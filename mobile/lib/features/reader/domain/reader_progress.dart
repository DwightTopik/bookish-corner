import 'package:bookish_corner/features/reader/domain/reader_locator.dart';

/// Снимок состояния рендера (volatile) — пересчитывается движком при каждом
/// перемещении и эмитится в [ReaderEngine.progress].
///
/// Маппинг на UI: слайдер ← [ReaderLocator.progress]; «% книги» =
/// `progress * 100`; «Глава X» ← [ReaderLocator.chapterIndex] + TOC;
/// «ещё N стр» ← [pagesToNextChapter]; «116 из 804» ← [currentPage]/[totalPages].
class ReaderProgress {
  const ReaderProgress({
    required this.locator,
    this.currentPage,
    this.totalPages,
    this.pagesToNextChapter,
  });

  final ReaderLocator locator;

  /// Номер страницы по всей книге; `null` для scroll-режима/движков без страниц.
  final int? currentPage;
  final int? totalPages;

  /// Сколько страниц осталось до начала следующей главы.
  final int? pagesToNextChapter;

  ReaderProgress copyWith({
    ReaderLocator? locator,
    int? currentPage,
    int? totalPages,
    int? pagesToNextChapter,
  }) {
    return ReaderProgress(
      locator: locator ?? this.locator,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      pagesToNextChapter: pagesToNextChapter ?? this.pagesToNextChapter,
    );
  }
}
