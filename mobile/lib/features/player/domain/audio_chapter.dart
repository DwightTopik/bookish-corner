import 'package:bookish_corner/features/library/domain/book_chapter.dart';

class AudioChapter {
  const AudioChapter({
    required this.index,
    required this.title,
    required this.filePath,
    required this.startOffsetMs,
    required this.durationMs,
  });

  final int index;
  final String title;
  final String filePath;
  final int startOffsetMs;
  final int durationMs;

  Duration get start => .new(milliseconds: startOffsetMs);
  Duration get duration => .new(milliseconds: durationMs);

  AudioChapter copyWith({
    int? index,
    String? title,
    String? filePath,
    int? startOffsetMs,
    int? durationMs,
  }) {
    return AudioChapter(
      index: index ?? this.index,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      startOffsetMs: startOffsetMs ?? this.startOffsetMs,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  factory AudioChapter.fromBookChapter(BookChapter row) {
    final BookChapter(:position, :title, :filePath, :duration, :startOffsetMs) =
        row;
    return AudioChapter(
      index: position,
      title: title ?? 'Глава ${position + 1}',
      filePath: filePath,
      startOffsetMs: startOffsetMs,
      durationMs: (duration ?? 0) * 1000,
    );
  }
}
