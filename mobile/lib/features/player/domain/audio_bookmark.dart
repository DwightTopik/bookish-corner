class AudioBookmark {
  const AudioBookmark({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.positionMs,
    required this.title,
    required this.chapterTitle,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String bookId;
  final int chapterIndex;
  final int positionMs;
  final String title;
  final String chapterTitle;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Duration get position => .new(milliseconds: positionMs);
}
