import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';

/// Плейсхолдер-поверхность рендера для B2 — реального текста/пагинации ещё нет
/// (придёт с fb2-движком). Watch'ит [readerControllerProvider] и показывает,
/// на какой «странице» мы находимся, чтобы при next/prev/seek было видно смену
/// страницы. Статичный текст-рыба — чтобы поверхность не выглядела пустой.
class FakeReaderView extends ConsumerWidget {
  const FakeReaderView({super.key, required this.bookId});

  final String bookId;

  static const List<String> _lorem = [
    'Это плейсхолдер поверхности рендера. Реальный текст книги появится вместе '
        'с fb2-движком — сейчас здесь показана только текущая позиция, чтобы '
        'оболочка ридера была проверяема вручную.',
    'Тап по краям экрана и горизонтальные свайпы листают страницы через '
        'фейк-движок. Тап по центру скрывает и показывает элементы управления.',
    'Слайдер прогресса перематывает по всей книге, а нижняя панель отражает '
        'главу и сколько страниц осталось до следующей.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readerControllerProvider(bookId));
    final AppColors(:bg, :textPrimary, :textSecondary) = context.appColors;

    final progress = state.progress;
    final chapterIndex = progress?.locator.chapterIndex ?? 0;
    final currentPage = progress?.currentPage ?? 1;
    final totalPages = progress?.totalPages ?? 1;

    return ColoredBox(
      color: bg,
      child: Padding(
        padding: const .symmetric(
          horizontal: AppDimensions.readerContentHPadding,
          vertical: AppDimensions.readerContentVPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Глава ${chapterIndex + 1} · стр $currentPage из $totalPages',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const Gap(AppDimensions.sectionGap),
            for (final paragraph in _lorem) ...[
              Text(
                paragraph,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              const Gap(AppDimensions.sectionGap),
            ],
          ],
        ),
      ),
    );
  }
}
