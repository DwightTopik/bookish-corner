import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bookish_corner/core/database/app_database.dart' hide ReaderProgress;
import 'package:bookish_corner/core/di/app_preferences_provider.dart';
import 'package:bookish_corner/core/di/database_provider.dart';
import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/reader/domain/reader_bookmark.dart';
import 'package:bookish_corner/features/reader/domain/reader_bookmark_repository.dart';
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

const _bookId = 'bk-d2';

final _testBook = Book(
  id: _bookId,
  title: 'D2 Test Book',
  author: 'Test',
  filePath: '/tmp/d2.fb2',
  format: .epub,
  addedAt: .utc(2026),
);

AppDatabase _openDb() => .new(
  NativeDatabase.memory(
    setup: (rawDb) => rawDb.execute('PRAGMA foreign_keys = ON'),
  ),
);

Future<void> _insertBook(AppDatabase db, String id) async {
  await db.into(db.books).insert(
    BooksCompanion.insert(
      id: id,
      title: 'D2 Test Book',
      author: 'Test',
      filePath: '/tmp/d2.fb2',
      format: 'epub',
      addedAt: DateTime(2026),
    ),
  );
}

Future<void> pump() async {
  await Future.delayed(Duration.zero);
  await Future.delayed(Duration.zero);
}

ProviderContainer _makeContainer(AppDatabase db, SharedPreferences prefs) {
  final engine = _BookmarkTestEngine();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWith((ref) {
        ref.onDispose(db.close);
        return db;
      }),
      readerBookProvider.overrideWith((ref, bookId) => Stream.value(_testBook)),
      readerEngineFactoryProvider.overrideWith((ref) => (_) => engine),
    ],
  );
  final sub = container.listen(readerControllerProvider(_bookId), (_, _) {});
  addTearDown(sub.close);
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('D2 — bookmark toggle', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      db = _openDb();
      await _insertBook(db, _bookId);
      container = _makeContainer(db, prefs);
    });

    ReaderUiState state() => container.read(readerControllerProvider(_bookId));
    ReaderControllerNotifier notifier() =>
        container.read(readerControllerProvider(_bookId).notifier);
    ReaderBookmarkRepository repo() =>
        container.read(readerBookmarkRepositoryProvider);

    test('toggleBookmark → isBookmarked true, запись в БД есть', () async {
      await pump();
      expect(state().status, equals(ReaderStatus.ready));
      expect(state().isBookmarked, isFalse);

      await notifier().toggleBookmark();
      await pump();

      expect(state().isBookmarked, isTrue);
      final rows = await db.select(db.readerBookmarks).get();
      expect(rows, hasLength(1));
    });

    test('повторный toggleBookmark → isBookmarked false, запись удалена',
        () async {
      await pump();
      await notifier().toggleBookmark();
      await pump();
      expect(state().isBookmarked, isTrue);

      await notifier().toggleBookmark();
      await pump();

      expect(state().isBookmarked, isFalse);
      expect(await db.select(db.readerBookmarks).get(), isEmpty);
    });

    test('watchBookmarks эмитит изменение после toggle', () async {
      await pump();

      // Подписываемся ДО toggle, чтобы поймать эмиссию после DB-записи.
      final expectation = expectLater(
        repo().watchBookmarks(_bookId),
        emitsThrough(predicate<List<ReaderBookmark>>((l) => l.isNotEmpty)),
      );
      await notifier().toggleBookmark();
      await expectation;
    });

    test('charOffset в закладке == startCharOffset текущей страницы',
        () async {
      await pump();
      await notifier().toggleBookmark();
      await pump();

      final rows = await db.select(db.readerBookmarks).get();
      expect(rows, hasLength(1));
      expect(rows.first.charOffset, equals(_BookmarkTestEngine.kCharOffset));
    });
  });
}

/// Движок для D2-тестов: эмитит локатор `'0:1337'` при open().
/// charOffset = 1337 детерминировано совпадёт с сохранённой закладкой.
class _BookmarkTestEngine implements ReaderEngine {
  static const int kCharOffset = 1337;

  final _progress = StreamController<ReaderProgress>.broadcast();
  final _selection = StreamController<ReaderSelection>.broadcast();

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
    _progress.add(
      const ReaderProgress(
        locator: ReaderLocator(
          progress: 0,
          anchor: '0:$kCharOffset',
          chapterIndex: 0,
        ),
        currentPage: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _progress.close();
    await _selection.close();
  }

  @override
  Future<void> goTo(ReaderLocator locator) async {}

  @override
  Future<void> nextPage() async {}

  @override
  Future<void> prevPage() async {}

  @override
  Future<List<ReaderSearchResult>> search(String query) async => const [];

  @override
  String currentPagePreview() => '';

  @override
  Future<void> applySettings(ReaderSettings settings) async {}
}
