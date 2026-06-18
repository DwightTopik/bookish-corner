import 'package:flutter/material.dart';

import 'package:bookish_corner/core/widgets/highlight_swatch.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';

/// Горизонтальный ряд из 5 свотчей хайлайтов.
class HighlightColorPicker extends StatelessWidget {
  const HighlightColorPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final HighlightColor selected;
  final ValueChanged<HighlightColor> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in HighlightColor.values)
          HighlightSwatch(
            color: c,
            isSelected: c == selected,
            onTap: () => onSelect(c),
          ),
      ],
    );
  }
}
