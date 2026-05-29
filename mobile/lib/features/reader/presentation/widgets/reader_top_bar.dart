import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:bookish_corner/core/theme/app_colors.dart';

/// Верхняя панель chrome (видна при `chromeVisible`). Зеркалит `_PlayerHeader`:
/// слева шеврон-вниз (pop экрана), по центру title (жирный) + author
/// (приглушённый) в две строки, справа kebab.
///
/// kebab в B2 — плейсхолдер (no-op); реальный sheet «О книге / Поиск / Уже
/// прочитано» = задача D4.
class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({
    super.key,
    required this.title,
    required this.author,
    required this.onClose,
    required this.onMenu,
  });

  final String title;
  final String author;
  final VoidCallback onClose;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final AppColors(:bg, :textPrimary, :textTertiary) = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.92)),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Назад',
              onPressed: onClose,
              icon: Icon(Icons.keyboard_arrow_down, color: textPrimary),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textTertiary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Ещё',
              onPressed: onMenu,
              icon: Icon(Icons.more_vert, color: textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
