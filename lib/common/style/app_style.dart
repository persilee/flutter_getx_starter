// 集中定义可复用配置，调用方从公共入口读取。

import 'package:flutter/material.dart';

/// 唯一主题数据：Material和自定义控件共享，主题动画通过lerp同步插值。
@immutable
class AppStyle extends ThemeExtension<AppStyle> {
  const AppStyle({
    required this.background,
    required this.foreground,
    required this.card,
    required this.primary,
    required this.onPrimary,
    required this.muted,
    required this.mutedForeground,
    required this.dangerAction,
    required this.onDanger,
    required this.border,
    required this.surface,
    required this.inputBorder,
    required this.errorText,
    required this.glassBorder,
    required this.headerGradient,
    required this.cardShadow,
    required this.sheetShadow,
    required this.dialogShadow,
    this.glassEnabled = true,
  });
  final Color background;
  final Color foreground;
  final Color card;
  final Color primary;
  final Color onPrimary;
  final Color muted;
  final Color mutedForeground;
  final Color dangerAction;
  final Color onDanger;
  final Color border;
  final Color surface;
  final Color inputBorder;
  final Color errorText;
  final Color glassBorder;
  final List<Color> headerGradient;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> sheetShadow;
  final List<BoxShadow> dialogShadow;

  /// 低性能场景可在根主题关闭玻璃，表面回退为不透明surface。
  final bool glassEnabled;
  static const light = AppStyle(
    background: Color(0xFFF5F1EA),
    foreground: Color(0xFF231F1A),
    card: Color(0xD1FFFFFF),
    primary: Color(0xFFD86B34),
    onPrimary: Color(0xFF231F1A),
    muted: Color(0xFFEDE8DF),
    mutedForeground: Color(0xFF736B61),
    dangerAction: Color(0xFFB91C1C),
    onDanger: Color(0xFFFFFFFF),
    border: Color(0x14322818),
    surface: Color(0xFFFFFFFF),
    inputBorder: Color(0xFF736B61),
    errorText: Color(0xFFB91C1C),
    glassBorder: Color(0x24FFFFFF),
    headerGradient: [Color(0x9EFFFFFF), Color(0x52FFFFFF), Color(0x0AFFFFFF)],
    cardShadow: [
      BoxShadow(
        color: Color(0x142C2216),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
    sheetShadow: [
      BoxShadow(
        color: Color(0x29352314),
        blurRadius: 40,
        offset: Offset(0, -18),
      ),
    ],
    dialogShadow: [
      BoxShadow(
        color: Color(0x29000000),
        blurRadius: 40,
        offset: Offset(0, 18),
      ),
    ],
  );
  static const dark = AppStyle(
    background: Color(0xFF141310),
    foreground: Color(0xFFF4EFE7),
    card: Color(0xE01C1B18),
    primary: Color(0xFFEF8A4E),
    onPrimary: Color(0xFF231F1A),
    muted: Color(0xFF282724),
    mutedForeground: Color(0xFFB0A89C),
    dangerAction: Color(0xFFB91C1C),
    onDanger: Color(0xFFFFFFFF),
    border: Color(0x14FFFFFF),
    surface: Color(0xFF1D1C18),
    inputBorder: Color(0xFFB0A89C),
    errorText: Color(0xFFFCA5A5),
    glassBorder: Color(0x08FFFFFF),
    headerGradient: [Color(0xC2121212), Color(0x61121212), Color(0x0A121212)],
    cardShadow: [
      BoxShadow(
        color: Color(0x47000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
    sheetShadow: [
      BoxShadow(
        color: Color(0x57000000),
        blurRadius: 48,
        offset: Offset(0, -24),
      ),
    ],
    dialogShadow: [
      BoxShadow(
        color: Color(0x57000000),
        blurRadius: 40,
        offset: Offset(0, 18),
      ),
    ],
  );

  @override
  AppStyle copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? primary,
    Color? onPrimary,
    Color? muted,
    Color? mutedForeground,
    Color? dangerAction,
    Color? onDanger,
    Color? border,
    Color? surface,
    Color? inputBorder,
    Color? errorText,
    Color? glassBorder,
    List<Color>? headerGradient,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? sheetShadow,
    List<BoxShadow>? dialogShadow,
    bool? glassEnabled,
  }) => AppStyle(
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
    card: card ?? this.card,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    muted: muted ?? this.muted,
    mutedForeground: mutedForeground ?? this.mutedForeground,
    dangerAction: dangerAction ?? this.dangerAction,
    onDanger: onDanger ?? this.onDanger,
    border: border ?? this.border,
    surface: surface ?? this.surface,
    inputBorder: inputBorder ?? this.inputBorder,
    errorText: errorText ?? this.errorText,
    glassBorder: glassBorder ?? this.glassBorder,
    headerGradient: headerGradient ?? this.headerGradient,
    cardShadow: cardShadow ?? this.cardShadow,
    sheetShadow: sheetShadow ?? this.sheetShadow,
    dialogShadow: dialogShadow ?? this.dialogShadow,
    glassEnabled: glassEnabled ?? this.glassEnabled,
  );
  @override
  AppStyle lerp(covariant AppStyle? other, double t) {
    if (other == null) return this;
    return AppStyle(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      dangerAction: Color.lerp(dangerAction, other.dangerAction, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      border: Color.lerp(border, other.border, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      headerGradient: List.generate(
        3,
        (i) => Color.lerp(headerGradient[i], other.headerGradient[i], t)!,
      ),
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
      sheetShadow: BoxShadow.lerpList(sheetShadow, other.sheetShadow, t)!,
      dialogShadow: BoxShadow.lerpList(dialogShadow, other.dialogShadow, t)!,
      glassEnabled: t < 0.5 ? glassEnabled : other.glassEnabled,
    );
  }
}
