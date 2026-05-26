import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/repository_providers.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/library/domain/book.dart';

class BookListTile extends ConsumerWidget {
  const BookListTile({super.key, required this.book});

  final Book book;

  void _open(BuildContext context) {
    if (book.format.isAudio) {
      context.push('/player/${book.id}');
    } else {
      context.push('/reader/${book.id}');
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final AppColors(:elevated, :error) = context.appColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: elevated,
        title: const Text('Удалить книгу?'),
        content: Text('«${book.title}» будет удалена из библиотеки.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(bookRepositoryProvider).deleteBook(book.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: context.appColors.elevated,
        borderRadius: const .all(.circular(14)),
        child: InkWell(
          borderRadius: const .all(.circular(14)),
          onTap: () => _open(context),
          onLongPress: () => _confirmDelete(context, ref),
          child: Padding(
            padding: const .all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BookCover(book: book),
                const Gap(12),
                Expanded(child: _BookInfo(book: book)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final AppColors(:border, :accent) = context.appColors;
    final showProgress = book.readingProgress > 0;
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const .all(.circular(8)),
            child: SizedBox(
              width: 80,
              height: 120,
              child: book.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: book.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const _CoverPlaceholder(),
                      errorWidget: (context, url, error) =>
                          const _CoverPlaceholder(),
                    )
                  : const _CoverPlaceholder(),
            ),
          ),
          if (showProgress) ...[
            const Gap(6),
            ClipRRect(
              borderRadius: const .all(.circular(2)),
              child: LinearProgressIndicator(
                value: book.readingProgress.clamp(0.0, 1.0),
                minHeight: 3,
                backgroundColor: border,
                color: accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final AppColors(:surface, :textTertiary) = context.appColors;
    return Container(
      color: surface,
      child: Icon(
        Icons.menu_book,
        color: textTertiary,
        size: 32,
      ),
    );
  }
}

class _BookInfo extends StatelessWidget {
  const _BookInfo({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :textSecondary, :textTertiary, :star) =
        context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const Gap(2),
        Text(
          book.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: textSecondary),
        ),
        if (book.format.isAudio && book.narrator != null) ...[
          const Gap(2),
          Text(
            'Читает: ${book.narrator}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: textTertiary),
          ),
        ],
        const Gap(8),
        Row(
          children: [
            _FormatBadge(book: book),
            if (book.rating != null) ...[
              const Gap(8),
              Icon(Icons.star, size: 14, color: star),
              const Gap(2),
              Text(
                book.rating!.toStringAsFixed(1),
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
              if (book.ratingCount != null) ...[
                const Gap(4),
                Text(
                  '${book.ratingCount}',
                  style: TextStyle(fontSize: 12, color: textTertiary),
                ),
              ],
            ],
          ],
        ),
        const Gap(8),
        _StatusRow(book: book),
      ],
    );
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final AppColors(:surface, :border, :textSecondary) = context.appColors;
    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const .all(.circular(6)),
        border: .fromBorderSide(.new(color: border)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (book.format.isAudio) ...[
            Icon(Icons.headphones, size: 12, color: textSecondary),
            const Gap(4),
          ],
          Text(
            book.format.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final AppColors(:success, :textPrimary, :accent) = context.appColors;
    if (book.readingStatus == .finished) {
      return Text(
        'Прочитано',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: success,
        ),
      );
    }
    if (book.readingStatus == .reading && book.readingProgress > 0) {
      final percent = (book.readingProgress * 100).round();
      final label = book.format.isAudio ? 'Слушать дальше' : 'Читать дальше';
      return Row(
        children: [
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const Gap(10),
          Flexible(
            child: Container(
              padding: const .symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: const .all(.circular(8)),
              ),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: accent,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
