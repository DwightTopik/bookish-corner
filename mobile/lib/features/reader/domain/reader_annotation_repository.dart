import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';

abstract class ReaderAnnotationRepository {
  Stream<List<ReaderAnnotation>> watchAnnotations(
    String bookId, {
    ReaderAnnotationType? type,
  });
  Future<void> addAnnotation(ReaderAnnotation annotation);
  Future<void> updateNote(String id, String noteText);
  Future<void> removeAnnotation(String id);
}
