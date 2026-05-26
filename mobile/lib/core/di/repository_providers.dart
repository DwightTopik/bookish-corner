import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookish_corner/core/di/database_provider.dart';
import 'package:bookish_corner/features/library/data/drift_book_repository.dart';
import 'package:bookish_corner/features/library/domain/book_repository.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return DriftBookRepository(ref.watch(appDatabaseProvider));
});
