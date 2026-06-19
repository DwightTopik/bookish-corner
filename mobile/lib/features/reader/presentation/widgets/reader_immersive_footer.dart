import 'package:flutter/material.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/features/reader/domain/reader_palette.dart';

/// Приглушённый футер иммерсивного режима (`chromeVisible == false`): тонкий
/// «N из M» по центру снизу, в [SafeArea]. Больше ничего на экране нет.
class ReaderImmersiveFooter extends StatelessWidget {
  const ReaderImmersiveFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.palette,
  });

  final int currentPage;
  final int totalPages;
  final ReaderPalette palette;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const .only(
          bottom: AppDimensions.readerImmersiveFooterBottomGap,
        ),
        child: Text(
          '$currentPage из $totalPages',
          textAlign: .center,
          style: TextStyle(
            color: palette.muted.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: .w500,
          ),
        ),
      ),
    );
  }
}
