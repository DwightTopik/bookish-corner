import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bookish_corner/core/di/app_preferences_provider.dart';
import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/core/theme/app_theme.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/book_format.dart';
import 'package:bookish_corner/features/reader/domain/reader_capabilities.dart';
import 'package:bookish_corner/features/reader/domain/reader_bookmark.dart';
import 'package:bookish_corner/features/reader/domain/reader_bookmark_repository.dart';
import 'package:bookish_corner/features/reader/domain/reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';
import 'package:bookish_corner/features/reader/domain/reader_progress.dart';
import 'package:bookish_corner/features/reader/domain/reader_search_result.dart';
import 'package:bookish_corner/features/reader/domain/reader_selection.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/domain/toc_entry.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_book_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/reader_chapters_sheet.dart';

const _bookId = 'sheet-test';

final _book = Book(
  id: _bookId,
  title: 'Тестовая книга',
  author: 'Тест Автор',
  filePath: '/tmp/test.fb2',
  format: BookFormat.fb2,
  addedAt: DateTime(2026),
);

final _testToc = [
  TocEntry(
    id: '0',
    title: 'Глава 1',
    index: 0,
    depth: 0,
    anchor: const ReaderLocator(progress: 0.0, anchor: '0:0', chapterIndex: 0),
  ),
  TocEntry(
    id: '1',
    title: 'Подраздел 1.1',
    index: 1,
    depth: 1,
    anchor: const ReaderLocator(progress: 0.3, anchor: '1:0', chapterIndex: 1),
  ),
  TocEntry(
    id: '2',
    title: 'Глава 2',
    index: 2,
    depth: 0,
    anchor: const ReaderLocator(progress: 0.6, anchor: '2:0', chapterIndex: 2),
  ),
];

ProviderContainer _makeContainer(_TocTestEngine engine, SharedPreferences prefs) {
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      readerBookProvider.overrideWith((ref, _) => .value(_book)),
      readerEngineFactoryProvider.overrideWith((ref) => (_) => engine),
      readerBookmarkRepositoryProvider.overrideWith(
        (ref) => _StubBookmarkRepository(),
      ),
    ],
  );
  final sub = container.listen(readerControllerProvider(_bookId), (_, _) {});
  addTearDown(sub.close);
  addTearDown(container.dispose);
  return container;
}

Future<void> _openSheet(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildDarkTheme(),
        home: Builder(
          builder: (ctx) => Scaffold(
            body: TextButton(
              onPressed: () => showReaderChaptersSheet(ctx, _bookId),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('ReaderChaptersSheet', () {
    late _TocTestEngine engine;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      engine = _TocTestEngine();
      container = _makeContainer(engine, prefs);
    });

    testWidgets('sheet показывает все записи toc', (tester) async {
      await _openSheet(tester, container);

      expect(find.text('Глава 1'), findsOneWidget);
      expect(find.text('Подраздел 1.1'), findsOneWidget);
      expect(find.text('Глава 2'), findsOneWidget);
    });

    testWidgets('текущая глава (index=1) подсвечена accent-цветом', (
      tester,
    ) async {
      await _openSheet(tester, container);

      final activeText = tester.widget<Text>(find.text('Подраздел 1.1'));
      final inactiveText = tester.widget<Text>(find.text('Глава 1'));

      expect(activeText.style?.color, equals(AppColors.dark.accent));
      expect(inactiveText.style?.color, isNot(equals(AppColors.dark.accent)));
    });

    testWidgets(
      'тап по главе → goTo вызван с правильным anchor + sheet закрыт',
      (tester) async {
        await _openSheet(tester, container);

        await tester.tap(find.text('Глава 2'));
        await tester.pumpAndSettle();

        expect(engine.lastGoTo?.anchor, equals('2:0'));
        expect(find.text('Глава 2'), findsNothing);
      },
    );

    testWidgets(
      'многократное открытие/закрытие + выбор главы: toc не пустеет, без исключений',
      (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: buildDarkTheme(),
              home: Builder(
                builder: (ctx) => Scaffold(
                  body: TextButton(
                    onPressed: () => showReaderChaptersSheet(ctx, _bookId),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );

        for (int i = 0; i < 4; i++) {
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();

          // Все пункты toc на месте при каждом открытии.
          expect(find.text('Глава 1'), findsOneWidget);
          expect(find.text('Глава 2'), findsOneWidget);

          await tester.tap(find.text('Глава 2'));
          await tester.pumpAndSettle();

          expect(engine.lastGoTo?.anchor, equals('2:0'));
          expect(find.text('Глава 2'), findsNothing); // sheet закрыт
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets('вложенная запись (depth=1) имеет больший отступ', (
      tester,
    ) async {
      await _openSheet(tester, container);

      double leftPaddingOf(String title) {
        final finder = find.ancestor(
          of: find.text(title),
          matching: find.byType(Padding),
        );
        final paddings = tester.widgetList<Padding>(finder).toList();
        // Берём ближайший Padding — с самым маленьким left (он содержит отступ по depth).
        // На деле хотим максимальный left (самый внешний по дереву = depth-отступ).
        double maxLeft = 0;
        for (final p in paddings) {
          final left = p.padding.resolve(TextDirection.ltr).left;
          if (left > maxLeft) maxLeft = left;
        }
        return maxLeft;
      }

      final indentDepth0 = leftPaddingOf('Глава 1');
      final indentDepth1 = leftPaddingOf('Подраздел 1.1');

      expect(indentDepth1, greaterThan(indentDepth0));
    });
  });
}

// --- Тестовый движок --------------------------------------------------------

class _TocTestEngine implements ReaderEngine {
  final StreamController<ReaderProgress> _progress =
      StreamController<ReaderProgress>.broadcast();
  final StreamController<ReaderSelection> _selection =
      StreamController<ReaderSelection>.broadcast();

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
  List<TocEntry> get toc => _testToc;

  @override
  Future<void> open() async {
    _progress.add(
      const ReaderProgress(
        locator: ReaderLocator(progress: 0.3, anchor: '1:0', chapterIndex: 1),
        currentPage: 3,
        totalPages: 10,
      ),
    );
  }

  @override
  Future<void> goTo(ReaderLocator locator) async => lastGoTo = locator;

  @override
  Future<void> dispose() async {
    await _progress.close();
    await _selection.close();
  }

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

class _StubBookmarkRepository implements ReaderBookmarkRepository {
  @override
  Stream<List<ReaderBookmark>> watchBookmarks(String bookId) =>
      .value(const <ReaderBookmark>[]);

  @override
  Future<bool> isBookmarked(String bookId, int charOffset) async => false;

  @override
  Future<void> addBookmark(ReaderBookmark bookmark) async {}

  @override
  Future<void> removeBookmark(String id) async {}
}
