import 'package:bookish_corner/features/library/domain/book_format.dart';
import 'package:bookish_corner/features/library/domain/reading_status.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.format,
    required this.addedAt,
    this.narrator,
    this.coverUrl,
    this.fileSize,
    this.lastOpenedAt,
    this.readingProgress = 0.0,
    this.lastPosition,
    this.totalPages,
    this.totalDuration,
    this.linkedBookId,
    this.readingStatus = ReadingStatus.notStarted,
    this.finishedAt,
    this.userRating,
    this.rating,
    this.ratingCount,
    this.description,
    this.language,
    this.pageCount,
  });

  final String id;
  final String title;
  final String author;
  final String? narrator;
  final String filePath;
  final String? coverUrl;
  final BookFormat format;
  final int? fileSize;
  final DateTime addedAt;
  final DateTime? lastOpenedAt;
  final double readingProgress;
  final String? lastPosition;
  final int? totalPages;
  final int? totalDuration;
  final String? linkedBookId;
  final ReadingStatus readingStatus;
  final DateTime? finishedAt;
  final int? userRating;
  final double? rating;
  final int? ratingCount;
  final String? description;
  final String? language;
  final int? pageCount;

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? narrator,
    String? filePath,
    String? coverUrl,
    BookFormat? format,
    int? fileSize,
    DateTime? addedAt,
    DateTime? lastOpenedAt,
    double? readingProgress,
    String? lastPosition,
    int? totalPages,
    int? totalDuration,
    String? linkedBookId,
    ReadingStatus? readingStatus,
    DateTime? finishedAt,
    int? userRating,
    double? rating,
    int? ratingCount,
    String? description,
    String? language,
    int? pageCount,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      narrator: narrator ?? this.narrator,
      filePath: filePath ?? this.filePath,
      coverUrl: coverUrl ?? this.coverUrl,
      format: format ?? this.format,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt ?? this.addedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      readingProgress: readingProgress ?? this.readingProgress,
      lastPosition: lastPosition ?? this.lastPosition,
      totalPages: totalPages ?? this.totalPages,
      totalDuration: totalDuration ?? this.totalDuration,
      linkedBookId: linkedBookId ?? this.linkedBookId,
      readingStatus: readingStatus ?? this.readingStatus,
      finishedAt: finishedAt ?? this.finishedAt,
      userRating: userRating ?? this.userRating,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      description: description ?? this.description,
      language: language ?? this.language,
      pageCount: pageCount ?? this.pageCount,
    );
  }
}
