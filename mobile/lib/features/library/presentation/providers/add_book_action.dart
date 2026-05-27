import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/book_chapter.dart';
import 'package:bookish_corner/features/library/domain/book_format.dart';
import 'package:bookish_corner/features/library/utils/book_metadata_extractor.dart';

Future<void> pickAndAddBook(WidgetRef ref) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: BookFormat.pickerExtensions,
  );
  final pickedFile = result?.files.single;
  if (pickedFile == null || pickedFile.path == null) return;
  final PlatformFile(:path, :name, :size) = pickedFile;

  final format = BookFormat.fromExtension(p.extension(name));
  if (format == null || path == null) return;

  final id = const Uuid().v4();
  final extractor = ref.read(bookMetadataExtractorProvider);
  final meta = await extractor.extract(path, format);
  final ExtractedBookMetadata(
    title: metaTitle,
    author: metaAuthor,
    narrator: metaNarrator,
    coverBytes: metaCoverBytes,
  ) = meta;

  String? coverPath;
  if (metaCoverBytes != null) {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final coversDir = Directory(p.join(dir.path, 'covers'));
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }
      coverPath = p.join(coversDir.path, '$id.jpg');
      await File(coverPath).writeAsBytes(metaCoverBytes);
    } catch (_) {
      coverPath = null;
    }
  }

  final book = Book(
    id: id,
    title: metaTitle,
    author: metaAuthor,
    narrator: format.isAudio ? metaNarrator : null,
    filePath: path,
    format: format,
    fileSize: size,
    addedAt: DateTime.now(),
    coverImagePath: coverPath,
  );

  await ref.read(bookRepositoryProvider).addBook(book);
}

const _audioExtensions = {
  '.mp3',
  '.m4b',
  '.m4a',
  '.aac',
  '.ogg',
  '.opus',
  '.flac',
};

const _coverFileNames = {'cover.jpg', 'cover.png', 'folder.jpg', 'folder.png'};

/// Converts a SAF content URI returned by [FilePicker.getDirectoryPath] into
/// a regular filesystem path that [dart:io] can enumerate.
///
/// On Android 10+, ACTION_OPEN_DOCUMENT_TREE returns a URI like
/// `content://com.android.externalstorage.documents/tree/primary%3AMusic%2FBooks`.
/// We decode the document-ID segment (`primary:Music/Books`) and map it to
/// `/storage/emulated/0/Music/Books` for primary storage, or
/// `/storage/<volumeId>/path` for removable storage.
/// If the input is already a plain path (iOS, Desktop, some Android ROMs that
/// resolve the path themselves), it is returned unchanged.
String? _resolveDirectoryPath(String uriOrPath) {
  if (!uriOrPath.startsWith('content://')) return uriOrPath;
  try {
    // Locate the "/tree/" marker and extract everything after it.
    const marker = '/tree/';
    final idx = uriOrPath.indexOf(marker);
    if (idx < 0) return null;
    // URL-decode the document ID: "primary%3AMusic%2FBooks" → "primary:Music/Books"
    final docId = Uri.decodeComponent(uriOrPath.substring(idx + marker.length));
    final colon = docId.indexOf(':');
    if (colon < 0) return null;
    final volume = docId.substring(0, colon);
    final relative = docId.substring(colon + 1);
    final root =
        volume == 'primary' ? '/storage/emulated/0' : '/storage/$volume';
    return relative.isEmpty ? root : '$root/$relative';
  } catch (_) {
    return null;
  }
}

/// Requests the runtime storage permission appropriate for the current Android
/// version. On API ≥ 33 this is READ_MEDIA_AUDIO; on older versions it is
/// READ_EXTERNAL_STORAGE. Returns true if any relevant permission is granted.
Future<bool> _requestAudioPermission() async {
  if (!Platform.isAndroid) return true;
  // Permission.audio maps to READ_MEDIA_AUDIO on API 33+ and behaves as
  // restricted/not-applicable on lower APIs (no spurious dialog).
  final audioStatus = await Permission.audio.request();
  if (audioStatus.isGranted) return true;
  // Fallback for Android ≤ 12 where READ_MEDIA_AUDIO does not exist.
  final storageStatus = await Permission.storage.request();
  return storageStatus.isGranted;
}

Future<void> pickAndAddFolder(
  ScaffoldMessengerState messenger,
  WidgetRef ref,
) async {
  final rawPath = await FilePicker.getDirectoryPath();
  if (rawPath == null) return;

  dev.log('getDirectoryPath raw: $rawPath', name: 'pickAndAddFolder');

  // On Android 10+, FilePicker returns a SAF content URI; convert it to a
  // filesystem path so that dart:io can enumerate the directory.
  final folderPath = _resolveDirectoryPath(rawPath);
  dev.log('resolved path: $folderPath', name: 'pickAndAddFolder');

  if (folderPath == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Не удалось получить путь к папке')),
    );
    return;
  }

  // Request storage/audio permission so dart:io can read external files.
  final permitted = await _requestAudioPermission();
  if (!permitted) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Нет разрешения на чтение аудиофайлов')),
    );
    return;
  }

  List<File> audioFiles;
  try {
    audioFiles = Directory(folderPath)
        .listSync(recursive: false)
        .whereType<File>()
        .where(
          (f) => _audioExtensions.contains(p.extension(f.path).toLowerCase()),
        )
        .toList()
      ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
  } catch (e) {
    dev.log('listSync error: $e', name: 'pickAndAddFolder');
    messenger.showSnackBar(
      const SnackBar(content: Text('Не удалось прочитать содержимое папки')),
    );
    return;
  }

  final List(:length, :isEmpty, :first, :indexed) = audioFiles;
  dev.log('audio files found: $length', name: 'pickAndAddFolder');

  if (isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('В папке не найдено аудиофайлов')),
    );
    return;
  }

  final id = const Uuid().v4();
  final extractor = ref.read(bookMetadataExtractorProvider);
  final meta = await extractor.extractFromAudioFile(
    first.path,
    folderPath: folderPath,
  );
  final ExtractedBookMetadata(
    title: metaTitle,
    author: metaAuthor,
    narrator: metaNarrator,
    coverBytes: embeddedCover,
  ) = meta;

  Uint8List? coverBytes = embeddedCover;
  if (coverBytes == null) {
    for (final f in Directory(folderPath).listSync(recursive: false).whereType<File>()) {
      if (_coverFileNames.contains(p.basename(f.path).toLowerCase())) {
        try {
          coverBytes = await f.readAsBytes();
          break;
        } catch (_) {}
      }
    }
  }

  String? coverPath;
  if (coverBytes != null) {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final coversDir = Directory(p.join(dir.path, 'covers'));
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }
      coverPath = p.join(coversDir.path, '$id.jpg');
      await File(coverPath).writeAsBytes(coverBytes);
    } catch (_) {
      coverPath = null;
    }
  }

  final chapterUuid = const Uuid();
  final chapters = [
    for (final (index, file) in indexed)
      BookChapter(
        id: chapterUuid.v4(),
        bookId: id,
        position: index + 1,
        filePath: file.path,
      ),
  ];

  final book = Book(
    id: id,
    title: metaTitle,
    author: metaAuthor,
    narrator: metaNarrator,
    filePath: folderPath,
    format: BookFormat.audioFolder,
    addedAt: DateTime.now(),
    coverImagePath: coverPath,
  );

  await ref.read(bookRepositoryProvider).addBookWithChapters(book, chapters);
}
