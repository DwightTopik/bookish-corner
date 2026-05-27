class BookChapter {
  const BookChapter({
    required this.id,
    required this.bookId,
    required this.position,
    required this.filePath,
    this.title,
    this.duration,
    this.startOffsetMs = 0,
  });

  final String id;
  final String bookId;
  final int position;
  final String filePath;
  final String? title;
  final int? duration;
  final int startOffsetMs;

  BookChapter copyWith({
    String? id,
    String? bookId,
    int? position,
    String? filePath,
    String? title,
    int? duration,
    int? startOffsetMs,
  }) {
    return BookChapter(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      position: position ?? this.position,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      startOffsetMs: startOffsetMs ?? this.startOffsetMs,
    );
  }
}
