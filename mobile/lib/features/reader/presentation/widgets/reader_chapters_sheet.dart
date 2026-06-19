import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/domain/toc_entry.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_book_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';

/// Показывает bottom sheet с оглавлением книги. Тап по главе → мгновенный
/// переход + закрытие sheet. [context] должен быть в дереве выше [Scaffold].
void showReaderChaptersSheet(BuildContext context, String bookId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: ReaderChaptersSheet(bookId: bookId),
    ),
  );
}

/// Содержимое sheet оглавления. Публичный для тестирования.
class ReaderChaptersSheet extends ConsumerWidget {
  const ReaderChaptersSheet({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readerControllerProvider(bookId));
    final bookAsync = ref.watch(readerBookProvider(bookId));
    final book = switch (bookAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final toc = state.toc;
    final currentChapterIndex = state.progress?.locator.chapterIndex;
    final colors = context.appColors;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetCtx, scrollController) => DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: .vertical(top: .circular(16)),
        ).copyWith(color: colors.surface),
        child: Column(
          children: [
            const _DragHandle(),
            _SheetHeader(title: book?.title, author: book?.author),
            Divider(height: 1, color: colors.border),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: toc.length,
                itemBuilder: (_, i) {
                  final entry = toc[i];
                  final isActive = currentChapterIndex != null &&
                      entry.index == currentChapterIndex;
                  return _ChapterRow(
                    entry: entry,
                    isActive: isActive,
                    onTap: () {
                      ref
                          .read(readerControllerProvider(bookId).notifier)
                          .goToToc(entry);
                      Navigator.pop(sheetCtx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: AppDimensions.readerChaptersHandleWidth,
          height: AppDimensions.readerChaptersHandleHeight,
          decoration: BoxDecoration(
            color: context.appColors.textTertiary,
            borderRadius: const .all(
              .circular(AppDimensions.readerChaptersHandleHeight / 2),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({this.title, this.author});

  final String? title;
  final String? author;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const .symmetric(
        horizontal: AppDimensions.screenHPadding,
        vertical: AppDimensions.readerPanelVPadding,
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (title != null)
            Text(
              title!,
              maxLines: 1,
              overflow: .ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: .w600,
                fontSize: 16,
              ),
            ),
          if (author != null)
            Padding(
              padding: const .only(top: 2),
              child: Text(
                author!,
                maxLines: 1,
                overflow: .ellipsis,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.entry,
    required this.isActive,
    required this.onTap,
  });

  final TocEntry entry;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppDimensions.screenHPadding +
              entry.depth * AppDimensions.readerChaptersDepthIndent,
          end: AppDimensions.screenHPadding,
          top: AppDimensions.readerPanelVPadding,
          bottom: AppDimensions.readerPanelVPadding,
        ),
        child: Text(
          entry.title,
          style: TextStyle(
            color: isActive ? colors.accent : colors.textPrimary,
            fontWeight: isActive ? .w600 : .normal,
          ),
        ),
      ),
    );
  }
}
