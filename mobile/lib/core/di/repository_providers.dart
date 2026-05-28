import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookish_corner/core/di/database_provider.dart';
import 'package:bookish_corner/features/book_details/data/empty_book_recommendation_repository.dart';
import 'package:bookish_corner/features/book_details/data/google_books_client.dart';
import 'package:bookish_corner/features/book_details/data/google_books_metadata_repository.dart';
import 'package:bookish_corner/features/book_details/data/info_txt_metadata_parser.dart';
import 'package:bookish_corner/features/book_details/data/info_txt_metadata_source.dart';
import 'package:bookish_corner/features/book_details/domain/book_metadata_enrichment_repository.dart';
import 'package:bookish_corner/features/book_details/domain/book_recommendation_repository.dart';
import 'package:bookish_corner/features/library/data/drift_book_repository.dart';
import 'package:bookish_corner/features/library/domain/book_repository.dart';
import 'package:bookish_corner/features/library/utils/book_metadata_extractor.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/composite_chapter_resolver.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/cue_chapter_resolver.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/filename_chapter_resolver.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/id3_chapter_resolver.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/m4b_chapter_resolver.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/single_file_chapter_resolver.dart';
import 'package:bookish_corner/features/player/data/drift_audio_bookmark_repository.dart';
import 'package:bookish_corner/features/player/data/drift_audio_progress_repository.dart';
import 'package:bookish_corner/features/player/domain/audio_bookmark_repository.dart';
import 'package:bookish_corner/features/player/domain/audio_progress_repository.dart';
import 'package:bookish_corner/features/player/domain/chapter_resolver.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return DriftBookRepository(ref.watch(appDatabaseProvider));
});

final bookMetadataExtractorProvider = Provider<BookMetadataExtractor>((ref) {
  return const BookMetadataExtractor();
});

final infoTxtMetadataSourceProvider = Provider<InfoTxtMetadataSource>((ref) {
  return const InfoTxtMetadataSource(InfoTxtMetadataParser());
});

final googleBooksClientProvider = Provider<GoogleBooksClient>((ref) {
  final client = GoogleBooksClient();
  ref.onDispose(client.close);
  return client;
});

final bookMetadataEnrichmentRepositoryProvider =
    Provider<BookMetadataEnrichmentRepository>((ref) {
      return GoogleBooksMetadataRepository(
        ref.watch(googleBooksClientProvider),
      );
    });

final bookRecommendationRepositoryProvider =
    Provider<BookRecommendationRepository>((ref) {
      return const EmptyBookRecommendationRepository();
    });

final audioProgressRepositoryProvider = Provider<AudioProgressRepository>((
  ref,
) {
  return DriftAudioProgressRepository(ref.watch(appDatabaseProvider));
});

final audioBookmarkRepositoryProvider = Provider<AudioBookmarkRepository>((
  ref,
) {
  return DriftAudioBookmarkRepository(ref.watch(appDatabaseProvider));
});

final chapterResolverProvider = Provider<ChapterResolver>((ref) {
  return const CompositeChapterResolver([
    M4bChapterResolver(),
    Id3ChapterResolver(),
    CueChapterResolver(),
    FilenameChapterResolver(),
    SingleFileChapterResolver(),
  ]);
});
