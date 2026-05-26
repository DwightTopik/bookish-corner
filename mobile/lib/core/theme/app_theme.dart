import 'package:flutter/material.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';

ThemeData buildLightTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2D8B6F),
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: base.copyWith(surface: AppColors.light.surface),
    scaffoldBackgroundColor: AppColors.light.bg,
    extensions: const [AppColors.light],
  );
}

ThemeData buildDarkTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2D8B6F),
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: base.copyWith(surface: AppColors.dark.surface),
    scaffoldBackgroundColor: AppColors.dark.bg,
    extensions: const [AppColors.dark],
  );
}
