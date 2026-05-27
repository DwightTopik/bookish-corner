import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;

import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/domain/chapter_resolver.dart';

class SingleFileChapterResolver implements ChapterResolver {
  const SingleFileChapterResolver();

  @override
  Future<List<AudioChapter>> resolve(Book book) async {
    final Book(:format, :filePath, :totalDuration, :title) = book;
    if (format == .audioFolder) return const [];
    final file = File(filePath);
    if (!await file.exists()) return const [];

    int durationMs = 0;
    try {
      final meta = amr.readMetadata(file, getImage: false);
      durationMs = meta.duration?.inMilliseconds ?? 0;
    } catch (_) {}

    if (durationMs == 0 && (totalDuration ?? 0) > 0) {
      durationMs = totalDuration! * 1000;
    }

    return [
      AudioChapter(
        index: 0,
        title: title,
        filePath: filePath,
        startOffsetMs: 0,
        durationMs: durationMs,
      ),
    ];
  }
}
