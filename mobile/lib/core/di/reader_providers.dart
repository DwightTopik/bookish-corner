import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/reader/data/fake_reader_engine.dart';
import 'package:bookish_corner/features/reader/data/fb2_reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_engine.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_book_provider.dart';

/// Фабрика движка ридера по [Book]: формат → конкретная реализация
/// [ReaderEngine]. Движок зависит от файла и формата книги, поэтому seam — не
/// просто провайдер движка, а функция от книги. Чистая, без побочных эффектов;
/// владение жизненным циклом — на [readerEngineProvider].
typedef ReaderEngineFactory = ReaderEngine Function(Book book);

/// Swap-точка типов движка (как `bookRepositoryProvider`). fb2/txt →
/// [Fb2ReaderEngine]; epub/pdf пока → [FakeReaderEngine] (задачи C). Тесты
/// подменяют фабрику на управляемый фейк.
final readerEngineFactoryProvider = Provider<ReaderEngineFactory>((ref) {
  return (book) => switch (book.format) {
    .fb2 || .txt => Fb2ReaderEngine(
      filePath: book.filePath,
      format: book.format,
      fallbackTitle: book.title,
    ),
    _ => FakeReaderEngine(),
  };
});

/// Движок активной книги. Family по `bookId`: дожидается [Book] из
/// `readerBookProvider`, строит движок фабрикой и ВЛАДЕЕТ его жизненным циклом
/// (`ref.onDispose`). `null`, пока книга не загружена — тогда контроллер держит
/// `loading`. Поверхность рендера читает тот же инстанс
/// (`ref.read(...) as Fb2ReaderEngine`).
final readerEngineProvider = Provider.family<ReaderEngine?, String>((
  ref,
  bookId,
) {
  final book = ref.watch(readerBookProvider(bookId)).asData?.value;
  if (book == null) return null;
  final engine = ref.watch(readerEngineFactoryProvider)(book);
  ref.onDispose(engine.dispose);
  return engine;
}, isAutoDispose: true);
