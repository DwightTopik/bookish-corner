import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;
import 'package:id3tag/id3tag.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

import 'package:bookish_corner/features/library/domain/book_format.dart';

class ExtractedBookMetadata {
  const ExtractedBookMetadata({
    required this.title,
    required this.author,
    this.narrator,
    this.coverBytes,
  });

  final String title;
  final String author;
  final String? narrator;
  final Uint8List? coverBytes;
}

class BookMetadataExtractor {
  const BookMetadataExtractor();

  Future<ExtractedBookMetadata> extract(
    String filePath,
    BookFormat format,
  ) async {
    final fileName = p.basename(filePath);
    final fallback = _parseFilename(fileName, isAudio: format.isAudio);

    try {
      final _Partial partial = switch (format) {
        .epub => await _extractEpub(filePath),
        .fb2 => await _extractFb2(filePath),
        .pdf => await _extractPdf(filePath),
        .mp3 => await _extractMp3(filePath),
        .m4b => await _extractM4b(filePath),
        .txt || .audioFolder => const _Partial(),
      };
      return _mergeWithFallback(partial, fallback);
    } catch (_) {
      return fallback;
    }
  }

  /// Extracts metadata from a single audio file.
  ///
  /// When importing from a folder, pass [folderPath] so that the filename
  /// fallback uses the folder name (the book title) rather than the individual
  /// audio file name (the chapter title).
  Future<ExtractedBookMetadata> extractFromAudioFile(
    String filePath, {
    String? folderPath,
  }) async {
    final ext = p.extension(filePath).toLowerCase().replaceFirst('.', '');
    final fallbackName = p.basename(folderPath ?? filePath);
    final fallback = _parseFilename(fallbackName, isAudio: true);
    try {
      final _Partial partial = switch (ext) {
        'mp3' => await _extractMp3(filePath),
        'm4b' || 'm4a' => await _extractM4b(filePath),
        _ => await _extractGenericAudio(filePath),
      };
      return _mergeWithFallback(partial, fallback);
    } catch (_) {
      return fallback;
    }
  }

  Future<_Partial> _extractGenericAudio(String filePath) async {
    final meta = amr.readMetadata(File(filePath), getImage: true);
    final albumTitle = meta.album?.trim();
    final trackTitle = meta.title?.trim();
    final title =
        (albumTitle?.isNotEmpty ?? false) ? albumTitle : trackTitle;
    final author = meta.artist?.trim();
    Uint8List? cover;
    if (meta.pictures.isNotEmpty) {
      cover = Uint8List.fromList(meta.pictures.first.bytes);
    }
    return _Partial(
      title: (title?.isNotEmpty ?? false) ? title : null,
      author: (author?.isNotEmpty ?? false) ? author : null,
      coverBytes: cover,
    );
  }

  ExtractedBookMetadata _mergeWithFallback(
    _Partial partial,
    ExtractedBookMetadata fallback,
  ) {
    final _Partial(
      title: pTitle,
      author: pAuthor,
      narrator: pNarrator,
      coverBytes: pCover,
    ) = partial;
    final ExtractedBookMetadata(
      title: fTitle,
      author: fAuthor,
      narrator: fNarrator,
    ) = fallback;
    return ExtractedBookMetadata(
      title: _firstNonEmpty(pTitle, fTitle),
      author: _firstNonEmpty(pAuthor, fAuthor),
      narrator: _firstNonEmptyOrNull(pNarrator, fNarrator),
      coverBytes: pCover,
    );
  }

