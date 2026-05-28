import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_recommendation.dart';

abstract class BookRecommendationRepository {
  Future<List<BookDetailsRecommendation>> getRecommendations(
    BookDetailsMetadata book,
  );
}
