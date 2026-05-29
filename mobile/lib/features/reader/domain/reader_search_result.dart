import 'package:bookish_corner/features/reader/domain/reader_locator.dart';

/// Результат полнотекстового поиска по книге (под экран поиска: группировка по
/// главам, процент позиции и подсветка совпадения).
class ReaderSearchResult {
  const ReaderSearchResult({
    required this.chapterTitle,
    required this.excerpt,
    required this.matchStart,
    required this.matchLength,
    required this.progress,
    required this.anchor,
  });

  final String chapterTitle;
  final String excerpt;

  /// Диапазон совпадения внутри [excerpt] (для подсветки).
  final int matchStart;
  final int matchLength;

  /// Процент позиции совпадения по всей книге.
  final double progress;

  /// Цель перехода к совпадению.
  final ReaderLocator anchor;
}
