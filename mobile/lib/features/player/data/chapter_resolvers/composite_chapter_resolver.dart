import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/domain/chapter_resolver.dart';

class CompositeChapterResolver implements ChapterResolver {
  const CompositeChapterResolver(this.resolvers);

  final List<ChapterResolver> resolvers;

  @override
  Future<List<AudioChapter>> resolve(Book book) async {
    for (final resolver in resolvers) {
      try {
        final chapters = await resolver.resolve(book);
        if (chapters.isNotEmpty) return chapters;
      } catch (_) {}
    }
    return const [];
  }
}
