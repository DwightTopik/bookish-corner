import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';

abstract class ChapterResolver {
  Future<List<AudioChapter>> resolve(Book book);
}
