import 'package:drift/drift.dart';

import 'package:bookish_corner/core/database/app_database.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation_repository.dart';

class DriftReaderAnnotationRepository implements ReaderAnnotationRepository {
  DriftReaderAnnotationRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ReaderAnnotation>> watchAnnotations(
    String bookId, {
    ReaderAnnotationType? type,
  }) {
    final query = _db.select(_db.readerAnnotations)
      ..where((t) {
        final byBook = t.bookId.equals(bookId);
        if (type != null) {
          return byBook & t.type.equals(type.index);
        }
        return byBook;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<void> addAnnotation(ReaderAnnotation annotation) async {
    final ReaderAnnotation(
      :id,
      :bookId,
      :type,
      :charStart,
      :charEnd,
      :chapterIndex,
      text: annotationText,
      :noteText,
      :color,
      :createdAt,
    ) = annotation;
    await _db.into(_db.readerAnnotations).insertOnConflictUpdate(
      ReaderAnnotationsCompanion(
        id: Value(id),
        bookId: Value(bookId),
        type: Value(type.index),
        charStart: Value(charStart),
        charEnd: Value(charEnd),
        chapterIndex: Value(chapterIndex),
        body: Value(annotationText),
        noteText: Value(noteText),
        color: Value(color.name),
        createdAt: Value(createdAt),
      ),
    );
  }

  @override
  Future<void> updateNote(String id, String noteText) async {
    await (_db.update(_db.readerAnnotations)..where((t) => t.id.equals(id)))
        .write(ReaderAnnotationsCompanion(noteText: Value(noteText)));
  }

  @override
  Future<void> updateColor(String id, HighlightColor color) async {
    await (_db.update(_db.readerAnnotations)..where((t) => t.id.equals(id)))
        .write(ReaderAnnotationsCompanion(color: Value(color.name)));
  }

  @override
  Future<void> removeAnnotation(String id) async {
    await (_db.delete(_db.readerAnnotations)..where((t) => t.id.equals(id))).go();
  }

  ReaderAnnotation _toDomain(ReaderAnnotationRow row) {
    final ReaderAnnotationRow(
      :id,
      :bookId,
      type: typeIndex,
      :charStart,
      :charEnd,
      :chapterIndex,
      body: annotationText,
      :noteText,
      :color,
      :createdAt,
    ) = row;
    return ReaderAnnotation(
      id: id,
      bookId: bookId,
      type: ReaderAnnotationType.values[typeIndex],
      charStart: charStart,
      charEnd: charEnd,
      chapterIndex: chapterIndex,
      text: annotationText,
      noteText: noteText,
      color: color == null ? HighlightColor.coral : HighlightColor.values.byName(color),
      createdAt: createdAt,
    );
  }
}
