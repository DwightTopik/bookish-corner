import 'package:flutter/material.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/domain/reader_palette.dart';

/// Нижний ряд инструментов chrome. Раскладка `spaceEvenly`. Иконки в стиле
/// тулбара плеера (`_BarAction`-паттерн: [InkResponse] + [Icon]).
///
/// В B2 все действия — плейсхолдеры/стабы (см. карту задач):
/// главы→D5, блокнот→E, настройки→B3, закладка→D2. Кнопка «Слушать» скрыта за
/// [hasAudioVersion] (источник появится позже; сейчас всегда `false`).
class ReaderToolbar extends StatelessWidget {
  const ReaderToolbar({
    super.key,
    required this.isBookmarked,
    required this.hasAudioVersion,
    required this.palette,
    required this.onChapters,
    required this.onNotebook,
    required this.onListen,
    required this.onSettings,
    required this.onBookmark,
  });

  final bool isBookmarked;
  final bool hasAudioVersion;
  final ReaderPalette palette;
  final VoidCallback onChapters;
  final VoidCallback onNotebook;
  final VoidCallback onListen;
  final VoidCallback onSettings;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final like = context.appColors.like;
    return SizedBox(
      height: AppDimensions.readerToolbarHeight,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ToolbarAction(
              icon: Icons.format_list_bulleted,
              tooltip: 'Главы',
              iconColor: palette.muted,
              onTap: onChapters,
            ),
            _ToolbarAction(
              icon: Icons.edit_note,
              tooltip: 'Блокнот',
              iconColor: palette.muted,
              onTap: onNotebook,
            ),
            if (hasAudioVersion)
              _ToolbarAction(
                icon: Icons.headphones,
                tooltip: 'Слушать',
                iconColor: palette.muted,
                onTap: onListen,
              ),
            _ToolbarAction(
              icon: Icons.text_fields,
              tooltip: 'Настройки',
              iconColor: palette.muted,
              onTap: onSettings,
            ),
            _ToolbarAction(
              icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              tooltip: 'Закладка',
              onTap: onBookmark,
              iconColor: isBookmarked ? like : palette.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Tooltip(
        message: tooltip,
        child: Icon(
          icon,
          color: iconColor,
          size: AppDimensions.readerToolbarIconSize,
        ),
      ),
    );
  }
}
