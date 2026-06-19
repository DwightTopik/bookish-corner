import 'package:bookish_corner/features/reader/data/document/reader_document.dart';

/// Парсер plain-text → [ReaderDocument]: одна глава, абзацы режутся по пустым
/// строкам. File IO здесь нет — на вход уже прочитанная строка.
class TxtParser {
  const TxtParser._();

  static final RegExp _blankLine = RegExp(r'\n\s*\n');

  static ReaderDocument parse(String text, {required String title}) {
    final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final blocks = <ReaderBlock>[
      for (final raw in normalized.split(_blankLine))
        if (_collapse(raw).isNotEmpty) ParagraphBlock([ReaderRun(_collapse(raw))]),
    ];
    return ReaderDocument.fromChapters([
      ReaderChapter.fromBlocks(
        index: 0,
        title: title,
        depth: 0,
        blocks: blocks,
      ),
    ]);
  }

  /// Внутри абзаца переносы строк и лишние пробелы схлопываются в один пробел.
  static String _collapse(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();
}
