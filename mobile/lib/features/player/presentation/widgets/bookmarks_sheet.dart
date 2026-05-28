import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/player/domain/audio_bookmark.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_providers.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_state.dart';

class BookmarksSheet extends ConsumerStatefulWidget {
  const BookmarksSheet({super.key});

  @override
  ConsumerState<BookmarksSheet> createState() => _BookmarksSheetState();
}

class _BookmarksSheetState extends ConsumerState<BookmarksSheet> {
  static const _uuid = Uuid();

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final AppColors(:elevated, :border, :textSecondary) = colors;
    final state = ref.watch(playerProvider);
    final bookId = state.book?.id;
    final bookmarksAsync = bookId == null
        ? const AsyncValue.data(<AudioBookmark>[])
        : ref.watch(audioBookmarksProvider(bookId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.48,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return ColoredBox(
          color: elevated,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const .only(left: 20, top: 10, right: 20),
              child: Column(
                children: [
                  const _SheetHandle(),
                  const Gap(18),
                  const _SheetHeader(),
                  const Gap(12),
                  Expanded(
                    child: bookmarksAsync.when(
                      data: (bookmarks) => ListView.separated(
                        controller: scrollController,
                        padding: const .only(bottom: 18),
                        itemCount: bookmarks.length + 1,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: border),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _NewBookmarkRow(
                              state: state,
                              saving: _saving,
                              onAdd: () => _addBookmark(context, state),
                            );
                          }
                          final bookmark = bookmarks[index - 1];
                          return _BookmarkRow(
                            key: ValueKey(bookmark.id),
                            bookmark: bookmark,
                            onTap: () async {
                              await ref
                                  .read(playerProvider.notifier)
                                  .seekToBookmark(bookmark);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            onDelete: () => ref
                                .read(audioBookmarkRepositoryProvider)
                                .deleteBookmark(bookmark.id),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => Center(
                        child: Text(
                          'Не удалось загрузить закладки',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addBookmark(BuildContext context, PlayerState state) async {
    final PlayerState(:book, :playing, :chapterIndex, :position) = state;
    if (_saving || book == null) return;
    _saving = true;
    try {
      final chapterTitle = _chapterLabel(state);
      final defaultTitle = '$chapterTitle - ${_formatPosition(position)}';
      String? title;
      if (playing) {
        title = defaultTitle;
      } else {
        if (!context.mounted) return;
        title = await _requestBookmarkTitle(context, defaultTitle);
        if (!mounted) return;
        if (title == null) return;
        title = title.trim();
        if (title.isEmpty) {
          title = defaultTitle;
        }
      }
      final now = DateTime.now();
      final bookmark = AudioBookmark(
        id: _uuid.v4(),
        bookId: book.id,
        chapterIndex: chapterIndex,
        positionMs: position.inMilliseconds,
        title: title,
        chapterTitle: chapterTitle,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(audioBookmarkRepositoryProvider).addBookmark(bookmark);
      await HapticFeedback.lightImpact();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<String?> _requestBookmarkTitle(
    BuildContext context,
    String defaultTitle,
  ) {
    return showDialog<String>(
      context: context,
      builder: (_) => _BookmarkTitleDialog(defaultTitle: defaultTitle),
    );
  }
}

class _BookmarkTitleDialog extends StatefulWidget {
  const _BookmarkTitleDialog({required this.defaultTitle});

  final String defaultTitle;

  @override
  State<_BookmarkTitleDialog> createState() => _BookmarkTitleDialogState();
}

class _BookmarkTitleDialogState extends State<_BookmarkTitleDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final AppColors(
      :elevated,
      :textPrimary,
      :textSecondary,
      :textTertiary,
      :accent,
    ) = colors;
    return AlertDialog(
      backgroundColor: elevated,
      title: Text('Новая закладка', style: TextStyle(color: textPrimary)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 1,
        textInputAction: TextInputAction.done,
        style: TextStyle(color: textPrimary),
        decoration: InputDecoration(
          hintText: widget.defaultTitle,
          hintStyle: TextStyle(color: textTertiary),
        ),
        onSubmitted: _closeWithTitle,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Отмена', style: TextStyle(color: textSecondary)),
        ),
        TextButton(
          onPressed: () => _closeWithTitle(_controller.text),
          child: Text('Сохранить', style: TextStyle(color: accent)),
        ),
      ],
    );
  }

  void _closeWithTitle(String value) {
    final title = value;
    Navigator.of(context).pop(title);
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 5,
      decoration: BoxDecoration(
        color: context.appColors.textTertiary.withValues(alpha: 0.65),
        borderRadius: const .all(.circular(99)),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.appColors.textPrimary;
    return Center(
      child: Text(
        'Закладки',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

class _NewBookmarkRow extends StatelessWidget {
  const _NewBookmarkRow({
    required this.state,
    required this.saving,
    required this.onAdd,
  });

  final PlayerState state;
  final bool saving;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final AppColors(:textPrimary, :textTertiary, :accent) = colors;
    return SizedBox(
      height: 76,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Новая закладка',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const Gap(5),
                Text(
                  '${_chapterLabel(state)} - ${_formatPosition(state.position)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          IconButton(
            tooltip: 'Добавить закладку',
            onPressed: saving || state.book == null ? null : onAdd,
            icon: Icon(Icons.bookmark_add_outlined, color: accent),
          ),
        ],
      ),
    );
  }
}

class _BookmarkRow extends StatelessWidget {
  const _BookmarkRow({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  final AudioBookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final AppColors(:textPrimary, :textTertiary, :textSecondary) = colors;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    '${bookmark.chapterTitle} - ${_formatPosition(bookmark.position)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textTertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            IconButton(
              tooltip: 'Удалить закладку',
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

String _chapterLabel(PlayerState state) {
  final title = state.currentChapter?.title.trim();
  if (title != null && title.isNotEmpty) return title;
  final bookTitle = state.book?.title.trim();
  if (bookTitle != null && bookTitle.isNotEmpty) return bookTitle;
  return 'Текущая позиция';
}

String _formatPosition(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) return '$hours:$minutes:$seconds';
  return '$minutes:$seconds';
}
