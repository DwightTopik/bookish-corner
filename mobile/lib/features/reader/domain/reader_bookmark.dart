class ReaderBookmark {
  const ReaderBookmark({
    required this.id,
    required this.bookId,
    required this.charOffset,
    this.chapterIndex,
    required this.previewText,
    required this.createdAt,
  });

  final String id;
  final String bookId;
  final int charOffset;
  final int? chapterIndex;
  final String previewText;
  final DateTime createdAt;
}
