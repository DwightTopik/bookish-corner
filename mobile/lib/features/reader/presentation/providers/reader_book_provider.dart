import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/features/library/domain/book.dart';

/// Источник метаданных книги (title/author/cover) для экрана ридера.
///
/// Зеркало `playerBookProvider`: chrome берёт заголовок и автора отсюда, а не
/// дублирует их в [ReaderControllerNotifier] (контроллер занимается только
/// позицией движка).
final readerBookProvider = StreamProvider.family<Book?, String>((ref, bookId) {
  return ref.watch(bookRepositoryProvider).watchBookById(bookId);
});
