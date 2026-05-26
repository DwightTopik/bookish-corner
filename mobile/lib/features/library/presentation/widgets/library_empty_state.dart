import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';

class LibraryEmptyView extends StatelessWidget {
  const LibraryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => context.push('/library/add'),
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
