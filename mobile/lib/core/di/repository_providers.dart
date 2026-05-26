import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/di/database_provider.dart';
import 'package:mobile/features/library/data/drift_book_repository.dart';
import 'package:mobile/features/library/domain/book_repository.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return DriftBookRepository(ref.watch(appDatabaseProvider));
});
