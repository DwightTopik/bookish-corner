import 'package:drift/drift.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/library/domain/book.dart';
import 'package:mobile/features/library/domain/book_format.dart';
import 'package:mobile/features/library/domain/book_repository.dart';
import 'package:mobile/features/library/domain/reading_status.dart';

class DriftBookRepository implements BookRepository {
  DriftBookRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Book>> watchAllBooks() {
    final query = _db.select(_db.books)
      ..orderBy([(b) => OrderingTerm.desc(b.addedAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<Book?> watchBookById(String id) {
    final query = _db.select(_db.books)..where((b) => b.id.equals(id));
    return query.watchSingleOrNull().map((row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<void> addBook(Book book) async {
    await _db.into(_db.books).insertOnConflictUpdate(_toCompanion(book));
  }

  @override
  Future<void> updateBook(Book book) async {
    await _db.into(_db.books).insertOnConflictUpdate(_toCompanion(book));
  }

  @override
  Future<void> deleteBook(String id) async {
    await (_db.delete(_db.books)..where((b) => b.id.equals(id))).go();
  }

  @override
  Future<void> updateProgress(
    String id,
    double progress,
    String? lastPosition,
  ) async {
    await (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(
        readingProgress: Value(progress),
        lastPosition: Value(lastPosition),
        lastOpenedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updateStatus(String id, ReadingStatus status) async {
    await (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(
        readingStatus: Value(status.name),
        finishedAt: Value(
          status == .finished ? DateTime.now() : null,
        ),
      ),
    );
  }

  Book _toDomain(BookRow row) {
    final BookRow(
      :id,
      :title,
      :author,
      :narrator,
      :filePath,
      :coverUrl,
      :format,
      :fileSize,
      :addedAt,
      :lastOpenedAt,
      :readingProgress,
      :lastPosition,
      :totalPages,
      :totalDuration,
      :linkedBookId,
      :readingStatus,
      :finishedAt,
      :userRating,
      :rating,
      :ratingCount,
      :description,
      :language,
      :pageCount,
    ) = row;
    return Book(
      id: id,
      title: title,
      author: author,
      narrator: narrator,
      filePath: filePath,
      coverUrl: coverUrl,
      format: BookFormat.values.byName(format),
      fileSize: fileSize,
      addedAt: addedAt,
      lastOpenedAt: lastOpenedAt,
      readingProgress: readingProgress,
      lastPosition: lastPosition,
      totalPages: totalPages,
      totalDuration: totalDuration,
      linkedBookId: linkedBookId,
      readingStatus: ReadingStatus.values.byName(readingStatus),
      finishedAt: finishedAt,
      userRating: userRating,
      rating: rating,
      ratingCount: ratingCount,
      description: description,
      language: language,
      pageCount: pageCount,
    );
  }

  BooksCompanion _toCompanion(Book book) {
    final Book(
      :id,
      :title,
      :author,
      :narrator,
      :filePath,
      :coverUrl,
      :format,
      :fileSize,
      :addedAt,
      :lastOpenedAt,
      :readingProgress,
      :lastPosition,
      :totalPages,
      :totalDuration,
      :linkedBookId,
      :readingStatus,
      :finishedAt,
      :userRating,
      :rating,
      :ratingCount,
      :description,
      :language,
      :pageCount,
    ) = book;
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      narrator: Value(narrator),
      filePath: Value(filePath),
      coverUrl: Value(coverUrl),
      format: Value(format.name),
      fileSize: Value(fileSize),
      addedAt: Value(addedAt),
      lastOpenedAt: Value(lastOpenedAt),
      readingProgress: Value(readingProgress),
      lastPosition: Value(lastPosition),
      totalPages: Value(totalPages),
      totalDuration: Value(totalDuration),
      linkedBookId: Value(linkedBookId),
      readingStatus: Value(readingStatus.name),
      finishedAt: Value(finishedAt),
      userRating: Value(userRating),
      rating: Value(rating),
      ratingCount: Value(ratingCount),
      description: Value(description),
      language: Value(language),
      pageCount: Value(pageCount),
    );
  }
}
