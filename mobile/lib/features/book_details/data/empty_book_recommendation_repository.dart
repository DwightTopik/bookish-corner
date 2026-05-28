import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_recommendation.dart';
import 'package:bookish_corner/features/book_details/domain/book_recommendation_repository.dart';

class EmptyBookRecommendationRepository
    implements BookRecommendationRepository {
  const EmptyBookRecommendationRepository();

  @override
  Future<List<BookDetailsRecommendation>> getRecommendations(
    BookDetailsMetadata book,
  ) async {
    return const [];
  }
}
