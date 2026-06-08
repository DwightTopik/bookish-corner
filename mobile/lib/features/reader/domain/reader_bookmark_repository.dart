import 'package:bookish_corner/features/reader/domain/reader_bookmark.dart';

abstract class ReaderBookmarkRepository {
  Stream<List<ReaderBookmark>> watchBookmarks(String bookId);
  Future<bool> isBookmarked(String bookId, int charOffset);
  Future<void> addBookmark(ReaderBookmark bookmark);
  Future<void> removeBookmark(String id);
}
