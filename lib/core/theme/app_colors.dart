import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.primary,
    required this.text,
  });

  final Color background;
  final Color primary;
  final Color text;

  static const light = AppColors(
    background: Color(0xFFFFFFFF),
    primary: Color(0xFF2563EB),
    text: Color(0xFF111827),
  );

  static const dark = AppColors(
    background: Color(0xFF121212),
    primary: Color(0xFF3B82F6),
    text: Color(0xFFF9FAFB),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith({Color? background, Color? primary, Color? text}) {
    return AppColors(
      background: background ?? this.background,
      primary: primary ?? this.primary,
      text: text ?? this.text,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t) ?? background,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      text: Color.lerp(text, other.text, t) ?? text,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get colors => AppColors.of(this);
}
