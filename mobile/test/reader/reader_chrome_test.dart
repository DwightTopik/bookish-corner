import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/theme/app_theme.dart';
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
import 'package:bookish_corner/features/reader/presentation/screens/reader_screen.dart';

const _bookId = 'book-1';

final _book = Book(
  id: _bookId,
  title: 'Тестовая книга',
  author: 'Автор Тестов',
  filePath: '/tmp/book.fb2',
  format: BookFormat.fb2,
  addedAt: DateTime(2026),
);

/// Поднимает [ReaderScreen] в [MaterialApp] с подменённым движком и источником
/// книги. Возвращает контейнер для прямых проверок состояния контроллера.
Future<ProviderContainer> _pumpReader(
  WidgetTester tester,
  _RecordingEngine engine,
) async {
  final container = ProviderContainer(
    overrides: [
      readerEngineProvider.overrideWith((ref, bookId) => engine),
      readerBookProvider.overrideWith((ref, bookId) => Stream.value(_book)),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildDarkTheme(),
        home: const ReaderScreen(bookId: _bookId),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('ready-стейт рендерит оболочку', (tester) async {
    await _pumpReader(tester, _RecordingEngine());

    // Top bar: title + author.
    expect(find.text('Тестовая книга'), findsOneWidget);
    expect(find.text('Автор Тестов'), findsOneWidget);
    // Bottom panel: глава + остаток до следующей.
    expect(find.text('Глава 1'), findsOneWidget);
    expect(find.text('ещё 3 стр'), findsOneWidget);
    // Toolbar: 4 кнопки (Слушать скрыта за hasAudioVersion=false).
    expect(find.byIcon(Icons.format_list_bulleted), findsOneWidget);
    expect(find.byIcon(Icons.edit_note), findsOneWidget);
    expect(find.byIcon(Icons.text_fields), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.byIcon(Icons.headphones), findsNothing);
    // Назад/Вперёд скрыты (история пуста).
    expect(find.text('Назад'), findsNothing);
    expect(find.text('Вперёд'), findsNothing);
  });

  testWidgets('тап по центру тогглит видимость chrome', (tester) async {
    final container = await _pumpReader(tester, _RecordingEngine());
    expect(
      container.read(readerControllerProvider(_bookId)).chromeVisible,
      isTrue,
    );

    final center = tester.getCenter(find.byType(ReaderScreen));
    await tester.tapAt(center);
    await tester.pumpAndSettle();

    expect(
      container.read(readerControllerProvider(_bookId)).chromeVisible,
      isFalse,
    );
    // Иммерсивный футер «N из M» присутствует.
    expect(find.text('1 из 12'), findsOneWidget);
  });

  testWidgets('тап по боковым зонам делегирует prev/next движку', (
    tester,
  ) async {
    final engine = _RecordingEngine();
    await _pumpReader(tester, engine);

    final size = tester.getSize(find.byType(ReaderScreen));
    final midY = size.height / 2;
    // Правая зона → nextPage.
    await tester.tapAt(Offset(size.width * 0.9, midY));
    await tester.pumpAndSettle();
    expect(engine.nextCalled, isTrue);
    // Левая зона → prevPage.
    await tester.tapAt(Offset(size.width * 0.1, midY));
    await tester.pumpAndSettle();
    expect(engine.prevCalled, isTrue);
  });

  testWidgets('перетаскивание слайдера вызывает seekTo (anchor пустой)', (
    tester,
  ) async {
    final engine = _RecordingEngine();
    await _pumpReader(tester, engine);

    await tester.drag(find.byType(Slider), const Offset(80, 0));
    await tester.pumpAndSettle();

    expect(engine.lastGoTo, isNotNull);
    expect(engine.lastGoTo!.anchor, equals(''));
  });
}

/// Записывающий тест-дубль движка: эмитит фиксированную позицию на open()
/// (статус → ready) и фиксирует делегированные интенты.
class _RecordingEngine implements ReaderEngine {
  final StreamController<ReaderProgress> _progress =
      StreamController<ReaderProgress>.broadcast();
  final StreamController<ReaderSelection> _selection =
      StreamController<ReaderSelection>.broadcast();

  bool nextCalled = false;
  bool prevCalled = false;
  ReaderLocator? lastGoTo;

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
  List<TocEntry> get toc => const [];

  @override
  Future<void> open() async {
    _progress.add(
      const ReaderProgress(
        locator: ReaderLocator(progress: 0, anchor: 'page:1', chapterIndex: 0),
        currentPage: 1,
        totalPages: 12,
        pagesToNextChapter: 3,
      ),
    );
  }

  @override
  Future<void> dispose() async {
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
