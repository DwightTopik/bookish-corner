import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;
import 'package:path/path.dart' as p;

import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/domain/chapter_resolver.dart';

class CueChapterResolver implements ChapterResolver {
  const CueChapterResolver();

  @override
  Future<List<AudioChapter>> resolve(Book book) async {
    final cueFile = await _findCue(book);
    if (cueFile == null) return const [];

    final content = await cueFile.readAsString();
    final lines = content.split(RegExp(r'\r?\n'));
    final tracks = <_CueTrack>[];
    String? currentFile;
    String? currentTitle;
    int? currentIndexMs;
    bool inTrack = false;

    void flush() {
      final file = currentFile;
      final startMs = currentIndexMs;
      if (inTrack && file != null && startMs != null) {
        tracks.add(
          _CueTrack(file: file, title: currentTitle, startMs: startMs),
        );
      }
      currentTitle = null;
      currentIndexMs = null;
      inTrack = false;
    }

    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('FILE ')) {
        final m = RegExp(r'FILE\s+"([^"]+)"').firstMatch(line);
        currentFile = m?.group(1);
      } else if (line.startsWith('TRACK ')) {
        flush();
        inTrack = true;
      } else if (inTrack && line.startsWith('TITLE ')) {
        final m = RegExp(r'TITLE\s+"([^"]+)"').firstMatch(line);
        currentTitle = m?.group(1);
      } else if (inTrack && line.startsWith('INDEX 01 ')) {
        final m = RegExp(r'INDEX\s+01\s+(\d+):(\d+):(\d+)').firstMatch(line);
        if (m != null) {
          final mm = int.parse(m.group(1)!);
          final ss = int.parse(m.group(2)!);
          final ff = int.parse(m.group(3)!);
          currentIndexMs = (mm * 60 + ss) * 1000 + (ff * 1000 ~/ 75);
        }
      }
    }
    flush();

    if (tracks.isEmpty) return const [];

    final cueDir = p.dirname(cueFile.path);
    int totalMs = 0;
    final firstFile = tracks.first.file;
    final firstPath = p.join(cueDir, firstFile);
    if (await File(firstPath).exists()) {
      totalMs = _safeReadDurationMs(File(firstPath));
    }

    final chapters = <AudioChapter>[];
    for (int i = 0; i < tracks.length; i++) {
      final t = tracks[i];
      final _CueTrack(file: trackFile, title: trackTitle, :startMs) = t;
      final next = i + 1 < tracks.length ? tracks[i + 1] : null;
      final filePath = p.join(cueDir, trackFile);
      final endMs = next != null && next.file == trackFile
          ? next.startMs
          : (totalMs > 0 ? totalMs : startMs);
      final durationMs = (endMs - startMs).clamp(0, 1 << 31);
      chapters.add(
        AudioChapter(
          index: i,
          title: trackTitle ?? 'Глава ${i + 1}',
          filePath: filePath,
          startOffsetMs: startMs,
          durationMs: durationMs,
        ),
      );
    }
    return chapters;
  }

  Future<File?> _findCue(Book book) async {
    final base = File(book.filePath);
    final candidates = <String>[];
    if (book.format == .audioFolder) {
      final dir = Directory(book.filePath);
      if (!await dir.exists()) return null;
      await for (final entity in dir.list()) {
        if (entity is File &&
            p.extension(entity.path).toLowerCase() == '.cue') {
          candidates.add(entity.path);
        }
      }
    } else {
      final dir = base.parent;
      final sibling = p.setExtension(base.path, '.cue');
      if (await File(sibling).exists()) candidates.add(sibling);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File &&
              p.extension(entity.path).toLowerCase() == '.cue' &&
              !candidates.contains(entity.path)) {
            candidates.add(entity.path);
          }
        }
      }
    }
    if (candidates.isEmpty) return null;
    return File(candidates.first);
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

class _CueTrack {
  const _CueTrack({required this.file, this.title, required this.startMs});
  final String file;
  final String? title;
  final int startMs;
}
