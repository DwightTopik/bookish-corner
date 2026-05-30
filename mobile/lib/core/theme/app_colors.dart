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
    required this.readerWhiteBg,
    required this.readerWhiteText,
    required this.readerSepiaBg,
    required this.readerSepiaText,
    required this.readerGrayBg,
    required this.readerGrayText,
    required this.readerBlackBg,
    required this.readerBlackText,
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

  /// Явные фоны/текст ридера (white/sepia/gray/black). «system» резолвится как
  /// [bg]/[textPrimary] текущей темы.
  final Color readerWhiteBg;
  final Color readerWhiteText;
  final Color readerSepiaBg;
  final Color readerSepiaText;
  final Color readerGrayBg;
  final Color readerGrayText;
  final Color readerBlackBg;
  final Color readerBlackText;

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
    readerWhiteBg: Color(0xFFFFFFFF),
    readerWhiteText: Color(0xFF171717),
    readerSepiaBg: Color(0xFFF5ECD7),
    readerSepiaText: Color(0xFF3B2E1A),
    readerGrayBg: Color(0xFF2C2C2E),
    readerGrayText: Color(0xFFE5E5EA),
    readerBlackBg: Color(0xFF000000),
    readerBlackText: Color(0xFFE5E5EA),
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
    readerWhiteBg: Color(0xFFFFFFFF),
    readerWhiteText: Color(0xFF171717),
    readerSepiaBg: Color(0xFFF5ECD7),
    readerSepiaText: Color(0xFF3B2E1A),
    readerGrayBg: Color(0xFFE5E5EA),
    readerGrayText: Color(0xFF1C1C1E),
    readerBlackBg: Color(0xFF000000),
    readerBlackText: Color(0xFFE5E5EA),
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
    Color? readerWhiteBg,
    Color? readerWhiteText,
    Color? readerSepiaBg,
    Color? readerSepiaText,
    Color? readerGrayBg,
    Color? readerGrayText,
    Color? readerBlackBg,
    Color? readerBlackText,
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
      readerWhiteBg: readerWhiteBg ?? this.readerWhiteBg,
      readerWhiteText: readerWhiteText ?? this.readerWhiteText,
      readerSepiaBg: readerSepiaBg ?? this.readerSepiaBg,
      readerSepiaText: readerSepiaText ?? this.readerSepiaText,
      readerGrayBg: readerGrayBg ?? this.readerGrayBg,
      readerGrayText: readerGrayText ?? this.readerGrayText,
      readerBlackBg: readerBlackBg ?? this.readerBlackBg,
      readerBlackText: readerBlackText ?? this.readerBlackText,
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
      :readerWhiteBg,
      :readerWhiteText,
      :readerSepiaBg,
      :readerSepiaText,
      :readerGrayBg,
      :readerGrayText,
      :readerBlackBg,
      :readerBlackText,
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
      readerWhiteBg: Color.lerp(this.readerWhiteBg, readerWhiteBg, t)!,
      readerWhiteText: Color.lerp(this.readerWhiteText, readerWhiteText, t)!,
      readerSepiaBg: Color.lerp(this.readerSepiaBg, readerSepiaBg, t)!,
      readerSepiaText: Color.lerp(this.readerSepiaText, readerSepiaText, t)!,
      readerGrayBg: Color.lerp(this.readerGrayBg, readerGrayBg, t)!,
      readerGrayText: Color.lerp(this.readerGrayText, readerGrayText, t)!,
      readerBlackBg: Color.lerp(this.readerBlackBg, readerBlackBg, t)!,
      readerBlackText: Color.lerp(this.readerBlackText, readerBlackText, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
