import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/features/library/domain/reading_status.dart';
import 'package:bookish_corner/features/reader/domain/reader_bookmark.dart';
import 'package:bookish_corner/features/reader/domain/reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';
import 'package:bookish_corner/features/reader/domain/reader_progress.dart';
import 'package:bookish_corner/features/reader/domain/reader_selection.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/domain/toc_entry.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_settings_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_ui_state.dart';

/// Контроллер экрана ридера. Family по `bookId`, авто-dispose при уходе с
/// экрана. Делегирует навигацию активному [ReaderEngine] (полученному через
/// `readerEngineProvider`, который сам резолвит книгу и владеет движком) и
/// отражает его поток позиции в [ReaderUiState]. Пока движок `null` (книга не
/// загружена) — остаётся в `loading`.
final readerControllerProvider =
    NotifierProvider.family<ReaderControllerNotifier, ReaderUiState, String>(
      ReaderControllerNotifier.new,
      isAutoDispose: true,
    );

class ReaderControllerNotifier extends Notifier<ReaderUiState> {
  ReaderControllerNotifier(this._bookId);

  final String _bookId;

  ReaderEngine? _engine;
  StreamSubscription<ReaderProgress>? _progressSub;
  StreamSubscription<ReaderSelection>? _selectionSub;
  StreamSubscription<List<ReaderBookmark>>? _bookmarkSub;
  List<ReaderBookmark> _bookmarks = [];
  Timer? _saveTimer;

  // Последнее известное состояние. Держим отдельно, чтобы при бенайн-пересборке
  // build (тот же инстанс движка) вернуть накопленный снимок, а не сбрасывать
  // экран в loading с пустым toc.
  ReaderUiState _last = const ReaderUiState();

  /// Единая точка записи состояния: синхронизирует `state` и [_last].
  void _set(ReaderUiState next) {
    _last = next;
    state = next;
  }

  @override
  ReaderUiState build() {
    final engine = ref.watch(readerEngineProvider(_bookId));

    // 1. Отменить ВСЕ старые подписки (incl. _bookmarkSub).
    _cancelSubs();

    // 2. Всегда создаём свежую подписку на закладки (engine-independent).
    final repo = ref.read(readerBookmarkRepositoryProvider);
    _bookmarkSub = repo.watchBookmarks(_bookId).listen(_onBookmarks);

    // 3. Регистрируем dispose.
    ref.onDispose(_cancelSubs);

    // 4. Identical early return: движок тот же, но _cancelSubs() убил engine-subs —
    //    пере-подписываемся на них тоже, иначе progress перестанет обновлять UI.
    if (engine != null && identical(engine, _engine)) {
      _progressSub = engine.progress.listen(_onProgress);
      _selectionSub = engine.selection.listen(_onSelection);
      return _last;
    }

    _engine = engine;
    if (engine == null) {
      _last = const ReaderUiState();
      return _last;
    }

    _progressSub = engine.progress.listen(_onProgress);
    _selectionSub = engine.selection.listen(_onSelection);
    // Инициализируем настройки из глобального хранилища при первой привязке.
    final savedSettings = ref.read(readerSettingsProvider);
    _last = const ReaderUiState(settings: ReaderSettings()).copyWith(
      settings: savedSettings,
    );
    unawaited(_open(engine));
    return _last;
  }

  Future<void> _open(ReaderEngine engine) async {
    try {
      await engine.open();
      if (!ref.mounted) return;
      _set(_last.copyWith(status: .ready, toc: engine.toc));
      // Восстановить позицию из Drift: если есть сохранённый anchor → goTo
      // (мгновенный jump без анимации). Пока вью не смонтирована, jumpToOffset
      // сохранится как pendingJump в Fb2RenderController и будет применён
      // в _bindEngine() через post-frame callback.
      final saved = await ref
          .read(readerProgressRepositoryProvider)
          .getProgress(_bookId);
      if (!ref.mounted) return;
      if (saved != null &&
          saved.anchor.isNotEmpty &&
          saved.anchor != '0:0') {
        await engine.goTo(saved);
      }
    } catch (e) {
      if (!ref.mounted) return;
      _set(_last.copyWith(status: .error, error: e));
    }
  }

