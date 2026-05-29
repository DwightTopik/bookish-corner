import 'package:bookish_corner/features/reader/domain/reader_locator.dart';

/// Запись оглавления (Table of Contents).
class TocEntry {
  const TocEntry({
    required this.id,
    required this.title,
    required this.index,
    required this.depth,
    required this.anchor,
    this.startProgress,
  });

  /// Стабильный идентификатор (spine href у epub / индекс главы у fb2/txt).
  final String id;
  final String title;
  final int index;

  /// Вложенность записи (epub-nav бывает многоуровневым).
  final int depth;

  /// Цель перехода.
  final ReaderLocator anchor;

  /// Начальный процент главы; `null`, если ещё неизвестен (у epub известен
  /// только после генерации locations).
  final double? startProgress;

  TocEntry copyWith({
    String? id,
    String? title,
    int? index,
    int? depth,
    ReaderLocator? anchor,
    double? startProgress,
  }) {
    return TocEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      index: index ?? this.index,
      depth: depth ?? this.depth,
      anchor: anchor ?? this.anchor,
      startProgress: startProgress ?? this.startProgress,
    );
  }
}
