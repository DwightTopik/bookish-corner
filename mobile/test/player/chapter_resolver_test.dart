import 'package:flutter_test/flutter_test.dart';

import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/book_format.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/composite_chapter_resolver.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/natural_sort.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/domain/chapter_resolver.dart';

void main() {
  group('naturalCompare', () {
    test('sorts embedded numbers by numeric value', () {
      final files = ['chapter 10.mp3', 'chapter 2.mp3', 'chapter 1.mp3'];

      files.sort(naturalCompare);

      expect(
        files,
        equals(['chapter 1.mp3', 'chapter 2.mp3', 'chapter 10.mp3']),
      );
    });
  });

  group('CompositeChapterResolver', () {
    test('returns first non-empty resolver result', () async {
      final expected = [
        const AudioChapter(
          index: 0,
          title: 'Chapter 1',
          filePath: 'book.mp3',
          startOffsetMs: 0,
          durationMs: 1000,
        ),
      ];
      final resolver = CompositeChapterResolver([
        _FakeResolver(const []),
        _FakeResolver(expected),
        _FakeResolver([
          const AudioChapter(
            index: 1,
            title: 'Ignored',
            filePath: 'book.mp3',
            startOffsetMs: 1000,
            durationMs: 1000,
          ),
        ]),
      ]);

      final result = await resolver.resolve(_book);

      expect(result, same(expected));
    });
  });
}

final _book = Book(
  id: 'book-id',
  title: 'Book',
  author: 'Author',
  filePath: 'book.mp3',
  format: BookFormat.mp3,
  addedAt: DateTime(2026),
);

class _FakeResolver implements ChapterResolver {
  const _FakeResolver(this.result);

  final List<AudioChapter> result;

  @override
  Future<List<AudioChapter>> resolve(Book book) async => result;
}
