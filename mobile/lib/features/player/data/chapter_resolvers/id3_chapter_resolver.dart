import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;
import 'package:id3tag/id3tag.dart';
import 'package:path/path.dart' as p;

import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/natural_sort.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/domain/chapter_resolver.dart';

class Id3ChapterResolver implements ChapterResolver {
  const Id3ChapterResolver();

  @override
  Future<List<AudioChapter>> resolve(Book book) async {
    if (book.format != .audioFolder) return const [];
    final dir = Directory(book.filePath);
    if (!await dir.exists()) return const [];

    final mp3Files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File && p.extension(entity.path).toLowerCase() == '.mp3') {
        mp3Files.add(entity);
      }
    }
    if (mp3Files.isEmpty) return const [];

    final entries = <_Id3Entry>[];
    for (final file in mp3Files) {
      try {
        final tag = await ID3TagReader.path(file.path).readTag();
        final trackText = tag
            .frameWithTypeAndName<TextInformation>('TRCK')
            ?.value;
        final track = _parseTrack(trackText);
        final title = tag.title?.trim();
        if (track == null && (title == null || title.isEmpty)) {
          return const [];
        }
        entries.add(_Id3Entry(file: file, track: track, title: title));
      } catch (_) {
        return const [];
      }
    }

    final hasAnyTrack = entries.any((e) => e.track != null);
    entries.sort((a, b) {
      if (hasAnyTrack) {
        final ta = a.track ?? 1 << 30;
        final tb = b.track ?? 1 << 30;
        final cmp = ta.compareTo(tb);
        if (cmp != 0) return cmp;
      }
      return naturalCompare(p.basename(a.file.path), p.basename(b.file.path));
    });

    final chapters = <AudioChapter>[];
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final durationMs = _safeReadDurationMs(e.file);
      chapters.add(
        AudioChapter(
          index: i,
          title: (e.title?.isNotEmpty ?? false)
              ? e.title!
              : p.basenameWithoutExtension(e.file.path),
          filePath: e.file.path,
          startOffsetMs: 0,
          durationMs: durationMs,
        ),
      );
    }
    return chapters;
  }

  static int? _parseTrack(String? raw) {
    if (raw == null) return null;
    final s = raw.split('/').first.trim();
    return int.tryParse(s);
  }

  static int _safeReadDurationMs(File file) {
    try {
      final meta = amr.readMetadata(file, getImage: false);
      return meta.duration?.inMilliseconds ?? 0;
    } catch (_) {
      return 0;
    }
  }
}

class _Id3Entry {
  const _Id3Entry({required this.file, this.track, this.title});
  final File file;
  final int? track;
  final String? title;
}
