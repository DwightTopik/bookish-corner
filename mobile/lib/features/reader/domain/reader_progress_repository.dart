import 'package:bookish_corner/features/reader/domain/reader_locator.dart';

abstract class ReaderProgressRepository {
  Future<ReaderLocator?> getProgress(String bookId);
  Future<void> saveProgress(String bookId, ReaderLocator locator);
  Stream<ReaderLocator?> watchProgress(String bookId);
}
