import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/features/reader/data/fake_reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_engine.dart';

/// DI-seam движка ридера (swap-паттерн репозитория, как `bookRepositoryProvider`).
///
/// В A1 всегда отдаёт [FakeReaderEngine]. Позже одна строка здесь превратится в
/// фабрику, выбирающую реальный движок по формату книги (epub/fb2/pdf/txt —
/// задачи B/C). Family по `bookId` — чтобы сигнатура не менялась, когда фабрике
/// понадобится сама книга.
///
/// Провайдер владеет жизненным циклом движка: создаёт его и диспозит через
/// [Ref.onDispose]. Контроллер вызывает [ReaderEngine.open] и владеет только
/// своими подписками на потоки.
final readerEngineProvider = Provider.family<ReaderEngine, String>((
  ref,
  bookId,
) {
  final engine = FakeReaderEngine();
  ref.onDispose(engine.dispose);
  return engine;
}, isAutoDispose: true);
