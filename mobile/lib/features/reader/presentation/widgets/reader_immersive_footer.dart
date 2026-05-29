import 'package:flutter/material.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';

/// Приглушённый футер иммерсивного режима (`chromeVisible == false`): тонкий
/// «N из M» по центру снизу, в [SafeArea]. Больше ничего на экране нет.
class ReaderImmersiveFooter extends StatelessWidget {
  const ReaderImmersiveFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.appColors.textSecondary;
    return SafeArea(
      child: Padding(
        padding: const .only(
          bottom: AppDimensions.readerImmersiveFooterBottomGap,
        ),
        child: Text(
          '$currentPage из $totalPages',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textSecondary.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
