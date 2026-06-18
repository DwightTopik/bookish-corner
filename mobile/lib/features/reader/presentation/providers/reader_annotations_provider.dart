import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';

/// Стрим всех аннотаций книги. Зеркало audioBookmarksProvider.
final readerAnnotationsProvider =
    StreamProvider.family<List<ReaderAnnotation>, String>(
  (ref, bookId) =>
      ref.watch(readerAnnotationRepositoryProvider).watchAnnotations(bookId),
  isAutoDispose: true,
);
