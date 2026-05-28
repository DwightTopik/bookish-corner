import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:bookish_corner/features/book_details/domain/book_details_diagnostics.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';

class GoogleBooksClient {
  GoogleBooksClient({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  // Optional for local development:
  // flutter run --dart-define=GOOGLE_BOOKS_API_KEY=...
  // Do not hardcode API keys in the app; production enrichment should move
  // behind the FastAPI backend.
  static const _apiKey = String.fromEnvironment('GOOGLE_BOOKS_API_KEY');

  final HttpClient _httpClient;
  final _diagnosticsCache = <String, _CachedGoogleBooksLookup>{};
  DateTime? _lastRequestAt;

  static const _cacheTtl = Duration(minutes: 30);
  static const _minRequestInterval = Duration(seconds: 2);

  Future<BookDetailsMetadata?> search(BookDetailsMetadata base) async {
    final diagnostics = await searchWithDiagnostics(base);
    return diagnostics.metadata;
  }

  Future<GoogleBooksLookupDiagnostics> searchWithDiagnostics(
    BookDetailsMetadata base,
  ) async {
    final queries = _queriesFor(base);
    if (queries.isEmpty) {
      dev.log(
        'Google Books not attempted: empty query',
        name: 'GoogleBooksClient',
      );
      return const GoogleBooksLookupDiagnostics(
        attempted: false,
        queries: [],
        resultCount: 0,
      );
    }

    GoogleBooksLookupDiagnostics? lastDiagnostics;
    for (final query in queries) {
      final diagnostics = await _cachedSearchQuery(query);
      lastDiagnostics = diagnostics;
      if (diagnostics.metadata != null) return diagnostics;
    }
    return lastDiagnostics ??
        GoogleBooksLookupDiagnostics(
          attempted: true,
          queries: queries,
          resultCount: 0,
        );
  }

  Future<GoogleBooksLookupDiagnostics> _cachedSearchQuery(String query) {
    final now = DateTime.now();
    final cached = _diagnosticsCache[query];
    if (cached != null && now.difference(cached.createdAt) < _cacheTtl) {
      dev.log('Google Books cache hit: $query', name: 'GoogleBooksClient');
      return cached.future;
    }
    if (cached != null) _diagnosticsCache.remove(query);

    final lookup = _diagnosticsCache.putIfAbsent(
      query,
      () => _CachedGoogleBooksLookup(
        createdAt: now,
        future: _throttledSearchQuery(query),
      ),
    );
    return lookup.future;
  }

  Future<GoogleBooksLookupDiagnostics> _throttledSearchQuery(
    String query,
  ) async {
    final lastRequestAt = _lastRequestAt;
    if (lastRequestAt != null) {
      final elapsed = DateTime.now().difference(lastRequestAt);
      if (elapsed < _minRequestInterval) {
        await Future<void>.delayed(_minRequestInterval - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();
    return _searchQuery(query);
  }

  Future<GoogleBooksLookupDiagnostics> _searchQuery(String query) async {
    dev.log('Google Books request: $query', name: 'GoogleBooksClient');
    try {
      final params = <String, String>{
        'q': query,
        'maxResults': '3',
        'printType': 'books',
        if (_apiKey.isNotEmpty) 'key': _apiKey,
      };
      final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', params);
      final request = await _httpClient.getUrl(uri);
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        dev.log(
          'Google Books non-success status: ${response.statusCode}',
          name: 'GoogleBooksClient',
        );
        return GoogleBooksLookupDiagnostics(
          attempted: true,
          queries: [query],
          statusCode: response.statusCode,
          resultCount: 0,
          errorSummary: 'HTTP ${response.statusCode}',
        );
      }
      final body = await utf8.decodeStream(response);
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, Object?>) {
        return GoogleBooksLookupDiagnostics(
          attempted: true,
          queries: [query],
          statusCode: response.statusCode,
          resultCount: 0,
          errorSummary: 'Unexpected JSON root',
        );
      }
      final items = decoded['items'];
      final resultCount = items is List ? items.length : 0;
      if (items is! List || items.isEmpty) {
        dev.log('Google Books empty result: $query', name: 'GoogleBooksClient');
        return GoogleBooksLookupDiagnostics(
          attempted: true,
          queries: [query],
          statusCode: response.statusCode,
          resultCount: resultCount,
        );
      }
      final volumeInfo = _bestVolumeInfo(items);
      if (volumeInfo is! Map<String, Object?>) {
        return GoogleBooksLookupDiagnostics(
          attempted: true,
          queries: [query],
          statusCode: response.statusCode,
          resultCount: resultCount,
          errorSummary: 'No volumeInfo',
        );
      }
      final metadata = _mapVolumeInfo(volumeInfo);
      final summary = MetadataDebugSummary.fromMetadata(metadata);
      final MetadataDebugSummary(
        :hasDescription,
        :genresCount,
        :visibleFieldCount,
      ) = summary;
      dev.log(
        'Google Books result: query=$query, status=${response.statusCode}, '
        'count=$resultCount, description=$hasDescription, '
        'genres=$genresCount, fields=$visibleFieldCount',
        name: 'GoogleBooksClient',
      );
      return GoogleBooksLookupDiagnostics(
        attempted: true,
        queries: [query],
        statusCode: response.statusCode,
        resultCount: resultCount,
        metadata: metadata,
      );
    } catch (error, stackTrace) {
      dev.log(
        'Google Books enrichment failed',
        name: 'GoogleBooksClient',
        error: error,
        stackTrace: stackTrace,
      );
      return GoogleBooksLookupDiagnostics(
        attempted: true,
        queries: [query],
        resultCount: 0,
        errorSummary: error.toString(),
      );
    }
  }

  void close() {
    _httpClient.close(force: true);
  }

  List<String> _queriesFor(BookDetailsMetadata base) {
    final isbn = base.isbn?.trim();
    if (isbn != null && isbn.isNotEmpty) return ['isbn:$isbn'];
    final title = base.title?.trim();
    final author = base.author?.trim();
    final queries = <String>[];
    if (title != null &&
        title.isNotEmpty &&
        author != null &&
        author.isNotEmpty) {
      queries.add('intitle:$title inauthor:$author');
      queries.add('$title $author');
    }
    if (title != null && title.isNotEmpty) queries.add('intitle:$title');
    return queries;
  }

  Map<String, Object?>? _bestVolumeInfo(List<Object?> items) {
    Map<String, Object?>? fallback;
    for (final item in items) {
      if (item is! Map<String, Object?>) continue;
      final volumeInfo = item['volumeInfo'];
      if (volumeInfo is! Map<String, Object?>) continue;
      fallback ??= volumeInfo;
      if (_string(volumeInfo['description']) != null &&
          _stringList(volumeInfo['categories']).isNotEmpty) {
        return volumeInfo;
      }
    }
    return fallback;
  }

  BookDetailsMetadata _mapVolumeInfo(Map<String, Object?> json) {
    final title = _string(json['title']);
    final subtitle = _string(json['subtitle']);
    return BookDetailsMetadata(
      title: title,
      author: _stringList(json['authors']).join(', '),
      description: _stripHtml(_string(json['description'])),
      categories: _stringList(json['categories']),
      publishedDate: _string(json['publishedDate']),
      isbn: _isbn(json['industryIdentifiers']),
      publisher: _string(json['publisher']),
      language: _string(json['language']),
      pageCount: _pageCount(json['pageCount']),
      ageRestriction: _ageRestriction(json['maturityRating']),
      coverUrl: _imageLink(json['imageLinks']),
      series: _seriesFromSubtitle(subtitle),
    );
  }

  String? _string(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String? _isbn(Object? value) {
    if (value is! List) return null;
    for (final item in value) {
      if (item is! Map<String, Object?>) continue;
      final type = _string(item['type']);
      final identifier = _string(item['identifier']);
      if (identifier == null) continue;
      if (type == 'ISBN_13') return identifier;
    }
    for (final item in value) {
      if (item is! Map<String, Object?>) continue;
      final identifier = _string(item['identifier']);
      if (identifier != null) return identifier;
    }
    return null;
  }

  String? _ageRestriction(Object? value) {
    final rating = _string(value);
    return switch (rating) {
      'MATURE' => '18+',
      'NOT_MATURE' => null,
      _ => rating,
    };
  }

  String? _pageCount(Object? value) {
    if (value is! num || value <= 0) return null;
    return '${value.round()} стр.';
  }

  String? _seriesFromSubtitle(String? subtitle) {
    if (subtitle == null) return null;
    final normalized = subtitle.trim();
    if (normalized.isEmpty) return null;
    final seriesMatch = RegExp(
      r'(.+?)(?:[,.:]\s*)?(?:book|книга|том)\s*\d+',
      caseSensitive: false,
      unicode: true,
    ).firstMatch(normalized);
    return seriesMatch?.group(1)?.trim();
  }

  String? _imageLink(Object? value) {
    if (value is! Map<String, Object?>) return null;
    for (final key in const ['extraLarge', 'large', 'medium', 'thumbnail']) {
      final link = _string(value[key]);
      if (link != null) return link.replaceFirst('http://', 'https://');
    }
    return null;
  }

  String? _stripHtml(String? value) {
    return value
        ?.replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _CachedGoogleBooksLookup {
  const _CachedGoogleBooksLookup({
    required this.createdAt,
    required this.future,
  });

  final DateTime createdAt;
  final Future<GoogleBooksLookupDiagnostics> future;
}
