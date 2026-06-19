/// Семантическая позиция в книге — двойная модель.
///
/// [progress] нормирован по ВСЕЙ книге (для слайдера и процентов), [anchor] —
/// непрозрачный, движко-специфичный якорь (CFI у epub, `page:quads` у pdf,
/// `chapterIdx:offset` у fb2/txt). Chrome НИКОГДА не парсит содержимое [anchor].
///
/// Пустой [anchor] (`''`) — сентинел «нет конкретного якоря, позиционируй по
/// [progress]» (используется при перемотке слайдером, где доступен только
/// процент). Движок резолвит позицию из [progress] самостоятельно.
class ReaderLocator {
  const ReaderLocator({
    required this.progress,
    required this.anchor,
    this.chapterIndex,
  });

  /// 0.0–1.0 по всей книге.
  final double progress;

  /// Непрозрачный якорь движка; `''` = позиционирование по [progress].
  final String anchor;

  /// Индекс главы в TOC (для отображения «Глава X»).
  final int? chapterIndex;

  ReaderLocator copyWith({
    double? progress,
    String? anchor,
    int? chapterIndex,
  }) {
    return ReaderLocator(
      progress: progress ?? this.progress,
      anchor: anchor ?? this.anchor,
      chapterIndex: chapterIndex ?? this.chapterIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderLocator &&
          other.progress == progress &&
          other.anchor == anchor &&
          other.chapterIndex == chapterIndex;

  @override
  int get hashCode => Object.hash(progress, anchor, chapterIndex);
}
