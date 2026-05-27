import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookish_corner/core/di/database_provider.dart';
import 'package:bookish_corner/features/library/data/drift_book_repository.dart';
import 'package:bookish_corner/features/library/domain/book_repository.dart';
import 'package:bookish_corner/features/library/utils/book_metadata_extractor.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return DriftBookRepository(ref.watch(appDatabaseProvider));
});

final bookMetadataExtractorProvider = Provider<BookMetadataExtractor>((ref) {
  return const BookMetadataExtractor();
});