  void _onProgress(ReaderProgress progress) {
    if (!ref.mounted) return;
    final charOffset = _charOffsetFromAnchor(progress.locator.anchor);
    final isBookmarked =
        charOffset >= 0 && _bookmarks.any((b) => b.charOffset == charOffset);
    _set(_last.copyWith(progress: progress, isBookmarked: isBookmarked));
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1500), () {
      _saveProgressToDrift(progress.locator);
    });
  }

  Future<void> _saveProgressToDrift(ReaderLocator locator) async {
    if (!ref.mounted) return;
    await ref.read(readerProgressRepositoryProvider).saveProgress(_bookId, locator);
    if (!ref.mounted) return;
    if (locator.progress > 0) {
      await ref.read(bookRepositoryProvider).updateProgress(
        _bookId, locator.progress, locator.anchor);
      if (!ref.mounted) return;
      await ref.read(bookRepositoryProvider).updateStatus(
        _bookId, ReadingStatus.reading);
    }
  }

  void _onSelection(ReaderSelection selection) {
    // A1: hook под контекстное меню выделения (задача D1).
  }

  void _onBookmarks(List<ReaderBookmark> bookmarks) {
    if (!ref.mounted) return;
    _bookmarks = bookmarks;
    final charOffset =
        _charOffsetFromAnchor(_last.progress?.locator.anchor ?? '');
    final isBookmarked =
        charOffset >= 0 && bookmarks.any((b) => b.charOffset == charOffset);
    _set(_last.copyWith(isBookmarked: isBookmarked));
  }

  // --- Intent-методы (дёргаются из chrome, B2) ---

  void toggleChrome() =>
      _set(_last.copyWith(chromeVisible: !_last.chromeVisible));

  Future<void> nextPage() async => _engine?.nextPage();

  Future<void> prevPage() async => _engine?.prevPage();

  /// Перемотка слайдером: якоря нет, движок резолвит позицию по [progress].
  Future<void> seekTo(double progress) async =>
      _engine?.goTo(ReaderLocator(progress: progress, anchor: ''));

  Future<void> goToToc(TocEntry entry) async => _engine?.goTo(entry.anchor);

  Future<void> updateSettings(ReaderSettings settings) async {
    _set(_last.copyWith(settings: settings));
    unawaited(ref.read(readerSettingsProvider.notifier).save(settings));
    await _engine?.applySettings(settings);
  }

  Future<void> toggleBookmark() async {
    final anchor = _last.progress?.locator.anchor ?? '';
    final charOffset = _charOffsetFromAnchor(anchor);
    if (charOffset < 0) return;

    final repo = ref.read(readerBookmarkRepositoryProvider);
    final existing =
        _bookmarks.where((b) => b.charOffset == charOffset).firstOrNull;
    if (existing != null) {
      await repo.removeBookmark(existing.id);
    } else {
      await repo.addBookmark(
        ReaderBookmark(
          id: const Uuid().v4(),
          bookId: _bookId,
          charOffset: charOffset,
          chapterIndex: _last.progress?.locator.chapterIndex,
          previewText: _engine?.currentPagePreview() ?? '',
          createdAt: DateTime.now(),
        ),
      );
    }
    // isBookmarked обновится через watchBookmarks stream
  }

  // --- Вспомогательные ---

  /// Извлекает charOffset из якоря формата `"ci:offset"` (FB2/TXT).
  /// Возвращает -1 для пустого/нераспознанного якоря — сигнал "нет позиции".
  int _charOffsetFromAnchor(String anchor) {
    if (anchor.isEmpty) return -1;
    final parts = anchor.split(':');
    if (parts.length == 2) return int.tryParse(parts[1]) ?? -1;
    return -1;
  }

  void _cancelSubs() {
    _progressSub?.cancel();
    _selectionSub?.cancel();
    _bookmarkSub?.cancel();
    _saveTimer?.cancel();
  }
}
