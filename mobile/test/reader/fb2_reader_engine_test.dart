import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:bookish_corner/features/library/domain/book_format.dart';
import 'package:bookish_corner/features/reader/data/fb2_reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';
import 'package:bookish_corner/features/reader/domain/reader_progress.dart';

/// Прокачивает event loop, чтобы доставить broadcast-эмиссии и резолв `open()`.
Future<void> pump() => .delayed(Duration.zero);

/// Две top-level секции с известными длинами plainText: «ABCDE» (5) и
/// «FGHIJKLMNO» (10). totalChars = 15, charsBeforeChapter = [0, 5].
const _mathFb2 = '''
<?xml version="1.0" encoding="UTF-8"?>
<FictionBook><body>
<section><p>ABCDE</p></section>
<section><p>FGHIJKLMNO</p></section>
</body></FictionBook>''';

/// Слово «поиск» во двух главах — для проверки search.
const _searchFb2 = '''
<?xml version="1.0" encoding="UTF-8"?>
<FictionBook><body>
<section><title><p>Первая</p></title><p>Начало поиск тут.</p></section>
<section><title><p>Вторая</p></title><p>Финал поиск здесь.</p></section>
</body></FictionBook>''';

void main() {
  group('Fb2ReaderEngine', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fb2_engine_test');
      // Удаление гарантируется даже при падении теста.
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });
    });

    Future<Fb2ReaderEngine> openEngine(
      String fixture, {
      BookFormat format = .fb2,
    }) async {
      final file = File(p.join(tempDir.path, 'book.${format.name}'));
      await file.writeAsString(fixture);
      final engine = Fb2ReaderEngine(filePath: file.path, format: format);
      addTearDown(engine.dispose);
      return engine;
    }

    test('после open эмитит стартовую позицию с page-полями null', () async {
      final engine = await openEngine(_mathFb2);
      final events = <ReaderProgress>[];
      final sub = engine.progress.listen(events.add);
      addTearDown(sub.cancel);

      await engine.open();
      await pump();

      expect(events, isNotEmpty);
      final ReaderProgress(
        :locator,
        :currentPage,
        :totalPages,
        :pagesToNextChapter,
      ) = events.last;
      expect(locator.progress, equals(0));
      expect(locator.chapterIndex, equals(0));
      expect(currentPage, isNull);
      expect(totalPages, isNull);
      expect(pagesToNextChapter, isNull);
    });

    test('toc корректен: depth, anchor «i:0», startProgress', () async {
      final engine = await openEngine(_mathFb2);
      await engine.open();

      expect(engine.toc, hasLength(2));
      expect(engine.toc[0].depth, equals(0));
      expect(engine.toc[0].anchor.anchor, equals('0:0'));
      expect(engine.toc[1].anchor.anchor, equals('1:0'));
      expect(engine.toc[1].startProgress, closeTo(5 / 15, 0.0001));
    });

    test('goTo("i:offset") считает progress по символьному смещению', () async {
      final engine = await openEngine(_mathFb2);
      final events = <ReaderProgress>[];
      final sub = engine.progress.listen(events.add);
      addTearDown(sub.cancel);
      await engine.open();
      await pump();

      await engine.goTo(
        const ReaderLocator(progress: 0, anchor: '1:2', chapterIndex: 1),
      );
      await pump();

      final ReaderProgress(:locator, :currentPage) = events.last;
      expect(locator.chapterIndex, equals(1));
      expect(locator.progress, closeTo(7 / 15, 0.0001));
      expect(currentPage, isNull);
    });

    test('goTo с пустым anchor резолвит позицию по progress', () async {
      final engine = await openEngine(_mathFb2);
      final events = <ReaderProgress>[];
      final sub = engine.progress.listen(events.add);
      addTearDown(sub.cancel);
      await engine.open();
      await pump();

      // Целевое смещение ~8 из 15 символов попадает во вторую главу со
      // смещением 3 внутри неё.
      await engine.goTo(const ReaderLocator(progress: 0.5, anchor: ''));
      await pump();

      final ReaderLocator(:chapterIndex, :anchor, :progress) =
          events.last.locator;
      expect(chapterIndex, equals(1));
      expect(anchor, equals('1:3'));
      expect(progress, closeTo(8 / 15, 0.0001));
    });

    test('search находит все вхождения, excerpt и offset корректны', () async {
      final engine = await openEngine(_searchFb2);
      await engine.open();

      final results = await engine.search('поиск');

      expect(results, hasLength(2));
      expect(results[0].chapterTitle, equals('Первая'));
      expect(results[0].anchor.chapterIndex, equals(0));
      expect(results[1].anchor.chapterIndex, equals(1));
      for (final r in results) {
        expect(r.matchLength, equals(5));
        final matched = r.excerpt
            .substring(r.matchStart, r.matchStart + r.matchLength)
            .toLowerCase();
        expect(matched, equals('поиск'));
      }
    });

    test('пустой query → пустой результат', () async {
      final engine = await openEngine(_searchFb2);
      await engine.open();

      expect(await engine.search(''), isEmpty);
    });

    test('txt-формат: одна глава, search по тексту работает', () async {
      final engine = await openEngine(
        'Первый абзац поиск.\n\nВторой абзац.',
        format: BookFormat.txt,
      );
      await engine.open();

      expect(engine.toc, hasLength(1));
      expect(await engine.search('поиск'), hasLength(1));
    });

    test('dispose идемпотентен', () async {
      final engine = await openEngine(_mathFb2);
      await engine.open();

      await engine.dispose();
      await engine.dispose();
    });
  });
}
