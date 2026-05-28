import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/reading_status.dart';

enum FormatFilter { all, books, audio }

@immutable
class LibraryFilterState {
  const LibraryFilterState({
    this.query = '',
    this.format = FormatFilter.all,
    this.statuses = const {},
    this.authors = const {},
  });

  final String query;
  final FormatFilter format;
  final Set<ReadingStatus> statuses;
  final Set<String> authors;

  bool get hasActiveFilters =>
      format != .all || statuses.isNotEmpty || authors.isNotEmpty;

  LibraryFilterState copyWith({
    String? query,
    FormatFilter? format,
    Set<ReadingStatus>? statuses,
    Set<String>? authors,
  }) => .new(
    query: query ?? this.query,
    format: format ?? this.format,
    statuses: statuses ?? this.statuses,
    authors: authors ?? this.authors,
  );
}

class LibraryFilterNotifier extends Notifier<LibraryFilterState> {
  @override
  LibraryFilterState build() => const .new();

  void setQuery(String q) => state = state.copyWith(query: q);

  void applyFilters({
    required FormatFilter format,
    required Set<ReadingStatus> statuses,
    required Set<String> authors,
  }) => state = state.copyWith(
    format: format,
    statuses: statuses,
    authors: authors,
  );

  void resetFilters() => state = state.copyWith(
    format: .all,
    statuses: const {},
    authors: const {},
  );
}

final libraryFilterProvider =
    NotifierProvider<LibraryFilterNotifier, LibraryFilterState>(
      LibraryFilterNotifier.new,
    );

final booksStreamProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(bookRepositoryProvider).watchAllBooks();
});

final filteredBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final booksAsync = ref.watch(booksStreamProvider);
  final filter = ref.watch(libraryFilterProvider);
  return booksAsync.whenData((books) => _applyFilter(books, filter));
});

List<Book> _applyFilter(List<Book> books, LibraryFilterState filter) {
  final LibraryFilterState(:query, :format, :statuses, :authors) = filter;
  List<Book> result = books;

  if (query.isNotEmpty) {
    final q = query.toLowerCase().trim();
    result = result
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();
  }

  result = switch (format) {
    .all => result,
    .books => result.where((b) => !b.format.isAudio).toList(),
    .audio => result.where((b) => b.format.isAudio).toList(),
  };

  if (statuses.isNotEmpty) {
    result = result
        .where((b) => statuses.contains(_effectiveStatus(b)))
        .toList();
  }

  if (authors.isNotEmpty) {
    result = result.where((b) => authors.contains(b.author)).toList();
  }

  return result;
}

ReadingStatus _effectiveStatus(Book book) {
  final progress = book.readingProgress;
  if (progress >= 1) return .finished;
  if (progress > 0) return .reading;
  return .notStarted;
}
