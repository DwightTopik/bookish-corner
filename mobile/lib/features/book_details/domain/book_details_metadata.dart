import 'package:bookish_corner/features/library/domain/book.dart';

class BookDetailsMetadata {
  const BookDetailsMetadata({
    this.title,
    this.author,
    this.coverImagePath,
    this.coverUrl,
    this.series,
    this.description,
    this.categories = const [],
    this.ageRestriction,
    this.publishedDate,
    this.writtenDate,
    this.isbn,
    this.translator,
    this.narrator,
    this.duration,
    this.publisher,
    this.rightHolder,
    this.language,
    this.pageCount,
    this.tableOfContents = const [],
  });

  final String? title;
  final String? author;
  final String? coverImagePath;
  final String? coverUrl;
  final String? series;
  final String? description;
  final List<String> categories;
  final String? ageRestriction;
  final String? publishedDate;
  final String? writtenDate;
  final String? isbn;
  final String? translator;
  final String? narrator;
  final String? duration;
  final String? publisher;
  final String? rightHolder;
  final String? language;
  final String? pageCount;
  final List<String> tableOfContents;

  factory BookDetailsMetadata.fromBook(Book book) {
    final Book(
      :title,
      :author,
      :coverImagePath,
      :coverUrl,
      :description,
      :narrator,
      :totalDuration,
      :language,
      :pageCount,
    ) = book;
    return BookDetailsMetadata(
      title: _clean(title),
      author: _clean(author),
      coverImagePath: _clean(coverImagePath),
      coverUrl: _clean(coverUrl),
      description: _clean(description),
      narrator: _clean(narrator),
      duration: _formatDurationSeconds(totalDuration),
      language: _clean(language),
      pageCount: pageCount == null || pageCount <= 0 ? null : '$pageCount стр.',
    );
  }

  BookDetailsMetadata mergeMissing(BookDetailsMetadata? other) {
    if (other == null) return this;
    final BookDetailsMetadata(
      title: otherTitle,
      author: otherAuthor,
      coverImagePath: otherCoverImagePath,
      coverUrl: otherCoverUrl,
      series: otherSeries,
      description: otherDescription,
      categories: otherCategories,
      ageRestriction: otherAgeRestriction,
      publishedDate: otherPublishedDate,
      writtenDate: otherWrittenDate,
      isbn: otherIsbn,
      translator: otherTranslator,
      narrator: otherNarrator,
      duration: otherDuration,
      publisher: otherPublisher,
      rightHolder: otherRightHolder,
      language: otherLanguage,
      pageCount: otherPageCount,
      tableOfContents: otherTableOfContents,
    ) = other;
    return BookDetailsMetadata(
      title: _prefer(title, otherTitle),
      author: _prefer(author, otherAuthor),
      coverImagePath: _prefer(coverImagePath, otherCoverImagePath),
      coverUrl: _prefer(coverUrl, otherCoverUrl),
      series: _prefer(series, otherSeries),
      description: _prefer(description, otherDescription),
      categories: _mergeLists(categories, otherCategories),
      ageRestriction: _prefer(ageRestriction, otherAgeRestriction),
      publishedDate: _prefer(publishedDate, otherPublishedDate),
      writtenDate: _prefer(writtenDate, otherWrittenDate),
      isbn: _prefer(isbn, otherIsbn),
      translator: _prefer(translator, otherTranslator),
      narrator: _prefer(narrator, otherNarrator),
      duration: _prefer(duration, otherDuration),
      publisher: _prefer(publisher, otherPublisher),
      rightHolder: _prefer(rightHolder, otherRightHolder),
      language: _prefer(language, otherLanguage),
      pageCount: _prefer(pageCount, otherPageCount),
      tableOfContents: _mergeLists(tableOfContents, otherTableOfContents),
    );
  }

  bool get hasAnyDetails {
    return [
          series,
          description,
          ageRestriction,
          publishedDate,
          writtenDate,
          isbn,
          translator,
          narrator,
          duration,
          publisher,
          rightHolder,
          language,
          pageCount,
        ].any((value) => _clean(value) != null) ||
        categories.isNotEmpty ||
        tableOfContents.isNotEmpty;
  }

  static String? _prefer(String? primary, String? secondary) {
    return _clean(primary) ?? _clean(secondary);
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final normalized = trimmed.toLowerCase();
    const emptyMarkers = {
      'unknown',
      'absent',
      'null',
      'not specified',
      'неизвестно',
      'нет',
      'не указано',
      'отсутствует',
    };
    return emptyMarkers.contains(normalized) ? null : trimmed;
  }

  static List<String> _mergeLists(
    List<String> primary,
    List<String> secondary,
  ) {
    final result = <String>[];
    final seen = <String>{};
    for (final value in [...primary, ...secondary]) {
      final cleaned = _clean(value);
      if (cleaned == null) continue;
      final key = cleaned.toLowerCase();
      if (seen.add(key)) result.add(cleaned);
    }
    return result;
  }

  static String? _formatDurationSeconds(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) return null;
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '$hours ч ${minutes.toString().padLeft(2, '0')} мин';
    return '$minutes мин';
  }
}
