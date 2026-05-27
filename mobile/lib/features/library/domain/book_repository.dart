import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/book_chapter.dart';
import 'package:bookish_corner/features/library/domain/reading_status.dart';

abstract class BookRepository {
  Stream<List<Book>> watchAllBooks();
  Stream<Book?> watchBookById(String id);
  Future<void> addBook(Book book);
  Future<void> addBookWithChapters(Book book, List<BookChapter> chapters);
  Future<void> updateBook(Book book);
  Future<void> deleteBook(String id);
  Future<void> updateProgress(String id, double progress, String? lastPosition);
  Future<void> updateStatus(String id, ReadingStatus status);
  Future<List<BookChapter>> getChapters(String bookId);
  Future<void> replaceChapters(String bookId, List<BookChapter> chapters);
}
