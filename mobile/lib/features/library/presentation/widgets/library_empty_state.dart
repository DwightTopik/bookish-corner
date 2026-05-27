import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/library/presentation/providers/add_book_action.dart';

class LibraryEmptyView extends ConsumerWidget {
  const LibraryEmptyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors(:textTertiary, :textSecondary, :accent) = context.appColors;
    return Center(
      child: Padding(
        padding: const .all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 72,
              color: textTertiary,
            ),
            const Gap(16),
            Text(
              'Добавьте первую книгу',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
              ),
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: () => pickAndAddBook(ref),
              icon: const Icon(Icons.add),
              label: const Text('Добавить книгу'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
