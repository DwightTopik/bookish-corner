import 'dart:io';
import 'dart:developer' as dev;

import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import 'package:bookish_corner/features/book_details/data/info_txt_metadata_parser.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_diagnostics.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';
import 'package:bookish_corner/features/library/domain/book.dart';

class InfoTxtMetadataSource {
  const InfoTxtMetadataSource(this._parser);

  final InfoTxtMetadataParser _parser;
  static Future<PermissionStatus>? _activeManageStorageRequest;
  static bool _manageStorageRequestAttempted = false;

  Future<BookDetailsMetadata?> read(Book book) async {
    final diagnostics = await inspect(book);
    return diagnostics.metadata;
  }

  Future<InfoTxtLookupDiagnostics> inspect(Book book) async {
    try {
      final directories = await _candidateDirectories(book.filePath);
      final candidateSet = await _candidateFiles(book.filePath, directories);
      final candidates = candidateSet.existingFiles;
      final candidatePaths = candidateSet.checkedPaths;
      dev.log(
        'info.txt candidates for ${book.id}: ${candidatePaths.join(' | ')}',
        name: 'InfoTxtMetadataSource',
      );
      if (candidates.isEmpty) {
        dev.log(
          'No info.txt found for ${book.id}',
          name: 'InfoTxtMetadataSource',
        );
        return InfoTxtLookupDiagnostics(
          candidatePaths: candidatePaths,
          found: false,
          readSucceeded: false,
          parseSucceeded: false,
        );
      }
      InfoTxtLookupDiagnostics? fallback;
      for (final infoFile in candidates) {
        String content;
        try {
          content = await _readTextWithPermissionRetry(infoFile);
        } catch (error, stackTrace) {
          dev.log(
            'Failed to read metadata txt: ${infoFile.path}',
            name: 'InfoTxtMetadataSource',
            error: error,
            stackTrace: stackTrace,
          );
          fallback ??= InfoTxtLookupDiagnostics(
            candidatePaths: candidatePaths,
            found: true,
            foundPath: infoFile.path,
            readSucceeded: false,
            parseSucceeded: false,
            errorSummary: error.toString(),
          );
          continue;
        }

        try {
          final metadata = _parser.parse(content);
          final summary = MetadataDebugSummary.fromMetadata(metadata);
          final MetadataDebugSummary(
            :hasDescription,
            :genresCount,
            :contentsCount,
            :visibleFieldCount,
          ) = summary;
          dev.log(
            'metadata txt parsed for ${book.id}: path=${infoFile.path}, '
            'description=$hasDescription, genres=$genresCount, '
            'contents=$contentsCount, fields=$visibleFieldCount',
            name: 'InfoTxtMetadataSource',
          );
          final diagnostics = InfoTxtLookupDiagnostics(
            candidatePaths: candidatePaths,
            found: true,
            foundPath: infoFile.path,
            readSucceeded: true,
            parseSucceeded: true,
            metadata: metadata,
          );
          if (visibleFieldCount > 0) return diagnostics;
          fallback ??= diagnostics;
        } catch (error, stackTrace) {
          dev.log(
            'Failed to parse metadata txt: ${infoFile.path}',
            name: 'InfoTxtMetadataSource',
            error: error,
            stackTrace: stackTrace,
          );
          fallback ??= InfoTxtLookupDiagnostics(
            candidatePaths: candidatePaths,
            found: true,
            foundPath: infoFile.path,
            readSucceeded: true,
            parseSucceeded: false,
            errorSummary: error.toString(),
          );
        }
      }
      return fallback ??
          InfoTxtLookupDiagnostics(
            candidatePaths: candidatePaths,
            found: false,
            readSucceeded: false,
            parseSucceeded: false,
          );
    } catch (error, stackTrace) {
      dev.log(
        'Failed to read nearby info.txt for ${book.filePath}',
        name: 'InfoTxtMetadataSource',
        error: error,
        stackTrace: stackTrace,
      );
      return InfoTxtLookupDiagnostics(
        candidatePaths: const [],
        found: false,
        readSucceeded: false,
        parseSucceeded: false,
        errorSummary: error.toString(),
      );
    }
  }

