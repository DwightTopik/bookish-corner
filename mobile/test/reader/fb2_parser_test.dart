import 'package:flutter_test/flutter_test.dart';

import 'package:bookish_corner/features/reader/data/document/reader_document.dart';
import 'package:bookish_corner/features/reader/data/document/fb2_parser.dart';

/// Синтетический мини-fb2: две top-level секции (вторая без заголовка),
/// вложенная подсекция, абзац с инлайн-начертанием и подзаголовок.
const _fb2 = '''
<?xml version="1.0" encoding="UTF-8"?>
<FictionBook>
  <body>
    <section>
      <title><p>Первая глава</p></title>
      <p>Обычный текст с <emphasis>курсивом</emphasis> и <strong>жирным</strong>.</p>
      <subtitle>Подзаголовок</subtitle>
      <section>
        <title><p>Вложенная</p></title>
        <p>Текст вложенной секции.</p>
      </section>
    </section>
    <section>
      <p>Глава без заголовка.</p>
    </section>
  </body>
</FictionBook>''';

void main() {
  group('Fb2Parser — структура', () {
    test('разворачивает секции в плоский список глав с depth', () {
      final doc = Fb2Parser.parse(_fb2, fallbackTitle: 'Книга');

      expect(doc.chapters, hasLength(3));
      expect(doc.chapters[0].title, equals('Первая глава'));
      expect(doc.chapters[0].depth, equals(0));
      // Вложенная секция идёт сразу после родителя и глубже на уровень.
      expect(doc.chapters[1].title, equals('Вложенная'));
      expect(doc.chapters[1].depth, equals(1));
    });

    test('секция без <title> НЕ нумеруется как «Глава N» — нейтральный фоллбэк',
        () {
      final doc = Fb2Parser.parse(_fb2, fallbackTitle: 'Книга');

      // Фоллбэк по первым словам контента, НЕ синтетический счётчик.
      expect(doc.chapters[2].title, equals('Глава без заголовка.'));
      expect(doc.chapters[2].title, isNot(equals('Глава 3')));
      expect(doc.chapters[2].depth, equals(0));
    });

    test('длинная безымянная секция → превью обрезается по слову с …', () {
      const fb2 = '''
<FictionBook><body><section>
<p>Это очень длинное вступление без собственного заголовка которое нужно обрезать.</p>
</section></body></FictionBook>''';
      final doc = Fb2Parser.parse(fb2, fallbackTitle: 'Книга');

      expect(doc.chapters.single.title, endsWith('…'));
      expect(doc.chapters.single.title.length, lessThanOrEqualTo(41));
      expect(doc.chapters.single.title, isNot(contains('Глава')));
    });

    test('многострочный <title> с <empty-line/> склеивается корректно', () {
      const fb2 = '''
<FictionBook><body><section>
<title><p>Ребекка Яррос</p><empty-line/><p>Четвертое крыло</p></title>
<p>Текст.</p>
</section></body></FictionBook>''';
      final doc = Fb2Parser.parse(fb2, fallbackTitle: 'Книга');

      expect(doc.chapters.single.title, equals('Ребекка Яррос Четвертое крыло'));
    });

    test('секция «Благодарности» со своим <title> сохраняет название', () {
      const fb2 = '''
<FictionBook><body>
<section><title><p>Глава 1</p></title><p>Текст.</p></section>
<section><title><p>Благодарности</p></title><p>Спасибо всем.</p></section>
</body></FictionBook>''';
      final doc = Fb2Parser.parse(fb2, fallbackTitle: 'Книга');

      expect(doc.chapters[0].title, equals('Глава 1'));
      expect(doc.chapters[1].title, equals('Благодарности'));
    });

    test('контент <epigraph> не теряется (фикс «чёрного экрана»)', () {
      const fb2 = '''
<FictionBook><body><section>
<epigraph><p>Посвящается Аарону.</p><text-author>Автор</text-author></epigraph>
</section></body></FictionBook>''';
      final doc = Fb2Parser.parse(fb2, fallbackTitle: 'Книга');

      final blocks = doc.chapters.single.blocks;
      expect(blocks, isNotEmpty);
      expect(doc.chapters.single.plainText, contains('Посвящается Аарону.'));
      expect(doc.chapters.single.plainText, contains('Автор'));
    });

    test('notes-body добавляется хвостовой главой со своим <title>', () {
      const fb2 = '''
<FictionBook>
<body><section><title><p>Глава 1</p></title><p>Текст.</p></section></body>
<body name="notes"><title><p>Примечания</p></title>
<section id="n_1"><title><p>1</p></title><p>Сноска один.</p></section>
</body>
</FictionBook>''';
      final doc = Fb2Parser.parse(fb2, fallbackTitle: 'Книга');

      expect(doc.chapters.last.title, equals('Примечания'));
      expect(doc.chapters.last.plainText, contains('Сноска один.'));
    });
  });

  group('Fb2Parser — блоки и раны', () {
    test('маппит <p> в ParagraphBlock, <subtitle> в HeadingBlock(level 2)', () {
      final doc = Fb2Parser.parse(_fb2, fallbackTitle: 'Книга');
      final blocks = doc.chapters[0].blocks;

      // Первый блок — заголовок главы (level 1), затем абзац, затем subtitle.
      expect(blocks, hasLength(3));
      expect(blocks[0], isA<HeadingBlock>());
      expect((blocks[0] as HeadingBlock).level, equals(1));
      expect(blocks[1], isA<ParagraphBlock>());
      expect(blocks[2], isA<HeadingBlock>());
      expect((blocks[2] as HeadingBlock).level, equals(2));
    });

    test('инлайн <emphasis>/<strong> дают курсив и жирный раны', () {
      final doc = Fb2Parser.parse(_fb2, fallbackTitle: 'Книга');
      final paragraph = doc.chapters[0].blocks[1] as ParagraphBlock;

      final hasItalic = paragraph.runs.any(
        (r) => r.italic && !r.bold && r.text.contains('курсивом'),
      );
      final hasBold = paragraph.runs.any(
        (r) => r.bold && !r.italic && r.text.contains('жирным'),
      );
      expect(hasItalic, isTrue);
      expect(hasBold, isTrue);
      // Пробел между ранами сохранён (не потерян тримом).
      expect(paragraph.text, equals('Обычный текст с курсивом и жирным.'));
    });

    test('агрегаты считаются по plainText глав', () {
      final doc = Fb2Parser.parse(_fb2, fallbackTitle: 'Книга');

      expect(doc.charsBeforeChapter, hasLength(doc.chapters.length));
      expect(doc.charsBeforeChapter.first, equals(0));
      expect(doc.totalChars, greaterThan(0));
    });
  });

  group('Fb2Parser — изображения', () {
    // «QUJD» (base64) = «ABC» (3 байта) — валидный binary для резолва.
    const imgFb2 = '''
<FictionBook xmlns:l="http://www.w3.org/1999/xlink">
<body><section><title><p>С картинкой</p></title>
<image l:href="#pic1.jpg"/>
<p>Текст после картинки.</p>
</section></body>
<binary id="pic1.jpg" content-type="image/jpeg">QUJD</binary>
</FictionBook>''';

    test('<image> + <binary> → ImageBlock создан и резолвится по id', () {
      final doc = Fb2Parser.parse(imgFb2, fallbackTitle: 'Книга');
      final blocks = doc.chapters.single.blocks;

      final image = blocks.whereType<ImageBlock>().single;
      expect(image.id, equals('pic1.jpg'));
      expect(image.bytes, equals('ABC'.codeUnits)); // QUJD → ABC
    });

    test('ImageBlock имеет charCount 0: вклад в символьный offset нулевой', () {
      final doc = Fb2Parser.parse(imgFb2, fallbackTitle: 'Книга');
      final chapter = doc.chapters.single;
      final image = chapter.blocks.whereType<ImageBlock>().single;
      final para = chapter.blocks.whereType<ParagraphBlock>().single;
      final heading = chapter.blocks.whereType<HeadingBlock>().first;

      // Сам блок-картинка не вносит символов (text пуст).
      expect(image.text, isEmpty);
      // plainText склеивается через '\n': heading + '\n' + '' + '\n' + para
      // ImageBlock = '', занимает только '\n'-разделитель, не добавляя символов.
      expect(chapter.plainText, contains(para.text));
      expect(chapter.plainText, contains(heading.text));
      final expectedChars =
          heading.text.length + 1 + // heading + '\n'
          0 + 1 + // ImageBlock.text.length==0 + '\n'
          para.text.length; // paragraph (последний, '\n' не добавляется)
      expect(chapter.charCount, equals(expectedChars));
    });

    test('незнакомый href и битый base64 — не кидает, блок пропущен', () {
      const fb2 = '''
<FictionBook xmlns:l="http://www.w3.org/1999/xlink">
<body><section><title><p>Г</p></title>
<image l:href="#missing.jpg"/>
<image l:href="#broken.jpg"/>
<p>Текст.</p>
</section></body>
<binary id="broken.jpg" content-type="image/jpeg">не-base64!!!</binary>
</FictionBook>''';
      final doc = Fb2Parser.parse(fb2, fallbackTitle: 'Книга');

      expect(doc.chapters.single.blocks.whereType<ImageBlock>(), isEmpty);
      expect(doc.chapters.single.plainText, contains('Текст.'));
    });
  });

  group('Fb2Parser — титульная глава', () {
    test('из title-info: обложка + название + автор первой главой', () {
      const fb2 = '''
<FictionBook xmlns:l="http://www.w3.org/1999/xlink">
<description><title-info>
<author><first-name>Ребекка</first-name><last-name>Яррос</last-name></author>
<book-title>Четвертое крыло</book-title>
<coverpage><image l:href="#cover.jpg"/></coverpage>
</title-info></description>
<body><section><title><p>Глава 1</p></title><p>Текст.</p></section></body>
<binary id="cover.jpg" content-type="image/jpeg">QUJD</binary>
</FictionBook>''';
      final doc = Fb2Parser.parse(fb2, fallbackTitle: 'Книга');

      final titlePage = doc.chapters.first;
      expect(titlePage.title, equals('Четвертое крыло'));
      expect(titlePage.blocks.whereType<ImageBlock>().single.id,
          equals('cover.jpg'));
      expect(titlePage.plainText, contains('Четвертое крыло'));
      expect(titlePage.plainText, contains('Ребекка Яррос'));
      // Реальная «Глава 1» идёт следом, не смешиваясь с титулом.
      expect(doc.chapters[1].title, equals('Глава 1'));
    });

    test('без title-info титульная глава не синтезируется', () {
      final doc = Fb2Parser.parse(_fb2, fallbackTitle: 'Книга');
      expect(doc.chapters.first.title, equals('Первая глава'));
    });
  });

  group('Fb2Parser — устойчивость', () {
    test('битый xml не кидает, возвращает документ с одной главой', () {
      final doc =
          Fb2Parser.parse('<FictionBook><body><sec', fallbackTitle: 'Битая');

      expect(doc.chapters, hasLength(1));
      expect(doc.chapters.first.title, equals('Битая'));
    });

    test('пустая строка не кидает', () {
      final doc = Fb2Parser.parse('', fallbackTitle: 'Пусто');

      expect(doc.chapters, hasLength(1));
      expect(doc.chapters.first.title, equals('Пусто'));
    });
  });
}
