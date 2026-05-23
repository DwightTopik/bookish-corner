import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.elevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentFallback,
    required this.like,
    required this.star,
    required this.success,
    required this.error,
  });

  final Color bg;
  final Color surface;
  final Color elevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentFallback;
  final Color like;
  final Color star;
  final Color success;
  final Color error;

  static const dark = AppColors(
    bg: Color(0xFF090A0B),
    surface: Color(0xFF121416),
    elevated: Color(0xFF1A1D21),
    border: Color(0xFF2E333A),
    textPrimary: Color(0xFFF4F0E8),
    textSecondary: Color(0xFFB8B1A7),
    textTertiary: Color(0xFF7D7973),
    accent: Color(0xFF2D8B6F),
    accentFallback: Color(0xFFC9822B),
    like: Color(0xFFE34B4B),
    star: Color(0xFFD8AE52),
    success: Color(0xFF4E9F6E),
    error: Color(0xFFE04F4F),
  );

  static const light = AppColors(
    bg: Color(0xFFF6F2EA),
    surface: Color(0xFFFFFDF8),
    elevated: Color(0xFFFFFDF8),
    border: Color(0xFFD8CFC2),
    textPrimary: Color(0xFF171717),
    textSecondary: Color(0xFF5F5A53),
    textTertiary: Color(0xFF5F5A53),
    accent: Color(0xFF2D8B6F),
    accentFallback: Color(0xFFC9822B),
    like: Color(0xFFE34B4B),
    star: Color(0xFFD8AE52),
    success: Color(0xFF4E9F6E),
    error: Color(0xFFE04F4F),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? elevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentFallback,
    Color? like,
    Color? star,
    Color? success,
    Color? error,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      elevated: elevated ?? this.elevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentFallback: accentFallback ?? this.accentFallback,
      like: like ?? this.like,
      star: star ?? this.star,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    final AppColors(
      :bg,
      :surface,
      :elevated,
      :border,
      :textPrimary,
      :textSecondary,
      :textTertiary,
      :accent,
      :accentFallback,
      :like,
      :star,
      :success,
      :error,
    ) = other;
    return AppColors(
      bg: Color.lerp(this.bg, bg, t)!,
      surface: Color.lerp(this.surface, surface, t)!,
      elevated: Color.lerp(this.elevated, elevated, t)!,
      border: Color.lerp(this.border, border, t)!,
      textPrimary: Color.lerp(this.textPrimary, textPrimary, t)!,
      textSecondary: Color.lerp(this.textSecondary, textSecondary, t)!,
      textTertiary: Color.lerp(this.textTertiary, textTertiary, t)!,
      accent: Color.lerp(this.accent, accent, t)!,
      accentFallback: Color.lerp(this.accentFallback, accentFallback, t)!,
      like: Color.lerp(this.like, like, t)!,
      star: Color.lerp(this.star, star, t)!,
      success: Color.lerp(this.success, success, t)!,
      error: Color.lerp(this.error, error, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
