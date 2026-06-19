import 'package:drift/drift.dart';

import 'package:bookish_corner/core/database/app_database.dart'
    hide ReaderProgress;
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';
import 'package:bookish_corner/features/reader/domain/reader_progress_repository.dart';

class DriftReaderProgressRepository implements ReaderProgressRepository {
  DriftReaderProgressRepository(this._db);

  final AppDatabase _db;

  @override
  Future<ReaderLocator?> getProgress(String bookId) async {
    final query = _db.select(_db.readerProgress)
      ..where((t) => t.bookId.equals(bookId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toLocator(row);
  }

  @override
  Future<void> saveProgress(String bookId, ReaderLocator locator) async {
    final (chapterIndex, charOffset) = _parseAnchor(locator);
    await _db.into(_db.readerProgress).insertOnConflictUpdate(
      ReaderProgressCompanion(
        bookId: Value(bookId),
        charOffset: Value(charOffset),
        chapterIndex: Value(chapterIndex),
        percent: Value(locator.progress),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Stream<ReaderLocator?> watchProgress(String bookId) {
    final query = _db.select(_db.readerProgress)
      ..where((t) => t.bookId.equals(bookId));
    return query.watchSingleOrNull().map((row) => row == null ? null : _toLocator(row));
  }

  ReaderLocator _toLocator(ReaderProgressRow row) {
    final ReaderProgressRow(:chapterIndex, :percent, :charOffset) = row;
    final ci = chapterIndex ?? 0;
    return ReaderLocator(
      progress: percent,
      anchor: '$ci:$charOffset',
      chapterIndex: chapterIndex,
    );
  }

  /// Парсит anchor вида `"chapterIndex:charOffset"` (fb2/txt формат).
  /// Пустой anchor → fallback по locator.chapterIndex + offset=0.
  (int? chapterIndex, int charOffset) _parseAnchor(ReaderLocator locator) {
    if (locator.anchor.isEmpty) {
      return (locator.chapterIndex, 0);
    }
    final parts = locator.anchor.split(':');
    if (parts.length == 2) {
      final ci = int.tryParse(parts[0]);
      final co = int.tryParse(parts[1]) ?? 0;
      return (ci, co);
    }
    return (locator.chapterIndex, 0);
  }
}
