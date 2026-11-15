// 维护跨页面共享能力，由初始化入口统一注册。

import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// 文件作用：
/// - access / refresh token、后端用户 ID 与 JWT exp 的一致持久化
/// - 为路由和网络层提供同步内存快照，避免读取到混合的新旧凭证
class TokenService extends GetxService {
  TokenService(StorageService storage) : _prefs = storage.prefs {
    // 构造时一次性从已初始化的存储恢复内存，后续同步 getter 读取内存记录。
    _record = _readRecord();
  }

  static const _kAccessToken = 'auth.access_token';
  static const _kRefreshToken = 'auth.refresh_token';
  static const _kExpiresAt = 'auth.expires_at';
  static const _kUserId = 'auth.user_id';

  final SharedPreferences _prefs;
  late _TokenRecord _record;
  // 初始队列已经完成，第一项可立即入队；后续写入依次接在队尾。
  Future<void> _writeQueue = Future<void>.value();

  String? get accessToken => _record.accessToken;
  String? get refreshToken => _record.refreshToken;
  int? get expiresAt => _record.expiresAt;

  /// 当前后端用户标识；旧版本没有该字段时不恢复为已登录状态。
  String? get userId => _record.userId;

  /// 整份替换登录或刷新返回的凭证，避免分项写入造成新旧字段混用。
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {
    // 先构造完整的新凭证记录，再整体替换，避免读到新 accessToken 配旧 refreshToken。
    final next = _TokenRecord(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: _decodeJwtExpiryMs(accessToken),
      userId: userId ?? _record.userId,
    );
    // 先替换内存记录；同一事件循环内的请求立即看到完整的新记录。
    _record = next;
    // 磁盘写入进入串行队列；较晚发起的 clear 会排在已入队的 save 后面。
    // 多个 SharedPreferences 键逐项写入，仍不等同于数据库事务。
    await _enqueueWrite(() async {
      await _prefs.setString(_kAccessToken, next.accessToken!);
      await _prefs.setString(_kRefreshToken, next.refreshToken!);
      if (next.expiresAt != null) {
        await _prefs.setInt(_kExpiresAt, next.expiresAt!);
      } else {
        // 新令牌没有可解析的 exp 时删除旧过期时间，避免用旧时间误判新令牌。
        await _prefs.remove(_kExpiresAt);
      }
      if (next.userId != null && next.userId!.isNotEmpty) {
        await _prefs.setString(_kUserId, next.userId!);
      } else {
        await _prefs.remove(_kUserId);
      }
    });
  }

  /// 清除整份记录；写队列保证迟到的 save 不会在登出后复活会话。
  Future<void> clear() async {
    // 先同步清空内存，后续路由和请求立即看见退出状态，再等待磁盘清理。
    _record = const _TokenRecord();
    // 磁盘写入进入串行队列；较晚发起的 clear 会排在已入队的 save 后面。
    // 多个 SharedPreferences 键逐项写入，仍不等同于数据库事务。
    await _enqueueWrite(() async {
      await _prefs.remove(_kAccessToken);
      await _prefs.remove(_kRefreshToken);
      // 新令牌没有可解析的 exp 时删除旧过期时间，避免用旧时间误判新令牌。
      await _prefs.remove(_kExpiresAt);
      await _prefs.remove(_kUserId);
    });
  }

  /// 同时具备用户身份和 accessToken 才是可恢复的登录会话。
  // 本地恢复要求同时有访问令牌和用户 ID；这只能说明本地状态齐全，不保证后端仍接受令牌。
  bool get hasToken =>
      accessToken?.isNotEmpty == true && userId?.isNotEmpty == true;

  /// 本地时钟估算是否过期；解析失败时交给服务端 401 兜底。
  bool get isExpired {
    final exp = expiresAt;
    // 无法推算过期时间时不主动刷新；由后端的 401 分支继续判断。
    if (exp == null) return false;
    return DateTime.now().millisecondsSinceEpoch >= exp;
  }

  // 从持久化数据恢复当前内存记录。
  _TokenRecord _readRecord() => _TokenRecord(
    accessToken: _prefs.getString(_kAccessToken),
    refreshToken: _prefs.getString(_kRefreshToken),
    expiresAt: _prefs.getInt(_kExpiresAt),
    userId: _prefs.getString(_kUserId),
  );

  /// 串行落盘，让较晚发起的登出或换号最终覆盖较早的异步写入。
  Future<void> _enqueueWrite(Future<void> Function() operation) {
    // 把当前操作串到上一个落盘任务之后，保证调用先后顺序。
    final result = _writeQueue.then((_) => operation());
    // 队尾吸收本次失败，防止队列后续任务全部被阻断；返回给调用方的 result 仍保留异常。
    _writeQueue = result.catchError((_) {});
    return result;
  }

  /// 解码 JWT payload 的 `exp`（Unix 秒）为毫秒；不负责签名校验。
  static int? _decodeJwtExpiryMs(String token) {
    // JWT 由 header、payload、signature 三段组成；这里只解码 payload，不校验签名。
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payloadJson = utf8.decode(
        // 先补齐 Base64URL 格式再解码；UTF-8 解码后才得到可供 jsonDecode 读取的文本。
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payload = jsonDecode(payloadJson);
      final exp = payload is Map ? payload['exp'] : null;
      // JWT exp 的单位是秒，转换为毫秒后才能和 Dart 的时间戳比较。
      if (exp is num) return (exp * 1000).toInt();
    } catch (_) {
      // 非 JWT 或数据损坏时不主动判过期。
    }
    return null;
  }
}

/// 仅在 [TokenService] 内整体替换的不可变凭证记录。
class _TokenRecord {
  const _TokenRecord({
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.userId,
  });

  final String? accessToken;
  final String? refreshToken;
  final int? expiresAt;
  final String? userId;
}
