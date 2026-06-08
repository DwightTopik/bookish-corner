enum ReaderAnnotationType { quote, note }

class ReaderAnnotation {
  const ReaderAnnotation({
    required this.id,
    required this.bookId,
    required this.type,
    required this.charStart,
    required this.charEnd,
    this.chapterIndex,
    required this.text,
    this.noteText,
    required this.createdAt,
  });

  final String id;
  final String bookId;
  final ReaderAnnotationType type;
  final int charStart;
  final int charEnd;
  final int? chapterIndex;
  final String text;
  final String? noteText;
  final DateTime createdAt;

  ReaderAnnotation copyWith({
    String? id,
    String? bookId,
    ReaderAnnotationType? type,
    int? charStart,
    int? charEnd,
    int? chapterIndex,
    String? text,
    String? noteText,
    DateTime? createdAt,
  }) {
    return ReaderAnnotation(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      type: type ?? this.type,
      charStart: charStart ?? this.charStart,
      charEnd: charEnd ?? this.charEnd,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      text: text ?? this.text,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
