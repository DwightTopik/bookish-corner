import 'dart:convert';
import 'dart:typed_data';

import 'package:xml/xml.dart';

import 'package:bookish_corner/features/reader/data/document/reader_document.dart';

/// Fault-tolerant парсер fb2 → [ReaderDocument]. В духе
/// `book_metadata_extractor`: ничего не кидает наружу, на незнакомых/битых узлах
/// не падает. File IO здесь нет — на вход уже прочитанная строка (легко
/// юнит-тестировать синтетическими fixture'ами).
///
/// Структура глав берётся ИЗ ФАЙЛА: реальные «Глава N» приходят из собственных
/// `<title>` секций, а не из счётчика. Безымянные секции (front-matter:
/// копирайт, посвящение) НЕ нумеруются синтетически — у них нейтральный
/// фоллбэк-заголовок (по первым словам / пустой). `<binary>`/`<image>`
/// резолвятся в [ImageBlock] (нулевой вклад в символьный offset).
class Fb2Parser {
  const Fb2Parser._();

  /// `<emphasis>` → курсив, `<strong>` → жирный (с учётом вложенности).
  static const String _italicTag = 'emphasis';
  static const String _boldTag = 'strong';

  /// Макс. длина нейтрального заголовка-превью для безымянной секции.
  static const int _previewTitleMaxLen = 40;

