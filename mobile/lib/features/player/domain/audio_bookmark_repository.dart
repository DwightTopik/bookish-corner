import 'package:bookish_corner/features/player/domain/audio_bookmark.dart';

abstract class AudioBookmarkRepository {
  Stream<List<AudioBookmark>> watchBookmarks(String bookId);
  Future<void> addBookmark(AudioBookmark bookmark);
  Future<void> deleteBookmark(String id);
}
