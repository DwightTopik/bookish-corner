import 'package:flutter/material.dart';

import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';

/// Разрешённая тройка цветов (фон/текст/muted) для reader-экрана.
/// Используется chrome-виджетами (topbar/toolbar/bottom panel/footer).
@immutable
class ReaderPalette {
  const ReaderPalette({
    required this.bg,
    required this.text,
    required this.muted,
  });

  final Color bg;
  final Color text;
  final Color muted;

  /// Возвращает палитру для [background]:
  /// - White/Sepia/Gray/Black — фиксированные значения, не зависят от app-темы.
  /// - system — следует за [AppColors]: bg/textPrimary/textTertiary.
  static ReaderPalette resolve(ReaderBackground background, AppColors colors) =>
      switch (background) {
        .white => ReaderPalette(
            bg: colors.readerWhiteBg,
            text: colors.readerWhiteText,
            muted: colors.readerWhiteMuted,
          ),
        .sepia => ReaderPalette(
            bg: colors.readerSepiaBg,
            text: colors.readerSepiaText,
            muted: colors.readerSepiaMuted,
          ),
        .gray => ReaderPalette(
            bg: colors.readerGrayBg,
            text: colors.readerGrayText,
            muted: colors.readerGrayMuted,
          ),
        .black => ReaderPalette(
            bg: colors.readerBlackBg,
            text: colors.readerBlackText,
            muted: colors.readerBlackMuted,
          ),
        .system => ReaderPalette(
            bg: colors.bg,
            text: colors.textPrimary,
            muted: colors.textTertiary,
          ),
      };
}
