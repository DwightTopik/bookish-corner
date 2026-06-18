import 'package:flutter/material.dart';

import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';

/// Возвращает полупрозрачный тинт хайлайта для рисования поверх текста.
Color highlightTint(HighlightColor color, AppColors colors) =>
    switch (color) {
      .coral  => colors.readerHighlightCoral,
      .yellow => colors.readerHighlightYellow,
      .blue   => colors.readerHighlightBlue,
      .teal   => colors.readerHighlightTeal,
      .gray   => colors.readerHighlightGray,
    };

/// Непрозрачный цвет кружка пикера (тот же RGB, alpha=1).
Color highlightSwatchColor(HighlightColor color, AppColors colors) =>
    highlightTint(color, colors).withValues(alpha: 1);