  Future<_Partial> _extractEpub(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final container = archive.findFile('META-INF/container.xml');
    if (container == null) return const _Partial();
    final containerXml = XmlDocument.parse(
      utf8.decode(container.content as List<int>, allowMalformed: true),
    );
    final rootfile = containerXml
        .findAllElements('rootfile')
        .firstOrNull
        ?.getAttribute('full-path');
    if (rootfile == null) return const _Partial();

    final opfFile = archive.findFile(rootfile);
    if (opfFile == null) return const _Partial();
    final opfDir = p.posix.dirname(rootfile);
    final opfXml = XmlDocument.parse(
      utf8.decode(opfFile.content as List<int>, allowMalformed: true),
    );

    String? title;
    String? author;
    for (final el in opfXml.findAllElements('*')) {
      if (el.name.local == 'title' && title == null) {
        final t = el.innerText.trim();
        if (t.isNotEmpty) title = t;
      } else if (el.name.local == 'creator' && author == null) {
        final a = el.innerText.trim();
        if (a.isNotEmpty) author = a;
      }
    }

    Uint8List? coverBytes;
    try {
      String? coverId;
      for (final meta in opfXml.findAllElements('meta')) {
        if (meta.getAttribute('name') == 'cover') {
          coverId = meta.getAttribute('content');
          break;
        }
      }
      String? coverHref;
      for (final item in opfXml.findAllElements('item')) {
        final id = item.getAttribute('id');
        final props = item.getAttribute('properties') ?? '';
        final mt = item.getAttribute('media-type') ?? '';
        final isMatch = (coverId != null && id == coverId) ||
            props.contains('cover-image') ||
            (id != null &&
                id.toLowerCase().contains('cover') &&
                mt.startsWith('image/'));
        if (isMatch) {
          coverHref = item.getAttribute('href');
          break;
        }
      }
      if (coverHref != null) {
        final coverPath = opfDir.isEmpty
            ? coverHref
            : p.posix.normalize(p.posix.join(opfDir, coverHref));
        final coverFile = archive.findFile(coverPath);
        if (coverFile != null) {
          coverBytes = Uint8List.fromList(coverFile.content as List<int>);
        }
      }
    } catch (_) {}

    return _Partial(title: title, author: author, coverBytes: coverBytes);
  }

  Future<_Partial> _extractFb2(String filePath) async {
    final content = await File(filePath).readAsString();
    final doc = XmlDocument.parse(content);
    final titleInfo = doc.findAllElements('title-info').firstOrNull;
    if (titleInfo == null) return const _Partial();

    final title =
        titleInfo.findElements('book-title').firstOrNull?.innerText.trim();
    final authorEl = titleInfo.findElements('author').firstOrNull;
    String? author;
    if (authorEl != null) {
      final first =
          authorEl.findElements('first-name').firstOrNull?.innerText.trim();
      final last =
          authorEl.findElements('last-name').firstOrNull?.innerText.trim();
      final nick =
          authorEl.findElements('nickname').firstOrNull?.innerText.trim();
      final joined =
          [first, last].where((s) => s != null && s.isNotEmpty).join(' ');
      author = joined.isNotEmpty ? joined : nick;
    }

    Uint8List? coverBytes;
    try {
      final coverpage = titleInfo.findElements('coverpage').firstOrNull;
      final imageEl = coverpage?.findElements('image').firstOrNull;
      final imageHref = imageEl?.getAttribute('l:href') ??
          imageEl?.getAttribute('xlink:href');
      if (imageHref != null && imageHref.startsWith('#')) {
        final id = imageHref.substring(1);
        for (final binary in doc.findAllElements('binary')) {
          if (binary.getAttribute('id') == id) {
            final b64 = binary.innerText.replaceAll(RegExp(r'\s'), '');
            coverBytes = _decodeBase64(b64);
            break;
          }
        }
      }
    } catch (_) {}

    return _Partial(
      title: (title?.isNotEmpty ?? false) ? title : null,
      author: (author?.isNotEmpty ?? false) ? author : null,
      coverBytes: coverBytes,
    );
  }

  Uint8List? _decodeBase64(String s) {
    try {
      return Uint8List.fromList(base64.decode(s));
    } catch (_) {
      return null;
    }
  }