  static ReaderDocument parse(String xml, {required String fallbackTitle}) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(xml);
    } catch (_) {
      return _fallback(xml, fallbackTitle);
    }

    final bodies = doc.findAllElements('body').toList();
    if (bodies.isEmpty) return _fallback(doc.innerText, fallbackTitle);

    final binaries = _collectBinaries(doc);
    final chapters = <ReaderChapter>[];

    // Часть C — титульная глава из title-info (обложка + название + автор).
    final titlePage = _titlePageChapter(doc, binaries, chapters.length);
    if (titlePage != null) chapters.add(titlePage);

    // Главный body (не notes) — top-level секции в плоский список глав.
    final mainBody = _mainBody(bodies);
    if (mainBody != null) {
      final topSections = mainBody.childElements
          .where((e) => e.name.local == 'section')
          .toList();
      if (topSections.isEmpty) {
        _walkSection(mainBody, 0, chapters, binaries);
      } else {
        for (final section in topSections) {
          _walkSection(section, 0, chapters, binaries);
        }
      }
    }

    // Прочие body (в т.ч. name="notes") — хвостовыми главами со своим <title>
    // («Примечания»). Footnote-определения становятся видимым разделом в конце.
    for (final body in bodies) {
      if (body == mainBody) continue;
      final chapter = _auxBodyChapter(body, binaries, chapters.length);
      if (chapter != null) chapters.add(chapter);
    }

    if (chapters.isEmpty) {
      return _fallback((mainBody ?? bodies.first).innerText, fallbackTitle);
    }
    return ReaderDocument.fromChapters(chapters);
  }

  /// Первый `<body>` без `name="notes"` (главный текст; сноски — отдельной
  /// хвостовой главой).
  static XmlElement? _mainBody(List<XmlElement> bodies) {
    for (final body in bodies) {
      if (body.getAttribute('name') != 'notes') return body;
    }
    return bodies.isEmpty ? null : bodies.first;
  }

  // --- Структура глав ------------------------------------------------------

  /// Добавляет [section] как главу и рекурсивно разворачивает вложенные секции
  /// в плоский список с возрастающим [depth].
  static void _walkSection(
    XmlElement section,
    int depth,
    List<ReaderChapter> out,
    Map<String, Uint8List> binaries,
  ) {
    final index = out.length;
    final title = _sectionTitle(section);
    final blocks = <ReaderBlock>[];

    // Заголовок главы (из <title>) вставляем первым блоком — отображается
    // крупным шрифтом на первой странице, как в референсе Readest.
    if (title.isNotEmpty) {
      blocks.add(HeadingBlock([ReaderRun(title)], 1));
    }

    _extractBlocks(section, blocks, binaries);

    out.add(
      ReaderChapter.fromBlocks(
        index: index,
        // НЕ синтезируем «Глава N»: реальные номера приходят из <title> файла,
        // безымянные секции получают нейтральный фоллбэк по первым словам.
        title: title.isNotEmpty ? title : _previewTitle(blocks),
        depth: depth,
        blocks: blocks,
      ),
    );

    for (final nested in section.childElements) {
      if (nested.name.local == 'section') {
        _walkSection(nested, depth + 1, out, binaries);
      }
    }
  }

  /// Вспомогательный body (notes и пр.) → одна хвостовая глава со своим
  /// `<title>`; секции внутри разворачиваются плоско (заголовок секции →
  /// [HeadingBlock]).
  static ReaderChapter? _auxBodyChapter(
    XmlElement body,
    Map<String, Uint8List> binaries,
    int index,
  ) {
    final title = _bodyTitle(body);
    final blocks = <ReaderBlock>[];
    // Прямой контент body вне секций (редко) — секции и title пропускаются.
    _extractBlocks(body, blocks, binaries);
    for (final section in body.childElements.where(
      (e) => e.name.local == 'section',
    )) {
      _appendSectionFlat(section, blocks, binaries);
    }
    if (blocks.isEmpty && title.isEmpty) return null;
    return ReaderChapter.fromBlocks(
      index: index,
      title: title.isNotEmpty ? title : _previewTitle(blocks),
      depth: 0,
      blocks: blocks,
    );
  }

  /// Секция + вложенные секции в один плоский список блоков (для хвостовых
  /// body): заголовок секции → [HeadingBlock], затем её контент.
  static void _appendSectionFlat(
    XmlElement section,
    List<ReaderBlock> out,
    Map<String, Uint8List> binaries,
  ) {
    final st = _sectionTitle(section);
    if (st.isNotEmpty) out.add(HeadingBlock([ReaderRun(st)], 2));
    _extractBlocks(section, out, binaries);
    for (final nested in section.childElements.where(
      (e) => e.name.local == 'section',
    )) {
      _appendSectionFlat(nested, out, binaries);
    }
  }

  /// Часть C — синтез титульной главы из `title-info`: обложка (#cover.jpg) +
  /// название книги + автор. Если ни обложки, ни названия нет — `null`.
  static ReaderChapter? _titlePageChapter(
    XmlDocument doc,
    Map<String, Uint8List> binaries,
    int index,
  ) {
    final infos = doc.findAllElements('title-info').toList();
    if (infos.isEmpty) return null;
    final info = infos.first;

    final blocks = <ReaderBlock>[];

    for (final cover in info.findElements('coverpage')) {
      for (final image in cover.findElements('image')) {
        final img = _imageBlock(image, binaries);
        if (img != null) {
          blocks.add(img);
          break;
        }
      }
    }

    final bookTitle = _normalize(info.getElement('book-title')?.innerText ?? '');
    if (bookTitle.isNotEmpty) {
      blocks.add(HeadingBlock([ReaderRun(bookTitle)], 1));
    }

    final author = _authorName(info);
    if (author.isNotEmpty) blocks.add(ParagraphBlock([ReaderRun(author)]));

    if (blocks.isEmpty) return null;
    return ReaderChapter.fromBlocks(
      index: index,
      title: bookTitle,
      depth: 0,
      blocks: blocks,
    );
  }

  static String _authorName(XmlElement info) {
    final author = info.getElement('author');
    if (author == null) return '';
    final parts = <String>[
      for (final tag in const ['first-name', 'middle-name', 'last-name'])
        _normalize(author.getElement(tag)?.innerText ?? ''),
    ].where((s) => s.isNotEmpty);
    return parts.join(' ');
  }

  // --- Блоки внутри секции -------------------------------------------------

  /// Разворачивает ПРЯМЫЕ блок-дети [element] в [out]: `p`/`subtitle`/`poem`/
  /// `cite`/`epigraph`/`text-author`/`image`. Вложенные `<section>` НЕ трогает
  /// (они становятся отдельными главами), `<title>`/`<empty-line>` пропускает.
  static void _extractBlocks(
    XmlElement element,
    List<ReaderBlock> out,
    Map<String, Uint8List> binaries,
  ) {
    for (final child in element.childElements) {
      switch (child.name.local) {
        case 'p':
          final runs = _runsOf(child);
          if (runs.isNotEmpty) out.add(ParagraphBlock(runs));
        case 'subtitle':
          final runs = _runsOf(child);
          if (runs.isNotEmpty) out.add(HeadingBlock(runs, 2));
        case 'text-author':
          final runs = _runsOf(child);
          if (runs.isNotEmpty) out.add(ParagraphBlock(runs));
        case 'poem':
          for (final stanza in child.findElements('stanza')) {
            for (final v in stanza.findElements('v')) {
              final runs = _runsOf(v);
              if (runs.isNotEmpty) out.add(ParagraphBlock(runs));
            }
          }
        case 'cite':
        case 'epigraph':
          // Контейнеры: разворачиваем их p/text-author/poem/image. Это чинит
          // «чёрный экран» там, где весь контент секции лежит в <epigraph>.
          _extractBlocks(child, out, binaries);
        case 'image':
          final img = _imageBlock(child, binaries);
          if (img != null) out.add(img);
        // title / section / annotation / empty-line и пр. — пропускаем.
      }
    }
  }

  // --- Заголовки -----------------------------------------------------------

  static String _sectionTitle(XmlElement section) {
    for (final child in section.childElements) {
      if (child.name.local == 'title') return _titleText(child);
    }
    return '';
  }

  static String _bodyTitle(XmlElement body) {
    for (final child in body.childElements) {
      if (child.name.local == 'title') return _titleText(child);
    }
    return '';
  }

  /// Робастная склейка текста `<title>`: несколько `<p>`, вложенные стили,
  /// `<empty-line/>` — собрать корректно (склейка через пробел + trim), не
  /// потерять.
  static String _titleText(XmlElement title) {
    final parts = <String>[];
    for (final node in title.childElements) {
      if (node.name.local == 'empty-line') continue;
      final t = _normalize(node.innerText);
      if (t.isNotEmpty) parts.add(t);
    }
    final joined = parts.join(' ').trim();
    if (joined.isNotEmpty) return joined;
    return _normalize(title.innerText);
  }

  /// Нейтральный заголовок для безымянной секции — первые слова первого
  /// абзаца (обрезка по границе слова), но НЕ «Глава N». Пусто, если текста нет
  /// (например image-only секция).
  static String _previewTitle(List<ReaderBlock> blocks) {
    for (final block in blocks) {
      if (block is! ParagraphBlock) continue;
      final text = _normalize(block.text);
      if (text.isEmpty) continue;
      if (text.length <= _previewTitleMaxLen) return text;
      final cut = text.substring(0, _previewTitleMaxLen);
      final lastSpace = cut.lastIndexOf(' ');
      final base = lastSpace > 0 ? cut.substring(0, lastSpace) : cut;
      return '$base…';
    }
    return '';
  }

  // --- Изображения ---------------------------------------------------------

  /// Все `<binary id=... >base64</binary>` → map {id → декодированные байты}.
  /// Битый base64 / без id — пропускаем молча (fault-tolerant).
  static Map<String, Uint8List> _collectBinaries(XmlDocument doc) {
    final map = <String, Uint8List>{};
    for (final bin in doc.findAllElements('binary')) {
      final id = bin.getAttribute('id');
      if (id == null || id.isEmpty) continue;
      try {
        final cleaned = bin.innerText.replaceAll(RegExp(r'\s+'), '');
        if (cleaned.isEmpty) continue;
        map[id] = base64.decode(cleaned);
      } catch (_) {
        // битый base64 — пропускаем
      }
    }
    return map;
  }

  /// `<image l:href="#id">` → [ImageBlock] по резолву id в [binaries].
  /// Незнакомый/битый href — `null` (молча).
  static ImageBlock? _imageBlock(
    XmlElement image,
    Map<String, Uint8List> binaries,
  ) {
    final href = _resolveHref(image);
    if (href == null) return null;
    final bytes = binaries[href];
    if (bytes == null) return null;
    return ImageBlock(id: href, bytes: bytes);
  }

  /// `l:href` без привязки к namespace-префиксу: ищем атрибут с local `href`,
  /// обрезаем ведущий `#`.
  static String? _resolveHref(XmlElement image) {
    for (final attr in image.attributes) {
      if (attr.name.local != 'href') continue;
      String value = attr.value.trim();
      if (value.startsWith('#')) value = value.substring(1);
      return value.isEmpty ? null : value;
    }
    return null;
  }

  // --- Раны / текст --------------------------------------------------------

  /// Раны инлайн-элемента с наследованием начертания по вложенности.
  static List<ReaderRun> _runsOf(
    XmlElement element, {
    bool bold = false,
    bool italic = false,
  }) {
    final runs = <ReaderRun>[];
    for (final node in element.children) {
      if (node is XmlText || node is XmlCDATA) {
        // Схлопываем пробелы, но НЕ тримим: пробел между ранами значим.
        final text = _collapseWs(node.value ?? '');
        if (text.isNotEmpty) {
          runs.add(ReaderRun(text, bold: bold, italic: italic));
        }
      } else if (node is XmlElement) {
        final local = node.name.local;
        runs.addAll(
          _runsOf(
            node,
            bold: bold || local == _boldTag,
            italic: italic || local == _italicTag,
          ),
        );
      }
    }
    return runs;
  }

  /// Схлопывает пробельные последовательности (переносы/отступы форматирования
  /// fb2) в один пробел и тримит — для заголовков и fallback-текста.
  static String _normalize(String s) => _collapseWs(s).trim();

  /// Схлопывает пробельные последовательности в один пробел БЕЗ трима —
  /// для текста ранов, где пробел на границе с соседним раном значим.
  static String _collapseWs(String s) => s.replaceAll(RegExp(r'\s+'), ' ');

  static ReaderDocument _fallback(String raw, String fallbackTitle) {
    final text = _normalize(raw);
    final blocks = <ReaderBlock>[
      if (text.isNotEmpty) ParagraphBlock([ReaderRun(text)]),
    ];
    return ReaderDocument.fromChapters([
      ReaderChapter.fromBlocks(
        index: 0,
        title: fallbackTitle,
        depth: 0,
        blocks: blocks,
      ),
    ]);
  }
}
