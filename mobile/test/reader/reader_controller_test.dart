import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bookish_corner/core/di/app_preferences_provider.dart';
import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/book_format.dart';
import 'package:bookish_corner/features/reader/domain/reader_capabilities.dart';
import 'package:bookish_corner/features/reader/domain/reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';
import 'package:bookish_corner/features/reader/domain/reader_progress.dart';
import 'package:bookish_corner/features/reader/domain/reader_search_result.dart';
import 'package:bookish_corner/features/reader/domain/reader_selection.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/domain/toc_entry.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_book_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_ui_state.dart';

const _bookId = 'book-1';

final _epubBook = Book(
  id: _bookId,
  title: 'Тест',
  author: 'Автор',
  filePath: '/tmp/book.epub',
  format: BookFormat.epub,
  addedAt: DateTime(2026),
);

/// Прокачивает event loop: два цикла, чтобы дать Riverpod время завершить
/// rebuild-цепочку (stream → providerUpdate → build → _open → open.future).
Future<void> pump() async {
  await Future.delayed(.zero);
  await Future.delayed(.zero);
}

/// Собирает контейнер с фейком-движком, возвращающим epub-книгу из
/// readerBookProvider. Тип epub → readerEngineFactoryProvider возвращает
/// FakeReaderEngine, но мы переопределяем фабрику на recording-движок.
ProviderContainer _makeContainer(
  _RecordingEngine engine,
  SharedPreferences prefs,
) {
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      readerBookProvider.overrideWith((ref, bookId) => Stream.value(_epubBook)),
      readerEngineFactoryProvider.overrideWith(
        (ref) =>
            (_) => engine,
      ),
    ],
  );
  final sub = container.listen(readerControllerProvider(_bookId), (_, _) {});
  addTearDown(sub.close);
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReaderController', () {
    late ProviderContainer container;
    late _RecordingEngine engine;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      engine = _RecordingEngine();
      container = _makeContainer(engine, prefs);
    });

    ReaderUiState state() => container.read(readerControllerProvider(_bookId));
    ReaderControllerNotifier notifier() =>
        container.read(readerControllerProvider(_bookId).notifier);

    test(
      'после open переходит в ready с непустым TOC и стартовой позицией',
      () async {
        await pump();

        expect(state().status, equals(ReaderStatus.ready));
        expect(state().toc, isEmpty); // RecordingEngine.toc == []
        expect(state().progress, isNotNull);
        expect(state().progress!.currentPage, equals(1));
      },
    );

    test('toggleChrome инвертирует видимость chrome', () async {
      await pump();
      expect(state().chromeVisible, isTrue);

      notifier().toggleChrome();
      expect(state().chromeVisible, isFalse);

      notifier().toggleChrome();
      expect(state().chromeVisible, isTrue);
    });

    test('nextPage / prevPage делегируются движку', () async {
      await pump();

      await notifier().nextPage();
      await pump();
      expect(engine.nextCalled, isTrue);

      await notifier().prevPage();
      await pump();
      expect(engine.prevCalled, isTrue);
    });

    test('seekTo резолвит позицию по progress (пустой anchor)', () async {
      await pump();

      await notifier().seekTo(0.5);
      await pump();

      expect(engine.lastGoTo?.progress, equals(0.5));
      expect(engine.lastGoTo?.anchor, equals(''));
    });

    test('updateSettings немедленно отражается в состоянии', () async {
      await pump();

      const next = ReaderSettings(fontSizeStep: 3, lineSpacingStep: 2);
      await notifier().updateSettings(next);

      expect(state().settings.fontSizeStep, equals(3));
      expect(state().settings.lineSpacingStep, equals(2));
    });
  });

  group('readerEngineFactoryProvider seam', () {
    late SharedPreferences seamPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      seamPrefs = await SharedPreferences.getInstance();
    });

    test('остаётся в loading, пока open() движка не завершён', () async {
      final gate = Completer<void>();
      final engine = _RecordingEngine(openGate: gate);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(seamPrefs),
          readerBookProvider.overrideWith(
            (ref, bookId) => Stream.value(_epubBook),
          ),
          readerEngineFactoryProvider.overrideWith(
            (ref) =>
                (_) => engine,
          ),
        ],
      );
      final sub = container.listen(
        readerControllerProvider(_bookId),
        (_, _) {},
      );
      addTearDown(sub.close);
      addTearDown(container.dispose);

      await pump();
      expect(
        container.read(readerControllerProvider(_bookId)).status,
        equals(ReaderStatus.loading),
      );

      gate.complete();
      await pump();
      expect(
        container.read(readerControllerProvider(_bookId)).status,
        equals(ReaderStatus.ready),
      );
    });

    test(
      'ре-эмит той же книги не пересобирает движок (open ровно один раз)',
      () async {
        final engine = _RecordingEngine();
        final bookCtrl = StreamController<Book?>.broadcast();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(seamPrefs),
            readerBookProvider.overrideWith((ref, bookId) => bookCtrl.stream),
            readerEngineFactoryProvider.overrideWith(
              (ref) =>
                  (_) => engine,
            ),
          ],
        );
        final sub = container.listen(
          readerControllerProvider(_bookId),
          (_, _) {},
        );
        addTearDown(sub.close);
        addTearDown(container.dispose);
        addTearDown(bookCtrl.close);

        bookCtrl.add(_epubBook);
        await pump();
        expect(engine.openCount, equals(1));
        expect(
          container.read(readerControllerProvider(_bookId)).status,
          equals(ReaderStatus.ready),
        );

        // Тот же файл/формат/заголовок — провайдер движка не пересобирается.
        bookCtrl.add(_epubBook.copyWith(coverUrl: 'https://x/cover.jpg'));
        await pump();
        bookCtrl.add(_epubBook.copyWith(readingProgress: 0.5));
        await pump();

        expect(
          engine.openCount,
          equals(1),
          reason: 'open() не должен повторяться',
        );
        expect(
          engine.disposed,
          isFalse,
          reason: 'движок должен остаться живым',
        );
        expect(
          container.read(readerControllerProvider(_bookId)).status,
          equals(ReaderStatus.ready),
        );
      },
    );

    test(
      'override подменяет фабрику, контроллер делегирует ему intent-ы',
      () async {
        final engine = _RecordingEngine();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(seamPrefs),
            readerBookProvider.overrideWith(
              (ref, bookId) => Stream.value(_epubBook),
            ),
            readerEngineFactoryProvider.overrideWith(
              (ref) =>
                  (_) => engine,
            ),
          ],
        );
        final sub = container.listen(
          readerControllerProvider(_bookId),
          (_, _) {},
        );
        addTearDown(sub.close);
        addTearDown(container.dispose);

        await pump();
        expect(engine.openCalled, isTrue);
        expect(
          container.read(readerControllerProvider(_bookId)).status,
          equals(ReaderStatus.ready),
        );

        final notifier = container.read(
          readerControllerProvider(_bookId).notifier,
        );
        await notifier.nextPage();
        await pump();
        await notifier.prevPage();
        await pump();
        await notifier.seekTo(0.3);
        await pump();

        final _RecordingEngine(:nextCalled, :prevCalled, :lastGoTo) = engine;
        expect(nextCalled, isTrue);
        expect(prevCalled, isTrue);
        expect(lastGoTo?.anchor, equals(''));
        expect(lastGoTo?.progress, equals(0.3));
      },
    );
  });
}

