// Headless-модель распарсенного текстового документа (fb2/txt) — чистый Dart,
// шрифт- и вьюпорт-независимая. Позиция в книге считается по СИМВОЛЬНОМУ
// смещению (без рендера): anchor = "chapterIndex:charOffset", где charOffset —
// смещение в ReaderChapter.plainText. Рендер и пагинация — задача B1b.

import 'dart:typed_data';

/// Инлайн-фрагмент текста с признаками начертания.
class ReaderRun {
  const ReaderRun(this.text, {this.bold = false, this.italic = false});

  final String text;
  final bool bold;
  final bool italic;
}

/// Блок текста главы. Sealed — рендер (B1b) исчерпывающе матчит варианты.
sealed class ReaderBlock {
  const ReaderBlock(this.runs);

  final List<ReaderRun> runs;

  /// Plain-text блока = конкатенация текста его ранов (без разделителей).
  String get text => runs.map((r) => r.text).join();
}

/// Обычный абзац.
class ParagraphBlock extends ReaderBlock {
  const ParagraphBlock(super.runs);
}

/// Подзаголовок внутри главы (`<subtitle>` и т.п.). [level] — семантический
/// уровень (2 для fb2-subtitle).
class HeadingBlock extends ReaderBlock {
  const HeadingBlock(super.runs, this.level);

  final int level;
}

/// Блочное изображение (`<image>` → `<binary>`). Без ранов: [text] = `''`, а
/// значит вклад в `plainText`/charCount — НУЛЕВОЙ. Так символьные offset'ы
/// поиска и страниц не плывут от наличия картинок. [id] — id `<binary>` (для
/// резолва декодированного `ui.Image` во вью), [bytes] — сырые байты картинки
/// (декод в `ui.Image` — забота Flutter-слоя, не чистой модели).
class ImageBlock extends ReaderBlock {
  const ImageBlock({required this.id, required this.bytes}) : super(const []);

  final String id;
  final Uint8List bytes;
}

/// Одна глава документа. [plainText] — источник правды для поиска и
/// символьного offset; строится той же фабрикой, что собирает [blocks], чтобы
/// offset был с ним согласован.
class ReaderChapter {
  const ReaderChapter({
    required this.id,
    required this.title,
    required this.index,
    required this.depth,
    required this.blocks,
    required this.plainText,
  });

  /// Собирает главу из блоков, выводя [plainText] детерминированно: текст блоков
  /// соединяется `'\n'`.
  factory ReaderChapter.fromBlocks({
    required int index,
    required String title,
    required int depth,
    required List<ReaderBlock> blocks,
  }) {
    final plainText = blocks.map((b) => b.text).join('\n');
    return ReaderChapter(
      id: '$index',
      title: title,
      index: index,
      depth: depth,
      blocks: blocks,
      plainText: plainText,
    );
  }

  /// Стабильный идентификатор (= индекс главы строкой).
  final String id;
  final String title;
  final int index;

  /// Вложенность fb2-section (для [TocEntry.depth]).
  final int depth;
  final List<ReaderBlock> blocks;
  final String plainText;

  int get charCount => plainText.length;
}

/// Документ целиком + агрегаты, нужные для offset↔progress математики.
class ReaderDocument {
  const ReaderDocument({
    required this.chapters,
    required this.totalChars,
    required this.charsBeforeChapter,
  });

  /// Считает агрегаты один раз: [totalChars] и префикс-суммы
  /// [charsBeforeChapter] (символов во всех главах до главы i).
  factory ReaderDocument.fromChapters(List<ReaderChapter> chapters) {
    final before = <int>[];
    int running = 0;
    for (final chapter in chapters) {
      before.add(running);
      running += chapter.charCount;
    }
    return ReaderDocument(
      chapters: chapters,
      totalChars: running,
      charsBeforeChapter: before,
    );
  }

  final List<ReaderChapter> chapters;

  /// Суммарное число символов по всем главам (знаменатель прогресса).
  final int totalChars;

  /// `charsBeforeChapter[i]` — символов во всех главах до i-й.
  final List<int> charsBeforeChapter;
}
