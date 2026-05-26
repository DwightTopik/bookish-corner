import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/di/repository_providers.dart';
import 'package:mobile/features/library/domain/book.dart';

final booksStreamProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(bookRepositoryProvider).watchAllBooks();
});
