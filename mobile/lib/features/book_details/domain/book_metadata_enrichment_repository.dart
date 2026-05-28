import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';

abstract class BookMetadataEnrichmentRepository {
  Future<BookDetailsMetadata?> enrich(BookDetailsMetadata base);
}
