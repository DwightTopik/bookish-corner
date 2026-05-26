import 'package:mobile/features/library/domain/book.dart';
import 'package:mobile/features/library/domain/reading_status.dart';

abstract class BookRepository {
  Stream<List<Book>> watchAllBooks();
  Stream<Book?> watchBookById(String id);
  Future<void> addBook(Book book);
  Future<void> updateBook(Book book);
  Future<void> deleteBook(String id);
  Future<void> updateProgress(String id, double progress, String? lastPosition);
  Future<void> updateStatus(String id, ReadingStatus status);
}
