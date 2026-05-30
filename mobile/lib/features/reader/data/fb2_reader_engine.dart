import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;

import 'package:bookish_corner/features/library/domain/book_format.dart';
import 'package:bookish_corner/features/reader/data/document/fb2_parser.dart';
import 'package:bookish_corner/features/reader/data/document/reader_document.dart';
import 'package:bookish_corner/features/reader/data/document/txt_parser.dart';
import 'package:bookish_corner/features/reader/data/fb2_render_controller.dart';
import 'package:bookish_corner/features/reader/domain/reader_capabilities.dart';
import 'package:bookish_corner/features/reader/domain/reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';
import 'package:bookish_corner/features/reader/domain/reader_progress.dart';
import 'package:bookish_corner/features/reader/domain/reader_search_result.dart';
import 'package:bookish_corner/features/reader/domain/reader_selection.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/domain/toc_entry.dart';

/// [ReaderEngine] для текстовых форматов (fb2/txt). Headless-часть (B1a): парсит
/// файл в [ReaderDocument] и ведёт позицию по СИМВОЛЬНОМУ смещению
/// (шрифт-независимо, без рендера). Постраничная вёрстка/перелистывание —
/// задача B1b, ими владеет вью через [Fb2RenderController] (движок — мост).
///
/// В A1-seam (`readerEngineProvider`) пока не подключён: остаётся
/// `FakeReaderEngine`, фабрика по формату появится в B1b. Тестируется напрямую.
class Fb2ReaderEngine implements ReaderEngine {
  Fb2ReaderEngine({
    required this.filePath,
    required this.format,
    this.fallbackTitle,
  }) {
    _render.addListener(_onRenderMetrics);
  }

  final String filePath;
  final BookFormat format;

  /// Заголовок книги из метаданных — заголовок единственной главы для txt и
  /// fallback при битом fb2. Если `null` — берётся из имени файла.
  final String? fallbackTitle;

  static const int _excerptRadius = 40;

  final StreamController<ReaderProgress> _progress =
      StreamController<ReaderProgress>.broadcast();
  final StreamController<ReaderSelection> _selection =
      StreamController<ReaderSelection>.broadcast();
  final Fb2RenderController _render = Fb2RenderController();

  ReaderDocument _document = ReaderDocument.fromChapters(const []);
  // Декодированные картинки по id <binary>. Пред-декод на open(): пагинация
  // (вью) получает натуральные w/h синхронно. Освобождаются в dispose().
  // TODO(reader): для очень тяжёлых книг — ленивый декод видимых с eviction.
  final Map<String, ui.Image> _images = <String, ui.Image>{};
  List<TocEntry> _toc = const [];
  ReaderLocator _locator = const ReaderLocator(
    progress: 0,
    anchor: '0:0',
    chapterIndex: 0,
  );
  ReaderSettings _settings = const ReaderSettings();
  bool _opened = false;
  bool _disposed = false;

  @override
  ReaderCapabilities get capabilities => const .new(
    supportsFontResize: true,
    supportsThemeColors: true,
    supportsScrollMode: true,
    supportsTextSelection: true,
    supportsHighlights: true,
    supportsSearch: true,
  );

  @override
  Stream<ReaderProgress> get progress => _progress.stream;

  @override
  Stream<ReaderSelection> get selection => _selection.stream;

  @override
  List<TocEntry> get toc => _toc;

  /// Текущие настройки (читаются вьюхой в B1b для вёрстки).
  ReaderSettings get settings => _settings;

  /// Распарсенный документ — вью верстает по нему страницы.
  ReaderDocument get document => _document;

  /// Декодированные картинки по id `<binary>` — вью рисует их в пагинации.
  Map<String, ui.Image> get images => _images;

  /// Мост к вью: вью выставляет хуки и репортит позицию/page-метрики.
  Fb2RenderController get renderController => _render;

  @override
  Future<void> open() async {
    if (_opened) return;
    _opened = true;
    final raw = await _readFile();
    _document = _parse(raw);
    await _decodeImages();
    _toc = _buildToc();
    _locator = const ReaderLocator(progress: 0, anchor: '0:0', chapterIndex: 0);
    _emit();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _render.removeListener(_onRenderMetrics);
    _render.dispose();
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
    await _progress.close();
    await _selection.close();
  }

  /// Пред-декод всех уникальных [ImageBlock] документа в `ui.Image` (по id
  /// `<binary>`). Битые байты — пропускаем молча (fault-tolerant). Так
  /// пагинация во вью получает натуральные w/h синхронно.
  Future<void> _decodeImages() async {
    for (final chapter in _document.chapters) {
      for (final block in chapter.blocks) {
        if (block is! ImageBlock || _images.containsKey(block.id)) continue;
        try {
          final codec = await ui.instantiateImageCodec(block.bytes);
          final frame = await codec.getNextFrame();
          _images[block.id] = frame.image;
        } catch (_) {
          // незагружаемая картинка — без неё, блок просто не отрисуется
        }
      }
    }
  }

  @override
  Future<void> goTo(ReaderLocator locator) async {
    final (int chapterIndex, int offset) = locator.anchor.isEmpty
        ? _resolveByProgress(locator.progress)
        : _parseAnchor(locator.anchor);
    _setLocator(chapterIndex, offset);
    _emit();
    // Просим смонтированную вью перебросить на страницу с этим offset; headless
    // (onJump == null) — no-op, позиция уже выставлена выше.
    _render.jumpToOffset(chapterIndex, offset);
  }

  @override
  Future<void> nextPage() async => _render.next();

  @override
  Future<void> prevPage() async => _render.prev();

