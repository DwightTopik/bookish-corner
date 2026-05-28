import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_diagnostics.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_recommendation.dart';
import 'package:bookish_corner/features/library/domain/book.dart';

final bookDetailsBookProvider = StreamProvider.family<Book?, String>((
  ref,
  bookId,
) {
  return ref.watch(bookRepositoryProvider).watchBookById(bookId);
});

final enrichedBookDetailsProvider =
    FutureProvider.family<BookDetailsMetadata?, String>((ref, bookId) async {
      final book = await ref
          .watch(bookRepositoryProvider)
          .watchBookById(bookId)
          .first;
      if (book == null) return null;

      final local = BookDetailsMetadata.fromBook(book);
      final info = await ref.watch(infoTxtMetadataSourceProvider).read(book);
      final withInfo = local.mergeMissing(info);
      final remote = await ref
          .watch(bookMetadataEnrichmentRepositoryProvider)
          .enrich(withInfo);
      return withInfo.mergeMissing(remote);
    });

final infoTxtBookDetailsProvider =
    FutureProvider.family<BookDetailsMetadata?, String>((ref, bookId) async {
      final book = await ref
          .watch(bookRepositoryProvider)
          .watchBookById(bookId)
          .first;
      if (book == null) return null;
      return ref.watch(infoTxtMetadataSourceProvider).read(book);
    });

final bookDetailsRecommendationsProvider =
    FutureProvider.family<List<BookDetailsRecommendation>, String>((
      ref,
      bookId,
    ) async {
      final details = await ref.watch(
        enrichedBookDetailsProvider(bookId).future,
      );
      if (details == null) return const [];
      return ref
          .watch(bookRecommendationRepositoryProvider)
          .getRecommendations(details);
    });

final bookDetailsDebugDiagnosticsProvider =
    FutureProvider.family<BookDetailsDebugDiagnostics?, String>((
      ref,
      bookId,
    ) async {
      final book = await ref
          .watch(bookRepositoryProvider)
          .watchBookById(bookId)
          .first;
      if (book == null) return null;

      final local = BookDetailsMetadata.fromBook(book);
      final infoDiagnostics = await ref
          .watch(infoTxtMetadataSourceProvider)
          .inspect(book);
      final withInfo = local.mergeMissing(infoDiagnostics.metadata);
      final googleDiagnostics = await ref
          .watch(googleBooksClientProvider)
          .searchWithDiagnostics(withInfo);
      final GoogleBooksLookupDiagnostics(
        :attempted,
        :statusCode,
        :resultCount,
        metadata: googleMetadata,
      ) = googleDiagnostics;
      final finalMetadata = withInfo.mergeMissing(googleDiagnostics.metadata);
      final finalSummary = MetadataDebugSummary.fromMetadata(finalMetadata);
      final diagnostics = BookDetailsDebugDiagnostics(
        bookId: book.id,
        localPath: book.filePath,
        infoTxt: infoDiagnostics,
        googleBooks: googleDiagnostics,
        finalSummary: finalSummary,
        hasLocalMetadata:
            MetadataDebugSummary.fromMetadata(local).visibleFieldCount > 0,
        hasInfoTxtMetadata: infoDiagnostics.parsedSummary.visibleFieldCount > 0,
        hasGoogleMetadata:
            MetadataDebugSummary.fromMetadata(
              googleMetadata,
            ).visibleFieldCount >
            0,
      );
      dev.log(
        'Book details diagnostics: bookId=$bookId, '
        'infoFound=${infoDiagnostics.found}, '
        'infoFields=${infoDiagnostics.parsedSummary.visibleFieldCount}, '
        'googleAttempted=$attempted, '
        'googleStatus=$statusCode, '
        'googleCount=$resultCount, '
        'finalFields=${finalSummary.visibleFieldCount}',
        name: 'BookDetailsDiagnostics',
      );
      return diagnostics;
    });
