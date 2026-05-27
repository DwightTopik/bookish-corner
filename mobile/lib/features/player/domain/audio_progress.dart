class AudioProgress {
  const AudioProgress({
    required this.bookId,
    required this.chapterIndex,
    required this.positionMs,
    required this.updatedAt,
  });

  final String bookId;
  final int chapterIndex;
  final int positionMs;
  final DateTime updatedAt;

  Duration get position => .new(milliseconds: positionMs);
}