  Future<_Partial> _extractPdf(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);
    try {
      final info = doc.documentInformation;
      final title = info.title.trim();
      final author = info.author.trim();
      return _Partial(
        title: title.isEmpty ? null : title,
        author: author.isEmpty ? null : author,
      );
    } finally {
      doc.dispose();
    }
  }

  Future<_Partial> _extractMp3(String filePath) async {
    final reader = ID3TagReader.path(filePath);
    final tag = await reader.readTag();
    final albumTitle =
        tag.frameWithTypeAndName<TextInformation>('TALB')?.value.trim();
    final trackTitle = tag.title?.trim();
    final title =
        (albumTitle?.isNotEmpty ?? false) ? albumTitle : trackTitle;
    final author = tag.artist?.trim();
    final albumArtist =
        tag.frameWithTypeAndName<TextInformation>('TPE2')?.value.trim();
    Uint8List? cover;
    if (tag.pictures.isNotEmpty) {
      cover = Uint8List.fromList(tag.pictures.first.imageData);
    }
    return _Partial(
      title: (title?.isNotEmpty ?? false) ? title : null,
      author: (author?.isNotEmpty ?? false) ? author : null,
      narrator: (albumArtist?.isNotEmpty ?? false) ? albumArtist : null,
      coverBytes: cover,
    );
  }

  Future<_Partial> _extractM4b(String filePath) async {
    final meta = amr.readMetadata(File(filePath), getImage: true);
    final albumTitle = meta.album?.trim();
    final trackTitle = meta.title?.trim();
    final title =
        (albumTitle?.isNotEmpty ?? false) ? albumTitle : trackTitle;
    final author = meta.artist?.trim();
    Uint8List? cover;
    if (meta.pictures.isNotEmpty) {
      cover = Uint8List.fromList(meta.pictures.first.bytes);
    }
    return _Partial(
      title: (title?.isNotEmpty ?? false) ? title : null,
      author: (author?.isNotEmpty ?? false) ? author : null,
      coverBytes: cover,
    );
  }

  ExtractedBookMetadata _parseFilename(
    String fileName, {
    required bool isAudio,
  }) {
    String stripped = p.basenameWithoutExtension(fileName);

    String? narrator;
    if (isAudio) {
      final re = RegExp(
        r'\((?:read by|чит\.|narrator)\s+([^)]+)\)',
        caseSensitive: false,
        unicode: true,
      );
      final m = re.firstMatch(stripped);
      if (m != null) {
        narrator = m.group(1)?.trim();
        stripped = stripped.replaceRange(m.start, m.end, '').trim();
      }
    }

    String author = '';
    String title = stripped;
    final sepIdx = stripped.indexOf(' - ');
    if (sepIdx > 0) {
      author = stripped.substring(0, sepIdx).trim();
      title = stripped.substring(sepIdx + 3).trim();
    }

    author = _cleanPart(author);
    title = _cleanPart(title);

    return ExtractedBookMetadata(
      title: title,
      author: author,
      narrator: (narrator?.isNotEmpty ?? false) ? narrator : null,
    );
  }

  String _cleanPart(String s) {
    String out = s.replaceAll(RegExp(r'[_\.]'), ' ').trim();
    out = out.replaceAll(RegExp(r'\s+'), ' ');
    if (out.isEmpty) return out;
    final isAllLower = out == out.toLowerCase();
    final isAllUpper = out == out.toUpperCase();
    if (isAllLower || isAllUpper) {
      out = out
          .split(' ')
          .map(
            (w) => w.isEmpty
                ? w
                : w[0].toUpperCase() + w.substring(1).toLowerCase(),
          )
          .join(' ');
    }
    return out;
  }

  String _firstNonEmpty(String? a, String b) {
    if (a != null && a.trim().isNotEmpty) return a.trim();
    return b;
  }

  String? _firstNonEmptyOrNull(String? a, String? b) {
    if (a != null && a.trim().isNotEmpty) return a.trim();
    if (b != null && b.trim().isNotEmpty) return b.trim();
    return null;
  }
}

class _Partial {
  const _Partial({this.title, this.author, this.narrator, this.coverBytes});

  final String? title;
  final String? author;
  final String? narrator;
  final Uint8List? coverBytes;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
