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
    required this.readerWhiteMuted,
    required this.readerSepiaBg,
    required this.readerSepiaText,
    required this.readerSepiaMuted,
    required this.readerGrayBg,
    required this.readerGrayText,
    required this.readerGrayMuted,
    required this.readerBlackBg,
    required this.readerBlackText,
    required this.readerBlackMuted,
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

  /// Фиксированные палитры ридера (bg/text/muted). Одинаковые в dark и light —
  /// независимы от app-темы. Авто-тема резолвится через [ReaderPalette.resolve]
  /// как bg/textPrimary/textTertiary текущей app-темы.
  final Color readerWhiteBg;
  final Color readerWhiteText;
  final Color readerWhiteMuted;
  final Color readerSepiaBg;
  final Color readerSepiaText;
  final Color readerSepiaMuted;
  final Color readerGrayBg;
  final Color readerGrayText;
  final Color readerGrayMuted;
  final Color readerBlackBg;
  final Color readerBlackText;
  final Color readerBlackMuted;

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
    readerWhiteText: Color(0xFF2D2D2D),
    readerWhiteMuted: Color(0xFF969696),
    readerSepiaBg: Color(0xFFFBF4E2),
    readerSepiaText: Color(0xFF59391F),
    readerSepiaMuted: Color(0xFFA89785),
    readerGrayBg: Color(0xFF4B4B4B),
    readerGrayText: Color(0xFFE3E3E3),
    readerGrayMuted: Color(0xFF969696),
    readerBlackBg: Color(0xFF010101),
    readerBlackText: Color(0xFFC2C2C2),
    readerBlackMuted: Color(0xFF616161),
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
    readerWhiteText: Color(0xFF2D2D2D),
    readerWhiteMuted: Color(0xFF969696),
    readerSepiaBg: Color(0xFFFBF4E2),
    readerSepiaText: Color(0xFF59391F),
    readerSepiaMuted: Color(0xFFA89785),
    readerGrayBg: Color(0xFF4B4B4B),
    readerGrayText: Color(0xFFE3E3E3),
    readerGrayMuted: Color(0xFF969696),
    readerBlackBg: Color(0xFF010101),
    readerBlackText: Color(0xFFC2C2C2),
    readerBlackMuted: Color(0xFF616161),
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
    Color? readerWhiteMuted,
    Color? readerSepiaBg,
    Color? readerSepiaText,
    Color? readerSepiaMuted,
    Color? readerGrayBg,
    Color? readerGrayText,
    Color? readerGrayMuted,
    Color? readerBlackBg,
    Color? readerBlackText,
    Color? readerBlackMuted,
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
      readerWhiteMuted: readerWhiteMuted ?? this.readerWhiteMuted,
      readerSepiaBg: readerSepiaBg ?? this.readerSepiaBg,
      readerSepiaText: readerSepiaText ?? this.readerSepiaText,
      readerSepiaMuted: readerSepiaMuted ?? this.readerSepiaMuted,
      readerGrayBg: readerGrayBg ?? this.readerGrayBg,
      readerGrayText: readerGrayText ?? this.readerGrayText,
      readerGrayMuted: readerGrayMuted ?? this.readerGrayMuted,
      readerBlackBg: readerBlackBg ?? this.readerBlackBg,
      readerBlackText: readerBlackText ?? this.readerBlackText,
      readerBlackMuted: readerBlackMuted ?? this.readerBlackMuted,
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
      :readerWhiteMuted,
      :readerSepiaBg,
      :readerSepiaText,
      :readerSepiaMuted,
      :readerGrayBg,
      :readerGrayText,
      :readerGrayMuted,
      :readerBlackBg,
      :readerBlackText,
      :readerBlackMuted,
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
      readerWhiteMuted: Color.lerp(this.readerWhiteMuted, readerWhiteMuted, t)!,
      readerSepiaBg: Color.lerp(this.readerSepiaBg, readerSepiaBg, t)!,
      readerSepiaText: Color.lerp(this.readerSepiaText, readerSepiaText, t)!,
      readerSepiaMuted: Color.lerp(this.readerSepiaMuted, readerSepiaMuted, t)!,
      readerGrayBg: Color.lerp(this.readerGrayBg, readerGrayBg, t)!,
      readerGrayText: Color.lerp(this.readerGrayText, readerGrayText, t)!,
      readerGrayMuted: Color.lerp(this.readerGrayMuted, readerGrayMuted, t)!,
      readerBlackBg: Color.lerp(this.readerBlackBg, readerBlackBg, t)!,
      readerBlackText: Color.lerp(this.readerBlackText, readerBlackText, t)!,
      readerBlackMuted: Color.lerp(this.readerBlackMuted, readerBlackMuted, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
