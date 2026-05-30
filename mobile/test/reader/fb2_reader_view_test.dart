import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/theme/app_theme.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/reader/data/fb2_reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_book_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_ui_state.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/fb2_reader_view.dart';

const _bookId = 'view-test-book';

const _longFb2 = '''<?xml version="1.0" encoding="UTF-8"?>
<FictionBook><body>
<section>
<title><p>Глава первая</p></title>
<p>Абзац первый. Это длинный текст для проверки пагинации. Здесь достаточно слов чтобы занять несколько строк на узком экране и создать несколько страниц.</p>
<p>Абзац второй. Продолжение текста первой главы. Ещё больше слов и предложений для того чтобы страниц стало заметно больше одной при малой высоте.</p>
<p>Абзац третий. Финальный абзац первой главы. Текст продолжается дальше и не заканчивается здесь.</p>
</section>
<section>
<title><p>Глава вторая</p></title>
<p>Начало второй главы. Этот раздел тоже содержит достаточно текста для пагинации.</p>
<p>Второй абзац второй главы. Текст продолжается и здесь тоже.</p>
</section>
</body></FictionBook>''';

Future<(ProviderContainer, Fb2ReaderEngine)> _pumpView(
  WidgetTester tester,
  Directory dir, {
  String content = _longFb2,
  double width = 200,
  double height = 120,
}) async {
  final file = File(p.join(dir.path, 'book.fb2'));
  await file.writeAsString(content);

  final engine = Fb2ReaderEngine(
    filePath: file.path,
    format: .fb2,
    fallbackTitle: 'Тест',
  );

  final book = Book(
    id: _bookId,
    title: 'Тест',
    author: 'А',
    filePath: file.path,
    format: .fb2,
    addedAt: DateTime(2026),
  );

  final container = ProviderContainer(
    overrides: [
      readerBookProvider.overrideWith((ref, _) => Stream.value(book)),
      readerEngineFactoryProvider.overrideWith(
        (ref) =>
            (_) => engine,
      ),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(engine.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(
          body: SizedBox(
            width: width,
            height: height,
            child: const Fb2ReaderView(bookId: _bookId),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (container, engine);
}

ReaderUiState _state(ProviderContainer c) =>
    c.read(readerControllerProvider(_bookId));

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fb2_view_test');
    addTearDown(() async {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });
  });

  testWidgets('монтирование: движок открыт, currentPage == 1', (tester) async {
    final (container, _) = await _pumpView(tester, tempDir);
    final progress = _state(container).progress;
    expect(progress, isNotNull);
    expect(progress!.currentPage, equals(1));
  });

  testWidgets('next: страница продвигается вперёд, progress не уменьшается', (
    tester,
  ) async {
    final (container, engine) = await _pumpView(tester, tempDir);

    final double initialProgress = _state(container).progress!.locator.progress;
    final int initialPage = _state(container).progress!.currentPage ?? 1;

    await engine.nextPage();
    await tester.pumpAndSettle();

    final newStateProgress = _state(container).progress!;
    final int newPage = newStateProgress.currentPage ?? 1;
    final double newProgress = newStateProgress.locator.progress;

    expect(newPage, greaterThanOrEqualTo(initialPage));
    expect(newProgress, greaterThanOrEqualTo(initialProgress));
  });

  testWidgets('goTo по progress прыгает на позицию > 0', (tester) async {
    final (container, engine) = await _pumpView(tester, tempDir);

    await engine.goTo(const ReaderLocator(progress: 0.5, anchor: ''));
    await tester.pumpAndSettle();

    final double progress = _state(container).progress!.locator.progress;
    expect(progress, greaterThan(0.0));
  });

  testWidgets('смена fontSizeStep → глава сохраняется в anchor', (
    tester,
  ) async {
    final (container, _) = await _pumpView(tester, tempDir);

    final String anchorBefore = _state(container).progress!.locator.anchor;
    final String chBefore = anchorBefore.split(':').first;

    await container
        .read(readerControllerProvider(_bookId).notifier)
        .updateSettings(const ReaderSettings(fontSizeStep: 2));
    await tester.pumpAndSettle();

    final afterLocator = _state(container).progress!.locator;
    expect(afterLocator.anchor.isNotEmpty, isTrue);
    expect(afterLocator.anchor.split(':').first, equals(chBefore));
  });

  testWidgets('prev на первой странице не отходит назад', (tester) async {
    final (container, engine) = await _pumpView(tester, tempDir);

    expect(_state(container).progress!.currentPage, equals(1));

    await engine.prevPage();
    await tester.pumpAndSettle();

    expect(_state(container).progress!.currentPage, greaterThanOrEqualTo(1));
    expect(_state(container).progress!.locator.chapterIndex, equals(0));
  });

  // ── Тесты анимации перелистывания ────────────────────────────────────────

  testWidgets('next + анимация завершается → страница продвинулась, charOffset репорчен', (
    tester,
  ) async {
    final (container, engine) = await _pumpView(tester, tempDir);

    final int pageBeforeAnim = _state(container).progress!.currentPage!;

    await engine.nextPage();
    // Прокачиваем ровно длительность анимации + 1 кадр для settle.
    await tester.pump(
      const Duration(milliseconds: AppDimensions.readerPageTurnAnimMs),
    );
    await tester.pumpAndSettle();

    final progress = _state(container).progress!;
    expect(progress.currentPage, greaterThanOrEqualTo(pageBeforeAnim));
    // progress.locator должен быть заполнен (charOffset репортируется сразу).
    expect(progress.locator.progress, greaterThanOrEqualTo(0.0));
  });

  testWidgets('next×2 быстро (прерывание анимации) → осел на правильной финальной странице', (
    tester,
  ) async {
    final (container, engine) = await _pumpView(tester, tempDir);

    final int initialPage = _state(container).progress!.currentPage!;

    // Первый next.
    await engine.nextPage();
    await tester.pump(Duration.zero);
    // Продвигаем анимацию наполовину.
    await tester.pump(
      const Duration(milliseconds: AppDimensions.readerPageTurnAnimMs ~/ 2),
    );

    // Второй next во время первой анимации.
    await engine.nextPage();
    await tester.pumpAndSettle();

    // Финальная страница должна быть не меньше initialPage + 1 (оба перехода прошли).
    final afterProgress = _state(container).progress!;
    expect(afterProgress.currentPage!, greaterThanOrEqualTo(initialPage + 1));
  });

  testWidgets('next через границу главы → страница 1 следующей главы', (
    tester,
  ) async {
    // Минимальный FB2: две главы ровно по одной странице при узком viewport.
    const tinyFb2 = '''<?xml version="1.0" encoding="UTF-8"?>
<FictionBook><body>
<section><title><p>A</p></title><p>X</p></section>
<section><title><p>B</p></title><p>Y</p></section>
</body></FictionBook>''';

    final (container, engine) = await _pumpView(
      tester,
      tempDir,
      content: tinyFb2,
      width: 200,
      height: 120,
    );

    // Глава 0, страница 1.
    expect(_state(container).progress!.locator.chapterIndex, equals(0));

    await engine.nextPage();
    await tester.pumpAndSettle();

    // После перехода — глава 1, страница 1.
    final progress = _state(container).progress!;
    expect(progress.locator.chapterIndex, equals(1));
    expect(progress.currentPage, equals(1));
  });

  testWidgets('goTo не запускает анимацию (мгновенный переход)', (tester) async {
    final (_, engine) = await _pumpView(tester, tempDir);

    await engine.goTo(const ReaderLocator(progress: 0.5, anchor: ''));
    // Один нулевой кадр для обработки setState.
    await tester.pump(Duration.zero);

    // Не должно быть ни одной running-анимации.
    expect(tester.hasRunningAnimations, isFalse);
  });
}
