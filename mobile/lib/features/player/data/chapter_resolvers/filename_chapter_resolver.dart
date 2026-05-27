import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;
import 'package:path/path.dart' as p;

import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/data/chapter_resolvers/natural_sort.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/domain/chapter_resolver.dart';

class FilenameChapterResolver implements ChapterResolver {
  const FilenameChapterResolver();

  static const _audioExtensions = {'.mp3', '.m4a', '.m4b', '.ogg', '.flac'};

  @override
  Future<List<AudioChapter>> resolve(Book book) async {
    if (book.format != .audioFolder) return const [];
    final dir = Directory(book.filePath);
    if (!await dir.exists()) return const [];

    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File &&
          _audioExtensions.contains(p.extension(entity.path).toLowerCase())) {
        files.add(entity);
      }
    }
    if (files.isEmpty) return const [];

    files.sort(
      (a, b) => naturalCompare(p.basename(a.path), p.basename(b.path)),
    );

    final chapters = <AudioChapter>[];
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final name = p.basenameWithoutExtension(file.path);
      final title = _cleanTitle(name);
      final durationMs = _safeReadDurationMs(file);
      chapters.add(
        AudioChapter(
          index: i,
          title: title,
          filePath: file.path,
          startOffsetMs: 0,
          durationMs: durationMs,
        ),
      );
    }
    return chapters;
  }

  static String _cleanTitle(String raw) {
    String s = raw.replaceAll(RegExp(r'[_\.]+'), ' ').trim();
    s = s.replaceFirst(RegExp(r'^[\d\s\-\.]+'), '').trim();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.isEmpty ? raw : s;
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
