import 'package:flutter/material.dart';

import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/core/theme/highlight_colors.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';

const double _kSwatchSize = 28.0;
const double _kSwatchRingGap = 2.0;
const double _kSwatchRingWidth = 2.0;

/// Цветной кружок пикера хайлайтов. Используется в меню выделения, редакторе
/// заметки и меню тапа по хайлайту.
class HighlightSwatch extends StatelessWidget {
  const HighlightSwatch({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final HighlightColor color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final swatchColor = highlightSwatchColor(color, colors);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.square(
        dimension: _kSwatchSize + (_kSwatchRingGap + _kSwatchRingWidth) * 2,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: _kSwatchSize,
            height: _kSwatchSize,
            decoration: BoxDecoration(
              color: swatchColor,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.fromBorderSide(
                      BorderSide(
                        color: swatchColor,
                        width: _kSwatchRingWidth + _kSwatchRingGap,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
