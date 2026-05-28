import 'package:drift/drift.dart';

import 'package:bookish_corner/core/database/app_database.dart';
import 'package:bookish_corner/features/player/domain/audio_bookmark.dart';
import 'package:bookish_corner/features/player/domain/audio_bookmark_repository.dart';

class DriftAudioBookmarkRepository implements AudioBookmarkRepository {
  DriftAudioBookmarkRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<AudioBookmark>> watchBookmarks(String bookId) {
    final query = _db.select(_db.audioBookmarks)
      ..where((t) => t.bookId.equals(bookId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<void> addBookmark(AudioBookmark bookmark) async {
    await _db
        .into(_db.audioBookmarks)
        .insertOnConflictUpdate(_toCompanion(bookmark));
  }

  @override
  Future<void> deleteBookmark(String id) async {
    await (_db.delete(_db.audioBookmarks)..where((t) => t.id.equals(id))).go();
  }

  AudioBookmark _toDomain(AudioBookmarkRow row) {
    final AudioBookmarkRow(
      :id,
      :bookId,
      :chapterIndex,
      :positionMs,
      :title,
      :chapterTitle,
      :createdAt,
      :updatedAt,
    ) = row;
    return AudioBookmark(
      id: id,
      bookId: bookId,
      chapterIndex: chapterIndex,
      positionMs: positionMs,
      title: title,
      chapterTitle: chapterTitle,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  AudioBookmarksCompanion _toCompanion(AudioBookmark bookmark) {
    final AudioBookmark(
      :id,
      :bookId,
      :chapterIndex,
      :positionMs,
      :title,
      :chapterTitle,
      :createdAt,
      :updatedAt,
    ) = bookmark;
    return AudioBookmarksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      positionMs: Value(positionMs),
      title: Value(title),
      chapterTitle: Value(chapterTitle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
