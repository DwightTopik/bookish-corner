import 'package:drift/drift.dart';

import 'package:bookish_corner/core/database/app_database.dart'
    hide AudioProgress;
import 'package:bookish_corner/features/player/domain/audio_progress.dart';
import 'package:bookish_corner/features/player/domain/audio_progress_repository.dart';

class DriftAudioProgressRepository implements AudioProgressRepository {
  DriftAudioProgressRepository(this._db);

  final AppDatabase _db;

  @override
  Future<AudioProgress?> getProgress(String bookId) async {
    final query = _db.select(_db.audioProgress)
      ..where((t) => t.bookId.equals(bookId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final AudioProgressRow(:chapterIndex, :positionMs, :updatedAt) = row;
    return AudioProgress(
      bookId: bookId,
      chapterIndex: chapterIndex,
      positionMs: positionMs,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> saveProgress(AudioProgress progress) async {
    final AudioProgress(:bookId, :chapterIndex, :positionMs, :updatedAt) =
        progress;
    await _db
        .into(_db.audioProgress)
        .insertOnConflictUpdate(
          AudioProgressCompanion(
            bookId: Value(bookId),
            chapterIndex: Value(chapterIndex),
            positionMs: Value(positionMs),
            updatedAt: Value(updatedAt),
          ),
        );
  }

  @override
  Future<void> deleteProgress(String bookId) async {
    await (_db.delete(
      _db.audioProgress,
    )..where((t) => t.bookId.equals(bookId))).go();
  }
}
