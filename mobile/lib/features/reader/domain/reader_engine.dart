import 'package:bookish_corner/features/reader/domain/reader_capabilities.dart';
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';
import 'package:bookish_corner/features/reader/domain/reader_progress.dart';
import 'package:bookish_corner/features/reader/domain/reader_search_result.dart';
import 'package:bookish_corner/features/reader/domain/reader_selection.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/domain/toc_entry.dart';

/// Format-agnostic контракт движка ридера. Реализуется отдельно на каждый
/// формат (epub/fb2/pdf/txt — задачи B/C); единый chrome (B2) работает только
/// против этого интерфейса.
///
/// Интерфейс спроектирован под САМЫЙ ОГРАНИЧЕННЫЙ бэкенд — epub.js
/// (асинхронный, якорь-агностичный): вся навигация возвращает [Future],
/// позиция и выделение приходят потоками, а [anchor] непрозрачен. То, что лёгко
/// ложится на epub.js, гарантированно реализуемо и на остальных форматах.
abstract class ReaderEngine {
  /// Что движок умеет — chrome по этим флагам скрывает недоступные контролы.
  ReaderCapabilities get capabilities;

  /// Поток снимков состояния рендера (новая эмиссия при каждом перемещении).
  Stream<ReaderProgress> get progress;

  /// Поток выделений текста пользователем.
  Stream<ReaderSelection> get selection;

  /// Оглавление. Валидно только ПОСЛЕ завершения [open] (у epub оно готово
  /// после генерации locations внутри [open]).
  List<TocEntry> get toc;

  /// Открыть книгу и подготовить рендер. По завершении [toc] и проценты
  /// доступны, эмитится стартовый [ReaderProgress].
  Future<void> open();

  /// Освободить ресурсы. Должен быть идемпотентным.
  Future<void> dispose();

  /// Перейти к позиции. Если [ReaderLocator.anchor] пуст (`''`), движок
  /// резолвит позицию по [ReaderLocator.progress] (перемотка слайдером).
  Future<void> goTo(ReaderLocator locator);

  Future<void> nextPage();
  Future<void> prevPage();

  Future<List<ReaderSearchResult>> search(String query);

  Future<void> applySettings(ReaderSettings settings);
}