  Future<String> _readTextWithPermissionRetry(File file) async {
    try {
      return await file.readAsString();
    } on FileSystemException catch (error, stackTrace) {
      if (!_isPermissionDenied(error) || !Platform.isAndroid) rethrow;
      dev.log(
        'Requesting Android all-files access for metadata text: ${file.path}',
        name: 'InfoTxtMetadataSource',
      );
      final status = await _requestManageStorageOnce();
      if (!status.isGranted) Error.throwWithStackTrace(error, stackTrace);
      return await file.readAsString();
    }
  }

  Future<PermissionStatus> _requestManageStorageOnce() async {
    final current = await Permission.manageExternalStorage.status;
    if (current.isGranted) return current;

    final active = _activeManageStorageRequest;
    if (active != null) {
      dev.log(
        'Waiting for active Android all-files permission request',
        name: 'InfoTxtMetadataSource',
      );
      return active;
    }

    if (_manageStorageRequestAttempted) {
      dev.log(
        'Android all-files permission was already requested this session',
        name: 'InfoTxtMetadataSource',
      );
      return current;
    }

    _manageStorageRequestAttempted = true;
    final request = Permission.manageExternalStorage.request();
    _activeManageStorageRequest = request;
    try {
      return await request;
    } finally {
      _activeManageStorageRequest = null;
    }
  }

  bool _isPermissionDenied(FileSystemException error) {
    return error.osError?.errorCode == 13 ||
        error.message.toLowerCase().contains('permission denied');
  }

  Future<List<Directory>> _candidateDirectories(String path) async {
    final directories = <String>[];
    void add(String value) {
      if (value.trim().isEmpty || value.startsWith('content://')) return;
      if (!directories.contains(value)) directories.add(value);
    }

    final type = await FileSystemEntity.type(path);
    if (type == .directory) add(path);
    if (type == .file) add(File(path).parent.path);
    final parent = p.dirname(path);
    if (parent != path) add(parent);
    return [for (final directory in directories) Directory(directory)];
  }

  Future<_CandidateTextFiles> _candidateFiles(
    String bookPath,
    List<Directory> directories,
  ) async {
    final byPath = <String, File>{};
    void addPath(String path) {
      if (path.trim().isEmpty || path.startsWith('content://')) return;
      byPath.putIfAbsent(path, () => File(path));
    }

    final baseName = p.basenameWithoutExtension(bookPath).trim();
    final parentName = p.basename(p.dirname(bookPath)).trim();

    for (final directory in directories) {
      for (final name in _infoFileNames) {
        addPath(p.join(directory.path, name));
      }
      for (final name in [baseName, parentName]) {
        if (name.isEmpty) continue;
        addPath(p.join(directory.path, '$name.txt'));
      }
    }

    for (final directory in directories) {
      if (!await directory.exists()) continue;
      try {
        await for (final entity in directory.list(recursive: false)) {
          if (entity is! File) continue;
          final extension = p.extension(entity.path).toLowerCase();
          if (extension != '.txt') continue;
          addPath(entity.path);
        }
      } catch (error, stackTrace) {
        dev.log(
          'Failed to list candidate text files: ${directory.path}',
          name: 'InfoTxtMetadataSource',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    final existing = <File>[];
    for (final file in byPath.values) {
      try {
        if (await file.exists()) existing.add(file);
      } catch (_) {}
    }
    return _CandidateTextFiles(
      checkedPaths: byPath.keys.toList(),
      existingFiles: existing,
    );
  }

  static const _infoFileNames = {
    'info.txt',
    'инфо.txt',
    'информация.txt',
    'описание.txt',
  };
}

class _CandidateTextFiles {
  const _CandidateTextFiles({
    required this.checkedPaths,
    required this.existingFiles,
  });

  final List<String> checkedPaths;
  final List<File> existingFiles;
}
