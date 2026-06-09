import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/core/di/reader_providers.dart';
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
    // Используем ref.watch: подписка удерживает autoDispose-провайдер движка
    // живым на всё время жизни контроллера и пересобирает контроллер, когда
    // движок появляется (после загрузки книги).
    final engine = ref.watch(readerEngineProvider(_bookId));

    // Тот же инстанс движка — пересборка провайдера не должна ронять прогресс,
    // toc и ready: не пере-подписываемся, не пере-открываем, отдаём снимок.
    if (engine != null && identical(engine, _engine)) {
      return _last;
    }

    _engine = engine;
    if (engine == null) {
      _last = const ReaderUiState();
      return _last;
    }

    _cancelSubs();
    _progressSub = engine.progress.listen(_onProgress);
    _selectionSub = engine.selection.listen(_onSelection);
    ref.onDispose(_cancelSubs);
    unawaited(_open(engine));
    // Инициализируем настройки из глобального хранилища при первой привязке.
    final savedSettings = ref.read(readerSettingsProvider);
    _last = const ReaderUiState(settings: ReaderSettings()).copyWith(
      settings: savedSettings,
    );
    return _last;
  }

  Future<void> _open(ReaderEngine engine) async {
    try {
      await engine.open();
      if (!ref.mounted) return;
      _set(_last.copyWith(status: ReaderStatus.ready, toc: engine.toc));
    } catch (e) {
      if (!ref.mounted) return;
      _set(_last.copyWith(status: ReaderStatus.error, error: e));
    }
  }

  void _onProgress(ReaderProgress progress) {
    if (!ref.mounted) return;
    _set(_last.copyWith(progress: progress));
  }

  void _onSelection(ReaderSelection selection) {
    // A1: hook под контекстное меню выделения (задача D1).
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

  void _cancelSubs() {
    _progressSub?.cancel();
    _selectionSub?.cancel();
  }
}
