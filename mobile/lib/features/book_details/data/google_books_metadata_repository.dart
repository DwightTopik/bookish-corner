import 'package:bookish_corner/features/book_details/data/google_books_client.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';
import 'package:bookish_corner/features/book_details/domain/book_metadata_enrichment_repository.dart';

class GoogleBooksMetadataRepository
    implements BookMetadataEnrichmentRepository {
  const GoogleBooksMetadataRepository(this._client);

  final GoogleBooksClient _client;

  @override
  Future<BookDetailsMetadata?> enrich(BookDetailsMetadata base) {
    return _client.search(base);
  }
}
