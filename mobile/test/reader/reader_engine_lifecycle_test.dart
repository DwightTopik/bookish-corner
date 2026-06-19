import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/theme/app_theme.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/reader/data/fb2_reader_engine.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_book_provider.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/reader_chapters_sheet.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/reader_view.dart';

const _bookId = 'lifecycle-book';

/// Харнес: монтирует поверхность ридера и позволяет тогглить её в дереве
/// (имитация ре-маунта вью при мелькании loading) + открыть chapters sheet.
class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool _showView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () => setState(() => _showView = !_showView),
            child: const Text('toggle'),
          ),
          TextButton(
            onPressed: () => showReaderChaptersSheet(context, _bookId),
            child: const Text('open'),
          ),
          Expanded(
            child: _showView
                ? const ReaderView(bookId: _bookId)
                : const SizedBox.expand(),
          ),
        ],
      ),
    );
  }
}

void main() {
  late File tmp;

  setUp(() async {
    tmp = File(
      '${Directory.systemTemp.path}/bc_reader_${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    await tmp.writeAsString(
      [for (int i = 0; i < 60; i++) 'Строка номер $i в тестовом тексте.'].join('\n'),
    );
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete();
  });

  testWidgets(
    'движок создаётся один раз и переживает ре-маунт вью + работу sheet',
    (tester) async {
      int engineBuildCount = 0;
      Fb2ReaderEngine? captured;

      final book = Book(
        id: _bookId,
        title: 'Жизненный цикл',
        author: 'Тест',
        filePath: tmp.path,
        format: .txt,
        addedAt: DateTime(2026),
      );

      final container = ProviderContainer(
        overrides: [
          readerBookProvider.overrideWith((ref, _) => Stream.value(book)),
          readerEngineFactoryProvider.overrideWith(
            (ref) => (b) {
              engineBuildCount++;
              final Book(:filePath, :format, title: fallbackTitle) = b;
              captured = Fb2ReaderEngine(
                filePath: filePath,
                format: format,
                fallbackTitle: fallbackTitle,
              );
              return captured!;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: buildDarkTheme(), home: const _Harness()),
        ),
      );
      await tester.pumpAndSettle();

      expect(engineBuildCount, equals(1));
      expect(captured, isNotNull);
      expect(captured!.isOpened, isTrue);
      expect(captured!.isDisposed, isFalse);

      // Ре-маунт поверхности несколько раз — движок не должен умирать.
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('toggle')); // убрать ReaderView
        await tester.pumpAndSettle();
        await tester.tap(find.text('toggle')); // вернуть ReaderView
        await tester.pumpAndSettle();

        expect(engineBuildCount, equals(1), reason: 'движок не пересоздаётся');
        expect(
          captured!.isDisposed,
          isFalse,
          reason: 'движок жив после ре-маунта',
        );
        expect(tester.takeException(), isNull);
      }

      // Открыть/закрыть sheet, выбрать главу — без исключений, движок жив.
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Жизненный цикл')); // единственная глава txt
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      expect(engineBuildCount, equals(1));
      expect(captured!.isDisposed, isFalse);
    },
  );
}
