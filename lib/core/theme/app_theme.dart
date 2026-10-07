import 'package:flutter/material.dart';
import 'package:project_starter/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light =>
      _createTheme(brightness: Brightness.light, colors: AppColors.light);

  static ThemeData get dark =>
      _createTheme(brightness: Brightness.dark, colors: AppColors.dark);

  static ThemeData _createTheme({
    required Brightness brightness,
    required AppColors colors,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: colors.primary,
              surface: colors.background,
              onSurface: colors.text,
            )
          : ColorScheme.light(
              primary: colors.primary,
              surface: colors.background,
              onSurface: colors.text,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
      ),
      extensions: [colors],
    );
  }
}
