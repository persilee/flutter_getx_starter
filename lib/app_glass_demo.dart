import 'dart:ui';

import 'package:flutter/material.dart';

import 'common/style/index.dart';

// 独立教学入口，不需要登录、全局服务或后续 GlassSurface。
void main() => runApp(const AppGlassDemo());

class AppGlassDemo extends StatefulWidget {
  const AppGlassDemo({super.key});

  @override
  State<AppGlassDemo> createState() => _AppGlassDemoState();
}

class _AppGlassDemoState extends State<AppGlassDemo> {
  bool _enabled = true;
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final brightness = _dark ? Brightness.dark : Brightness.light;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(brightness, glassEnabled: _enabled),
      home: Scaffold(
        appBar: AppBar(title: const Text('玻璃效果对比')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SwitchListTile(
                title: const Text('开启玻璃效果'),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
              SwitchListTile(
                title: const Text('暗色主题'),
                value: _dark,
                onChanged: (value) => setState(() => _dark = value),
              ),
              const Text(
                'Glass 是组合视觉效果；blur 是模糊算法；BackdropFilter 是应用背景滤镜的组件。\n'
                '三块预览使用相同背景图片：先比较填充透明度，再比较背景模糊。关闭玻璃后全部回退为普通表面。',
              ),
              const SizedBox(height: 16),
              const _GlassPreview(kind: _SurfaceKind.opaque),
              const SizedBox(height: 16),
              const _GlassPreview(kind: _SurfaceKind.translucent),
              const SizedBox(height: 16),
              const _GlassPreview(kind: _SurfaceKind.frosted),
              const SizedBox(height: 28),
              Text(
                'Glass / blur / BackdropFilter',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Glass 示例跟随上方玻璃开关；blur 和 BackdropFilter 独立展示模糊，不受玻璃开关影响。Glass 是视觉组合，并非 Flutter 内置组件；'
                'blur 是算法，这里通过 ImageFiltered 作用于子组件；'
                'BackdropFilter 则处理组件背后的内容。三例使用相同模糊强度。',
              ),
              for (final effect in _EffectKind.values) ...[
                const SizedBox(height: 16),
                _EffectPreview(kind: effect),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 三种表面共用背景与布局，只改变填充和背景滤镜。
enum _SurfaceKind { opaque, translucent, frosted }

// 本节只演示参数如何驱动绘制；4-2 再把这类逻辑封装到 GlassSurface。
class _GlassPreview extends StatelessWidget {
  const _GlassPreview({required this.kind});

  final _SurfaceKind kind;

  @override
  Widget build(BuildContext context) {
    final glassEnabled = context.appStyle.glassEnabled;
    final translucent = glassEnabled && kind != _SurfaceKind.opaque;
    final blur = translucent && kind == _SurfaceKind.frosted;
    final title = switch (kind) {
      _SurfaceKind.opaque => '1. 普通表面',
      _SurfaceKind.translucent => '2. 半透明表面（无模糊）',
      _SurfaceKind.frosted => '3. 磨砂玻璃表面',
    };
    final description = !translucent
        ? '不透明填充遮住背景，无背景滤镜'
        : blur
        ? '半透明填充 + BackdropFilter + ImageFilter.blur\n背景模糊，文字保持清晰'
        : '半透明填充与渐变，无背景滤镜\n背景图片细节仍然清晰';
    final radius = BorderRadius.circular(AppRadius.card);
    Widget panel = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 第 2、3 块共用半透明填充；关闭玻璃后全部使用不透明表面。
        color: translucent ? null : context.appSurface,
        gradient: translucent
            ? LinearGradient(
                colors: [
                  AppGlass.cardFillOf(context),
                  ...AppGlass.headerGradientOf(context),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: radius,
        border: Border.all(color: AppGlass.borderOf(context)),
      ),
      child: Text('$title\n$description', style: AppTextStyles.bodyOn(context)),
    );
    if (blur) {
      panel = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppGlass.blurLight,
          sigmaY: AppGlass.blurLight,
        ),
        child: panel,
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: _PreviewBackground()),
          Padding(
            padding: const EdgeInsets.all(24),
            // 必须裁切滤镜范围，防止模糊扩展到整块背景或页面。
            child: ClipRRect(borderRadius: radius, child: panel),
          ),
        ],
      ),
    );
  }
}

const _backgroundUrl =
    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=1200&q=85&fit=crop';

class _PreviewBackground extends StatelessWidget {
  const _PreviewBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 图片加载中或失败时，色块仍能展示模糊差异。
        Row(
          children: [
            for (final color in [
              context.appPrimary,
              AppColors.success,
              AppColors.warning,
              context.appPrimary,
            ])
              Expanded(child: ColoredBox(color: color)),
          ],
        ),
        Image.network(
          _backgroundUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

enum _EffectKind { glass, blur, backdrop }

class _EffectPreview extends StatelessWidget {
  const _EffectPreview({required this.kind});

  final _EffectKind kind;

  @override
  Widget build(BuildContext context) {
    final glassDisabled =
        kind == _EffectKind.glass && !context.appStyle.glassEnabled;
    final radius = BorderRadius.circular(AppRadius.card);
    final filter = ImageFilter.blur(
      sigmaX: AppGlass.blurLight,
      sigmaY: AppGlass.blurLight,
    );
    final title = switch (kind) {
      _EffectKind.glass => 'Glass：完整玻璃组合',
      _EffectKind.blur => 'blur：模糊子组件',
      _EffectKind.backdrop => 'BackdropFilter：只模糊背景',
    };
    final description = glassDisabled
        ? '玻璃效果已关闭：普通不透明表面，无模糊。'
        : switch (kind) {
            _EffectKind.glass => '背景模糊 + 半透明填充 + 高光边框，前景文字清晰。',
            _EffectKind.blur => 'ImageFiltered 包裹图片和文字，两者一起模糊；外侧背景保持清晰。',
            _EffectKind.backdrop => '透明面板只应用背景模糊，不加玻璃填充；前景文字保持清晰。',
          };
    final label = Center(
      child: Text(
        'Flutter Glass\n观察文字与图片细节',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: glassDisabled
              ? Theme.of(context).colorScheme.onSurface
              : Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: glassDisabled
              ? null
              : const [Shadow(color: Colors.black87, blurRadius: 4)],
        ),
      ),
    );
    Widget panel;
    if (glassDisabled) {
      panel = DecoratedBox(
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: radius,
          border: Border.all(color: AppGlass.borderOf(context)),
        ),
        child: label,
      );
    } else if (kind == _EffectKind.blur) {
      panel = ImageFiltered(
        imageFilter: filter,
        child: Stack(
          fit: StackFit.expand,
          children: [const _PreviewBackground(), label],
        ),
      );
    } else {
      panel = BackdropFilter(
        filter: filter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: kind == _EffectKind.glass
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppGlass.cardFillOf(context),
                      ...AppGlass.headerGradientOf(context),
                    ],
                  )
                : null,
            border: kind == _EffectKind.glass
                ? Border.all(color: AppGlass.borderOf(context))
                : null,
          ),
          child: label,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyOn(context)),
        const SizedBox(height: 6),
        Text(description),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _PreviewBackground(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ClipRRect(borderRadius: radius, child: panel),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