/// Записывающий тест-дубль — доказывает swap-ability seam и факт делегирования.
class _RecordingEngine implements ReaderEngine {
  _RecordingEngine({this.openGate});

  final Completer<void>? openGate;

  final StreamController<ReaderProgress> _progress =
      StreamController<ReaderProgress>.broadcast();
  final StreamController<ReaderSelection> _selection =
      StreamController<ReaderSelection>.broadcast();

  bool openCalled = false;
  int openCount = 0;
  bool disposed = false;
  bool nextCalled = false;
  bool prevCalled = false;
  ReaderLocator? lastGoTo;

  @override
  ReaderCapabilities get capabilities => const .new(
    supportsFontResize: false,
    supportsThemeColors: false,
    supportsScrollMode: false,
    supportsTextSelection: false,
    supportsHighlights: false,
    supportsSearch: false,
  );

  @override
  Stream<ReaderProgress> get progress => _progress.stream;

  @override
  Stream<ReaderSelection> get selection => _selection.stream;

  @override
  List<TocEntry> get toc => const [];

  @override
  Future<void> open() async {
    openCalled = true;
    openCount++;
    final gate = openGate;
    if (gate != null) await gate.future;
    _progress.add(
      const ReaderProgress(
        locator: ReaderLocator(progress: 0, anchor: 'page:1', chapterIndex: 0),
        currentPage: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _progress.close();
    await _selection.close();
  }

  @override
  Future<void> goTo(ReaderLocator locator) async => lastGoTo = locator;

  @override
  Future<void> nextPage() async => nextCalled = true;

  @override
  Future<void> prevPage() async => prevCalled = true;

  @override
  Future<List<ReaderSearchResult>> search(String query) async => const [];

  @override
  Future<void> applySettings(ReaderSettings settings) async {}
}
