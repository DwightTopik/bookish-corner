import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;

import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/domain/chapter_resolver.dart';

class M4bChapterResolver implements ChapterResolver {
  const M4bChapterResolver();

  static const _containerBoxes = {'moov', 'udta', 'trak', 'mdia', 'minf'};

  @override
  Future<List<AudioChapter>> resolve(Book book) async {
    final Book(:format, :filePath) = book;
    if (format != .m4b) return const [];
    final file = File(filePath);
    if (!await file.exists()) return const [];

    final bytes = await file.readAsBytes();
    final chpl = _findBox(bytes, 0, bytes.length, 'chpl');
    if (chpl == null) return const [];

    final chapters = _parseChpl(bytes, chpl.start, chpl.end);
    if (chapters.isEmpty) return const [];

    final totalMs = _safeReadDurationMs(file, book);
    return [
      for (int i = 0; i < chapters.length; i++)
        AudioChapter(
          index: i,
          title: chapters[i].title.isEmpty
              ? 'Глава ${i + 1}'
              : chapters[i].title,
          filePath: filePath,
          startOffsetMs: chapters[i].startMs,
          durationMs: _chapterDurationMs(chapters, i, totalMs),
        ),
    ];
  }

  _BoxRange? _findBox(Uint8List bytes, int start, int end, String target) {
    int offset = start;
    while (offset + 8 <= end) {
      final size32 = _uint32(bytes, offset);
      final type = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));
      int header = 8;
      int size = size32;
      if (size32 == 1 && offset + 16 <= end) {
        size = _uint64(bytes, offset + 8);
        header = 16;
      } else if (size32 == 0) {
        size = end - offset;
      }
      if (size < header || offset + size > end) break;

      final payloadStart = offset + header;
      final payloadEnd = offset + size;
      if (type == target) return _BoxRange(payloadStart, payloadEnd);
      if (_containerBoxes.contains(type)) {
        final nested = _findBox(bytes, payloadStart, payloadEnd, target);
        if (nested != null) return nested;
      }
      offset += size;
    }
    return null;
  }

  List<_M4bChapter> _parseChpl(Uint8List bytes, int start, int end) {
    if (start + 5 > end) return const [];
    int offset = start + 4;
    final chapterCount = _readChapterCount(bytes, offset);
    offset++;

    final chapters = <_M4bChapter>[];
    for (int i = 0; i < chapterCount && offset + 9 <= end; i++) {
      final start100Ns = _uint64(bytes, offset);
      offset += 8;
      final titleLength = _readTitleLength(bytes, offset);
      offset++;
      if (offset + titleLength > end) break;
      final title = String.fromCharCodes(
        bytes.sublist(offset, offset + titleLength),
      );
      offset += titleLength;
      chapters.add(_M4bChapter(title: title, startMs: start100Ns ~/ 10000));
    }
    chapters.sort((a, b) => a.startMs.compareTo(b.startMs));
    return chapters;
  }

  int _chapterDurationMs(List<_M4bChapter> chapters, int index, int totalMs) {
    if (index + 1 < chapters.length) {
      return (chapters[index + 1].startMs - chapters[index].startMs).clamp(
        0,
        1 << 31,
      );
    }
    if (totalMs <= chapters[index].startMs) return 0;
    return totalMs - chapters[index].startMs;
  }

  int _safeReadDurationMs(File file, Book book) {
    try {
      final meta = amr.readMetadata(file, getImage: false);
      return meta.duration?.inMilliseconds ?? (book.totalDuration ?? 0) * 1000;
    } catch (_) {
      return (book.totalDuration ?? 0) * 1000;
    }
  }

  int _uint32(Uint8List bytes, int offset) {
    return ByteData.sublistView(
      bytes,
      offset,
      offset + 4,
    ).getUint32(0, Endian.big);
  }

  int _readChapterCount(Uint8List bytes, int offset) {
    return ByteData.sublistView(bytes, offset, offset + 1).getUint8(0);
  }

  int _readTitleLength(Uint8List bytes, int offset) {
    return ByteData.sublistView(bytes, offset, offset + 1).getUint8(0);
  }

  int _uint64(Uint8List bytes, int offset) {
    final data = ByteData.sublistView(bytes, offset, offset + 8);
    final high = data.getUint32(0, Endian.big);
    final low = data.getUint32(4, Endian.big);
    return (high << 32) | low;
  }
}

class _BoxRange {
  const _BoxRange(this.start, this.end);

  final int start;
  final int end;
}

class _M4bChapter {
  const _M4bChapter({required this.title, required this.startMs});

  final String title;
  final int startMs;
}