  @override
  Future<List<ReaderSearchResult>> search(String query) async {
    if (query.isEmpty) return const [];
    final lowerQuery = query.toLowerCase();
    final before = _document.charsBeforeChapter;
    final results = <ReaderSearchResult>[];
    for (final chapter in _document.chapters) {
      final ReaderChapter(:plainText, :index, :title) = chapter;
      final haystack = plainText.toLowerCase();
      int start = haystack.indexOf(lowerQuery);
      while (start >= 0) {
        final globalOffset = before[index] + start;
        final position = _progressForOffset(globalOffset);
        final (String excerpt, int matchStart) = _excerpt(
          plainText,
          start,
          query.length,
        );
        results.add(
          ReaderSearchResult(
            chapterTitle: title,
            excerpt: excerpt,
            matchStart: matchStart,
            matchLength: query.length,
            progress: position,
            anchor: ReaderLocator(
              progress: position,
              anchor: '$index:$start',
              chapterIndex: index,
            ),
          ),
        );
        start = haystack.indexOf(lowerQuery, start + query.length);
      }
    }
    return results;
  }

  @override
  Future<void> applySettings(ReaderSettings settings) async {
    _settings = settings;
    // Реальная ре-вёрстка — B1b; здесь только сигнал вьюхе через контроллер.
    _render.relayout();
  }

  // --- Внутреннее ---------------------------------------------------------

  void _onRenderMetrics() {
    // Вью отрепортила позицию — пересобираем локатор из символьного offset.
    final ci = _render.chapterIndex;
    final co = _render.charOffset;
    if (ci != null && co != null) _setLocator(ci, co);
    _emit();
  }

  void _emit() {
    if (_disposed) return;
    final ci = _locator.chapterIndex;
    final chapterTitle =
        ci != null && ci < _toc.length ? _toc[ci].title : null;
    _progress.add(
      ReaderProgress(
        locator: _locator,
        currentPage: _render.currentPage,
        totalPages: _render.totalPages,
        pagesToNextChapter: _render.pagesToNextChapter,
        chapterTitle: chapterTitle?.isNotEmpty == true ? chapterTitle : null,
      ),
    );
  }

  Future<String> _readFile() async {
    final file = File(filePath);
    try {
      return await file.readAsString();
    } catch (_) {
      try {
        final bytes = await file.readAsBytes();
        return latin1.decode(bytes, allowInvalid: true);
      } catch (_) {
        return '';
      }
    }
  }

  ReaderDocument _parse(String raw) {
    final title = (fallbackTitle?.trim().isNotEmpty ?? false)
        ? fallbackTitle!.trim()
        : p.basenameWithoutExtension(filePath);
    return switch (format) {
      .fb2 => Fb2Parser.parse(raw, fallbackTitle: title),
      .txt => TxtParser.parse(raw, title: title),
      _ => TxtParser.parse(raw, title: title),
    };
  }

  List<TocEntry> _buildToc() {
    return [
      for (final ReaderChapter(:id, :title, :index, :depth) in _document.chapters)
        TocEntry(
          id: id,
          title: title,
          index: index,
          depth: depth,
          anchor: _chapterLocator(index),
          startProgress: _progressForOffset(
            _document.charsBeforeChapter[index],
          ),
        ),
    ];
  }

  ReaderLocator _chapterLocator(int chapterIndex) {
    return ReaderLocator(
      progress: _progressForOffset(_document.charsBeforeChapter[chapterIndex]),
      anchor: '$chapterIndex:0',
      chapterIndex: chapterIndex,
    );
  }

  void _setLocator(int chapterIndex, int offset) {
    final globalOffset = _document.charsBeforeChapter[chapterIndex] + offset;
    _locator = ReaderLocator(
      progress: _progressForOffset(globalOffset),
      anchor: '$chapterIndex:$offset',
      chapterIndex: chapterIndex,
    );
  }

  double _progressForOffset(int globalOffset) {
    final total = _document.totalChars;
    if (total <= 0) return 0;
    return (globalOffset / total).clamp(0.0, 1.0);
  }

  /// Пустой anchor → позиция по progress: целевой глобальный offset → глава +
  /// смещение внутри неё.
  (int, int) _resolveByProgress(double progress) {
    final total = _document.totalChars;
    if (total <= 0 || _document.chapters.isEmpty) return (0, 0);
    final before = _document.charsBeforeChapter;
    final target = (progress.clamp(0.0, 1.0) * total).round().clamp(0, total);
    int chapterIndex = 0;
    for (int i = 0; i < before.length; i++) {
      if (before[i] <= target) {
        chapterIndex = i;
      } else {
        break;
      }
    }
    final offset = (target - before[chapterIndex]).clamp(
      0,
      _document.chapters[chapterIndex].charCount,
    );
    return (chapterIndex, offset);
  }

  /// `"i:offset"` → пара (глава, смещение) с clamp в границы; кривой anchor → 0:0.
  (int, int) _parseAnchor(String anchor) {
    final parts = anchor.split(':');
    if (parts.length == 2) {
      final index = int.tryParse(parts[0]);
      final offset = int.tryParse(parts[1]);
      if (index != null &&
          offset != null &&
          index >= 0 &&
          index < _document.chapters.length) {
        final clamped = offset.clamp(0, _document.chapters[index].charCount);
        return (index, clamped);
      }
    }
    return (0, 0);
  }

  (String, int) _excerpt(String text, int matchStart, int matchLength) {
    final from = (matchStart - _excerptRadius).clamp(0, text.length);
    final to = (matchStart + matchLength + _excerptRadius).clamp(0, text.length);
    return (text.substring(from, to), matchStart - from);
  }
}
