import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';

class MetadataDebugSummary {
  const MetadataDebugSummary({
    required this.hasDescription,
    required this.genresCount,
    required this.contentsCount,
    required this.visibleFieldCount,
    this.series,
    this.isbn,
    this.translator,
    this.narrator,
    this.rightHolder,
  });

  final bool hasDescription;
  final String? series;
  final int genresCount;
  final String? isbn;
  final String? translator;
  final String? narrator;
  final String? rightHolder;
  final int contentsCount;
  final int visibleFieldCount;

  factory MetadataDebugSummary.fromMetadata(BookDetailsMetadata? metadata) {
    if (metadata == null) {
      return const MetadataDebugSummary(
        hasDescription: false,
        genresCount: 0,
        contentsCount: 0,
        visibleFieldCount: 0,
      );
    }
    final BookDetailsMetadata(
      :title,
      :author,
      :series,
      :description,
      :categories,
      :ageRestriction,
      :publishedDate,
      :writtenDate,
      :isbn,
      :translator,
      :narrator,
      :duration,
      :publisher,
      :rightHolder,
      :language,
      :pageCount,
      :tableOfContents,
    ) = metadata;
    final fields = [
      title,
      author,
      series,
      description,
      ageRestriction,
      publishedDate,
      writtenDate,
      isbn,
      translator,
      narrator,
      duration,
      publisher,
      rightHolder,
      language,
      pageCount,
    ].where(_hasValue).length;
    return MetadataDebugSummary(
      hasDescription: _hasValue(description),
      series: series,
      genresCount: categories.length,
      isbn: isbn,
      translator: translator,
      narrator: narrator,
      rightHolder: rightHolder,
      contentsCount: tableOfContents.length,
      visibleFieldCount: fields + categories.length + tableOfContents.length,
    );
  }

  static bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class InfoTxtLookupDiagnostics {
  const InfoTxtLookupDiagnostics({
    required this.candidatePaths,
    required this.found,
    required this.readSucceeded,
    required this.parseSucceeded,
    this.foundPath,
    this.errorSummary,
    this.metadata,
  });

  final List<String> candidatePaths;
  final bool found;
  final bool readSucceeded;
  final bool parseSucceeded;
  final String? foundPath;
  final String? errorSummary;
  final BookDetailsMetadata? metadata;

  MetadataDebugSummary get parsedSummary => .fromMetadata(metadata);
}

class GoogleBooksLookupDiagnostics {
  const GoogleBooksLookupDiagnostics({
    required this.attempted,
    required this.queries,
    required this.resultCount,
    this.statusCode,
    this.errorSummary,
    this.metadata,
  });

  final bool attempted;
  final List<String> queries;
  final int resultCount;
  final int? statusCode;
  final String? errorSummary;
  final BookDetailsMetadata? metadata;

  String get queryString => queries.join(' | ');
}

class BookDetailsDebugDiagnostics {
  const BookDetailsDebugDiagnostics({
    required this.bookId,
    required this.localPath,
    required this.infoTxt,
    required this.googleBooks,
    required this.finalSummary,
    required this.hasLocalMetadata,
    required this.hasInfoTxtMetadata,
    required this.hasGoogleMetadata,
  });

  final String bookId;
  final String localPath;
  final InfoTxtLookupDiagnostics infoTxt;
  final GoogleBooksLookupDiagnostics googleBooks;
  final MetadataDebugSummary finalSummary;
  final bool hasLocalMetadata;
  final bool hasInfoTxtMetadata;
  final bool hasGoogleMetadata;
}
