import 'dart:async';

import 'package:bookish_corner/features/reader/domain/reader_capabilities.dart';
import 'package:bookish_corner/features/reader/domain/reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';
import 'package:bookish_corner/features/reader/domain/reader_progress.dart';
import 'package:bookish_corner/features/reader/domain/reader_search_result.dart';
import 'package:bookish_corner/features/reader/domain/reader_selection.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/domain/toc_entry.dart';

/// Внутреннее описание синтетической главы фейк-движка.
class _FakeChapter {
  const _FakeChapter({
    required this.index,
    required this.title,
    required this.startPage,
    required this.pageCount,
    required this.body,
  });

  final int index;
  final String title;

  /// Первая страница главы (1-based, по всей книге).
  final int startPage;
  final int pageCount;
  final String body;
}

/// Детерминированная реализация [ReaderEngine] без реального файла — нужна,
/// чтобы контроллер и chrome (B2) тестировались до появления настоящих движков
/// (B/C). Выбор реального движка по формату появится позже через фабрику; в A1
/// этот фейк отдаётся через `readerEngineProvider` (DI-swap seam).
class FakeReaderEngine implements ReaderEngine {
  FakeReaderEngine();

  static const List<_FakeChapter> _chapters = [
    _FakeChapter(
      index: 0,
      title: 'Глава 1. Начало',
      startPage: 1,
      pageCount: 3,
      body: 'Это начало книги. Здесь встречается слово поиск для теста.',
    ),
    _FakeChapter(
      index: 1,
      title: 'Глава 2. Развитие',
      startPage: 4,
      pageCount: 4,
      body: 'Сюжет развивается. Ещё одно совпадение поиск во второй главе.',
    ),
    _FakeChapter(
      index: 2,
      title: 'Глава 3. Кульминация',
      startPage: 8,
      pageCount: 2,
      body: 'Напряжение нарастает к развязке истории.',
    ),
    _FakeChapter(
      index: 3,
      title: 'Глава 4. Финал',
      startPage: 10,
      pageCount: 3,
      body: 'Все линии сходятся. Слово поиск встречается в финале.',
    ),
  ];

  static const int _totalPages = 12;

  final StreamController<ReaderProgress> _progressController =
      StreamController<ReaderProgress>.broadcast();
  final StreamController<ReaderSelection> _selectionController =
      StreamController<ReaderSelection>.broadcast();

  late final List<TocEntry> _toc = [
    for (final _FakeChapter(:index, :title, :startPage) in _chapters)
      TocEntry(
        id: 'chapter-$index',
        title: title,
        index: index,
        depth: 0,
        anchor: ReaderLocator(
          progress: _progressForPage(startPage),
          anchor: 'page:$startPage',
          chapterIndex: index,
        ),
        startProgress: _progressForPage(startPage),
      ),
  ];

  int _currentPage = 1;
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
  Stream<ReaderProgress> get progress => _progressController.stream;

  @override
  Stream<ReaderSelection> get selection => _selectionController.stream;

  @override
  List<TocEntry> get toc => _toc;

  @override
  Future<void> open() async {
    if (_opened) return;
    _opened = true;
    _currentPage = 1;
    _emit();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _progressController.close();
    await _selectionController.close();
  }

  @override
  Future<void> goTo(ReaderLocator locator) async {
    final page = locator.anchor.isEmpty
        ? (locator.progress * (_totalPages - 1)).round() + 1
        : _pageFromAnchor(locator.anchor);
    _currentPage = page.clamp(1, _totalPages);
    _emit();
  }

  @override
  Future<void> nextPage() async {
    if (_currentPage >= _totalPages) return;
    _currentPage++;
    _emit();
  }

  @override
  Future<void> prevPage() async {
    if (_currentPage <= 1) return;
    _currentPage--;
    _emit();
  }

  @override
  Future<List<ReaderSearchResult>> search(String query) async {
    if (query.isEmpty) return const [];
    final lower = query.toLowerCase();
    final results = <ReaderSearchResult>[];
    for (final _FakeChapter(:index, :title, :startPage, :body) in _chapters) {
      final matchStart = body.toLowerCase().indexOf(lower);
      if (matchStart < 0) continue;
      results.add(
        ReaderSearchResult(
          chapterTitle: title,
          excerpt: body,
          matchStart: matchStart,
          matchLength: query.length,
          progress: _progressForPage(startPage),
          anchor: ReaderLocator(
            progress: _progressForPage(startPage),
            anchor: 'page:$startPage',
            chapterIndex: index,
          ),
        ),
      );
    }
    return results;
  }

  @override
  Future<void> applySettings(ReaderSettings settings) async {
    // Фейк ничего не рендерит — chrome-тестам важен сам факт делегирования.
  }

  void _emit() {
    if (_disposed) return;
    final chapter = _chapterForPage(_currentPage);
    _progressController.add(
      ReaderProgress(
        locator: ReaderLocator(
          progress: _progressForPage(_currentPage),
          anchor: 'page:$_currentPage',
          chapterIndex: chapter.index,
        ),
        currentPage: _currentPage,
        totalPages: _totalPages,
        pagesToNextChapter: _pagesToNextChapter(_currentPage, chapter),
      ),
    );
  }

  static double _progressForPage(int page) => (page - 1) / (_totalPages - 1);

  static _FakeChapter _chapterForPage(int page) {
    for (final chapter in _chapters.reversed) {
      if (page >= chapter.startPage) return chapter;
    }
    return _chapters.first;
  }

  static int? _pagesToNextChapter(int page, _FakeChapter chapter) {
    final nextIndex = chapter.index + 1;
    if (nextIndex >= _chapters.length) return null;
    return _chapters[nextIndex].startPage - page;
  }

  static int _pageFromAnchor(String anchor) {
    final parts = anchor.split(':');
    if (parts.length == 2 && parts.first == 'page') {
      return int.tryParse(parts[1]) ?? 1;
    }
    return 1;
  }
}
