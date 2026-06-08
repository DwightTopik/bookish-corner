import 'package:drift/drift.dart';

import 'package:bookish_corner/core/database/app_database.dart';
import 'package:bookish_corner/features/reader/domain/reader_bookmark.dart';
import 'package:bookish_corner/features/reader/domain/reader_bookmark_repository.dart';

class DriftReaderBookmarkRepository implements ReaderBookmarkRepository {
  DriftReaderBookmarkRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ReaderBookmark>> watchBookmarks(String bookId) {
    final query = _db.select(_db.readerBookmarks)
      ..where((t) => t.bookId.equals(bookId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<bool> isBookmarked(String bookId, int charOffset) async {
    final query = _db.select(_db.readerBookmarks)
      ..where((t) => t.bookId.equals(bookId) & t.charOffset.equals(charOffset));
    return (await query.getSingleOrNull()) != null;
  }

  @override
  Future<void> addBookmark(ReaderBookmark bookmark) async {
    final ReaderBookmark(:id, :bookId, :charOffset, :chapterIndex, :previewText, :createdAt) = bookmark;
    await _db.into(_db.readerBookmarks).insertOnConflictUpdate(
      ReaderBookmarksCompanion(
        id: Value(id),
        bookId: Value(bookId),
        charOffset: Value(charOffset),
        chapterIndex: Value(chapterIndex),
        previewText: Value(previewText),
        createdAt: Value(createdAt),
      ),
    );
  }

  @override
  Future<void> removeBookmark(String id) async {
    await (_db.delete(_db.readerBookmarks)..where((t) => t.id.equals(id))).go();
  }

  ReaderBookmark _toDomain(ReaderBookmarkRow row) {
    final ReaderBookmarkRow(:id, :bookId, :charOffset, :chapterIndex, :previewText, :createdAt) = row;
    return ReaderBookmark(
      id: id,
      bookId: bookId,
      charOffset: charOffset,
      chapterIndex: chapterIndex,
      previewText: previewText,
      createdAt: createdAt,
    );
  }
}
