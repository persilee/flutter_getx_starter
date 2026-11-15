// 集中定义可复用配置，调用方从公共入口读取。

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

/// Material与自定义控件共享AppStyle，关闭玻璃可使用build(brightness, glassEnabled: false)。
abstract final class AppTheme {
  static ThemeData get lightTheme => build(Brightness.light);
  static ThemeData get darkTheme => build(Brightness.dark);
  static ThemeData build(Brightness brightness, {bool glassEnabled = true}) {
    final s = (brightness == Brightness.dark ? AppStyle.dark : AppStyle.light)
        .copyWith(glassEnabled: glassEnabled);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: s.inputBorder),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [s],
      scaffoldBackgroundColor: s.background,
      canvasColor: s.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: s.primary,
        onPrimary: s.onPrimary,
        secondary: s.muted,
        onSecondary: s.foreground,
        surface: s.surface,
        onSurface: s.foreground,
        error: s.errorText,
        onError: brightness == Brightness.dark ? s.background : s.onDanger,
        outline: s.inputBorder,
        outlineVariant: s.border,
        surfaceContainerHighest: s.muted,
        onSurfaceVariant: s.mutedForeground,
      ),
      textTheme: AppTextStyles.theme(s),
      dividerTheme: DividerThemeData(color: s.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: s.background,
        foregroundColor: s.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.pageTitle.copyWith(color: s.foreground),
      ),
      cardTheme: CardThemeData(
        color: s.glassEnabled ? s.card : s.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: s.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: s.primary,
          foregroundColor: s.onPrimary,
          elevation: 0,
          minimumSize: const Size(48, 42),
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: s.foreground,
          side: BorderSide(color: s.inputBorder),
          shape: buttonShape,
          minimumSize: const Size(48, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: s.foreground,
          minimumSize: const Size(48, 42),
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: s.foreground,
          minimumSize: const Size(48, 48),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: s.muted,
        selectedColor: s.primary,
        labelStyle: AppTextStyles.secondary.copyWith(color: s.foreground),
        secondaryLabelStyle: AppTextStyles.secondary.copyWith(
          color: s.onPrimary,
        ),
        shape: const StadiumBorder(),
        side: BorderSide(color: s.border),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: s.inputBorder, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: s.errorText),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: s.errorText, width: 2),
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: s.errorText),
        errorMaxLines: 3,
        hintStyle: AppTextStyles.body.copyWith(color: s.mutedForeground),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
    );
  }
}
