import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:just_audio/just_audio.dart'
    show AudioPlayer, AudioSource, ConcatenatingAudioSource;
import 'package:just_audio_background/just_audio_background.dart';

import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/book_chapter.dart';
import 'package:bookish_corner/features/library/domain/book_repository.dart';
import 'package:bookish_corner/features/player/domain/audio_bookmark.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/domain/audio_progress.dart';
import 'package:bookish_corner/features/player/domain/audio_progress_repository.dart';
import 'package:bookish_corner/features/player/domain/chapter_resolver.dart';
import 'package:bookish_corner/features/player/domain/sleep_timer_option.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_state.dart';

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);

final playerBookProvider = StreamProvider.family<Book?, String>((ref, bookId) {
  return ref.watch(bookRepositoryProvider).watchBookById(bookId);
});

final audioBookmarksProvider =
    StreamProvider.family<List<AudioBookmark>, String>((ref, bookId) {
      return ref.watch(audioBookmarkRepositoryProvider).watchBookmarks(bookId);
    });

class PlayerNotifier extends Notifier<PlayerState> {
  static const _resumePreroll = Duration(seconds: 2);

  AudioPlayer? _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<ja.PlayerState>? _stateSub;
  StreamSubscription<int?>? _indexSub;
  Timer? _autoSaveTimer;
  Timer? _sleepTimer;
  Timer? _sleepTickTimer;
  bool _endOfChapterPending = false;
  bool _sleepPaused = false;

  ChapterResolver get _resolver => ref.read(chapterResolverProvider);
  AudioProgressRepository get _progressRepo =>
      ref.read(audioProgressRepositoryProvider);
  BookRepository get _bookRepo => ref.read(bookRepositoryProvider);

  @override
  PlayerState build() {
    ref.onDispose(_dispose);
    return const PlayerState();
  }

  Future<void> loadBook(Book book) async {
    if (state.book?.id == book.id && _player != null) return;

    state = const PlayerState().copyWith(book: book, loading: true);

    final chapters = await _loadChapters(book);
    if (!ref.mounted) return;
    if (chapters.isEmpty) {
      state = state.copyWith(loading: false);
      return;
    }

    await _ensurePlayer();
    if (!ref.mounted) return;
    final player = _player!;

    final source = _buildSource(book, chapters);
    try {
      await player.setAudioSource(source);
    } catch (_) {}
    if (!ref.mounted) return;

    final saved = await _progressRepo.getProgress(book.id);
    if (!ref.mounted) return;
    int initialIndex = 0;
    Duration initialPos = .zero;
    if (saved != null) {
      initialIndex = saved.chapterIndex.clamp(0, chapters.length - 1);
      initialPos = _positionWithResumePreroll(saved.position);
    }

    if (_isSingleSource(chapters)) {
      final absolute = chapters[initialIndex].start + initialPos;
      await player.seek(absolute);
    } else {
      await player.seek(initialPos, index: initialIndex);
    }
    if (!ref.mounted) return;

    final duration = player.duration;
    state = state.copyWith(
      chapters: chapters,
      chapterIndex: initialIndex,
      position: initialPos,
      loading: false,
      chapterDurationOverride: _canUsePlayerDuration(chapters)
          ? duration
          : null,
      clearChapterDurationOverride: !_canUsePlayerDuration(chapters),
    );

    _startAutoSave();
    _captureCurrentDuration();
  }

  Future<void> _ensurePlayer() async {
    if (_player != null) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    if (!ref.mounted) return;
    final player = AudioPlayer();
    _player = player;
    _positionSub = player.positionStream.listen(_onPosition);
    _durationSub = player.durationStream.listen(_onDuration);
    _stateSub = player.playerStateStream.listen(_onPlayerState);
    _indexSub = player.currentIndexStream.listen(_onIndex);
  }

  Duration _positionWithResumePreroll(Duration position) {
    if (position <= _resumePreroll) return .zero;
    return position - _resumePreroll;
  }

  Future<List<AudioChapter>> _loadChapters(Book book) async {
    final cached = await _bookRepo.getChapters(book.id);
    if (!ref.mounted) return const [];
    if (cached.isNotEmpty) {
      final normalizedCached = _normalizeChapters(
        cached.map(AudioChapter.fromBookChapter).toList(),
      );
      if (!_needsChapterRefresh(normalizedCached)) {
        return normalizedCached;
      }
      final refreshed = await _resolver.resolve(book);
      if (!ref.mounted) return normalizedCached;
      if (refreshed.isEmpty) return normalizedCached;
      final normalizedRefreshed = _normalizeChapters(refreshed);
      await _persistChapters(book.id, normalizedRefreshed);
      if (!ref.mounted) return normalizedRefreshed;
      return normalizedRefreshed;
    }
    final resolved = await _resolver.resolve(book);
    if (!ref.mounted) return const [];
    if (resolved.isNotEmpty) {
      final normalized = _normalizeChapters(resolved);
      await _persistChapters(book.id, normalized);
      if (!ref.mounted) return normalized;
      return normalized;
    }
    return const [];
  }

  Future<void> _persistChapters(
    String bookId,
    List<AudioChapter> chapters,
  ) async {
    await _bookRepo.replaceChapters(bookId, [
      for (final AudioChapter(
            :index,
            :filePath,
            :title,
            :durationMs,
            :startOffsetMs,
          )
          in chapters)
        BookChapter(
          id: '$bookId-$index',
          bookId: bookId,
          position: index,
          filePath: filePath,
          title: title,
          duration: durationMs > 0 ? durationMs ~/ 1000 : null,
          startOffsetMs: startOffsetMs,
        ),
    ]);
  }

  bool _needsChapterRefresh(List<AudioChapter> chapters) {
    return chapters.any(
      (chapter) =>
          chapter.durationMs <= 0 || _isGenericChapterTitle(chapter.title),
    );
  }

  List<AudioChapter> _normalizeChapters(List<AudioChapter> chapters) {
    final sorted = [...chapters]
      ..sort((a, b) {
        final byIndex = a.index.compareTo(b.index);
        if (byIndex != 0) return byIndex;
        return a.filePath.compareTo(b.filePath);
      });
    return [
      for (final (displayIndex, chapter) in sorted.indexed)
        if (_isGenericChapterTitle(chapter.title))
          chapter.copyWith(
            index: displayIndex,
            title: 'Глава ${displayIndex + 1}',
          )
        else
          chapter.copyWith(index: displayIndex),
    ];
  }

  bool _isGenericChapterTitle(String title) {
    return RegExp(
      r'^\s*глава\s+\d+\s*$',
      caseSensitive: false,
      unicode: true,
    ).hasMatch(title);
  }

  bool _isSingleSource(List<AudioChapter> chapters) {
    if (chapters.length <= 1) return true;
    final first = chapters.first.filePath;
    for (final c in chapters) {
      if (c.filePath != first) return false;
    }
    return true;
  }

  bool _canUsePlayerDuration(List<AudioChapter> chapters) {
    return !_isSingleSource(chapters) || chapters.length == 1;
  }

  AudioSource _buildSource(Book book, List<AudioChapter> chapters) {
    if (_isSingleSource(chapters)) {
      return AudioSource.file(
        chapters.first.filePath,
        tag: _mediaItem(book, chapters.first),
      );
    }
    return ConcatenatingAudioSource(
      children: [
        for (final c in chapters)
          AudioSource.file(c.filePath, tag: _mediaItem(book, c)),
      ],
    );
  }

  MediaItem _mediaItem(Book book, AudioChapter chapter) {
    final Book(:id, :title, :author, :coverImagePath) = book;
    final AudioChapter(:index, title: chapterTitle, :duration) = chapter;
    return MediaItem(
      id: '$id#$index',
      album: title,
      title: chapterTitle,
      artist: author,
      duration: duration,
      artUri: coverImagePath != null ? Uri.file(coverImagePath) : null,
    );
  }

  void _onPosition(Duration p) {
    if (!ref.mounted || !_isReady) return;
    final chapters = state.chapters;
    if (chapters.isEmpty) return;
    if (_isSingleSource(chapters)) {
      final currentIndex = state.chapterIndex.clamp(0, chapters.length - 1);
      if (_endOfChapterPending &&
          _hasReachedSingleSourceChapterEnd(p, currentIndex, chapters)) {
        final current = chapters[currentIndex];
        final rel = _clampDuration(p - current.start, current.duration);
        state = state.copyWith(chapterIndex: currentIndex, position: rel);
        _triggerSleepAtChapterEnd();
        return;
      }
      final idx = _findChapterAt(p, chapters);
      final rel = p - chapters[idx].start;
      final wasChapter = state.chapterIndex;
      state = state.copyWith(
        chapterIndex: idx,
        position: _clampDuration(rel, chapters[idx].duration),
      );
      if (_endOfChapterPending && idx != wasChapter) {
        _triggerSleepAtChapterEnd();
      }
    } else {
      final duration = state.chapterDuration;
      final position = duration > .zero ? _clampDuration(p, duration) : p;
      state = state.copyWith(position: position);
      if (_endOfChapterPending && duration > .zero && p >= duration) {
        _triggerSleepAtChapterEnd();
      }
    }
  }

  void _onDuration(Duration? duration) {
    if (!ref.mounted || !_isReady || duration == null || duration <= .zero) {
      return;
    }
    if (_syncSingleSourceFinalDuration(duration)) return;
    if (!_canUsePlayerDuration(state.chapters)) {
      state = state.copyWith(clearChapterDurationOverride: true);
      return;
    }
    state = state.withCurrentChapterDuration(duration);
  }

  bool _syncSingleSourceFinalDuration(Duration sourceDuration) {
    final chapters = state.chapters;
    if (!_isSingleSource(chapters) || chapters.length <= 1) return false;
    final totalMs = sourceDuration.inMilliseconds;
    final last = chapters.last;
    final correctedMs = totalMs - last.startOffsetMs;
    if (correctedMs <= 0 || correctedMs == last.durationMs) {
      state = state.copyWith(clearChapterDurationOverride: true);
      return true;
    }
    final updated = [...chapters];
    updated[updated.length - 1] = last.copyWith(durationMs: correctedMs);
    state = state.copyWith(
      chapters: updated,
      clearChapterDurationOverride: true,
    );
    return true;
  }

  bool _hasReachedSingleSourceChapterEnd(
    Duration absolutePosition,
    int index,
    List<AudioChapter> chapters,
  ) {
    final chapter = chapters[index];
    final end = index + 1 < chapters.length
        ? chapters[index + 1].start
        : chapter.start + chapter.duration;
    return end > chapter.start && absolutePosition >= end;
  }

  Duration _clampDuration(Duration value, Duration max) {
    if (value.isNegative) return .zero;
    if (max > .zero && value > max) return max;
    return value;
  }

  int _findChapterAt(Duration p, List<AudioChapter> chapters) {
    final ms = p.inMilliseconds;
    int idx = 0;
    for (int i = 0; i < chapters.length; i++) {
      final start = chapters[i].startOffsetMs;
      final end = i + 1 < chapters.length
          ? chapters[i + 1].startOffsetMs
          : start + chapters[i].durationMs;
      if (ms >= start && ms < end) return i;
      if (ms >= start) idx = i;
    }
    return idx;
  }

  void _onPlayerState(ja.PlayerState ps) {
    if (!ref.mounted) return;
    if (_sleepPaused && ps.playing) {
      _player?.pause();
      return;
    }
    if (ps.processingState == .completed) {
      state = _completedState();
      _saveProgress();
      return;
    }
    state = state.copyWith(playing: ps.playing);
  }

  PlayerState _completedState() {
    final chapters = state.chapters;
    if (chapters.isEmpty) return state.copyWith(playing: false);
    final lastIndex = chapters.length - 1;
    return state.copyWith(
      chapterIndex: lastIndex,
      position: chapters[lastIndex].duration,
      playing: false,
    );
  }

  void _onIndex(int? index) {
    if (!ref.mounted || index == null) return;
    if (_isSingleSource(state.chapters)) return;
    final clamped = index.clamp(0, state.chapters.length - 1);
    final was = state.chapterIndex;
    state = state.copyWith(
      chapterIndex: clamped,
      position: clamped != was ? .zero : state.position,
    );
    final duration = _player?.duration;
    if (_canUsePlayerDuration(state.chapters) &&
        duration != null &&
        duration > .zero) {
      state = state.withCurrentChapterDuration(duration);
    } else {
      state = state.copyWith(clearChapterDurationOverride: true);
    }
    if (_endOfChapterPending && clamped != was) {
      _triggerSleepAtChapterEnd();
    }
  }

  bool get _isReady => _player != null && state.chapters.isNotEmpty;

  Future<void> play() async {
    if (!_isReady) return;
    _sleepPaused = false;
    await _player!.play();
  }

  Future<void> pause() async {
    if (!_isReady) return;
    await _player!.pause();
    if (!ref.mounted) return;
    await _saveProgress();
  }

  Future<void> togglePlay() async {
    if (state.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (!_isReady) return;
    await _seekToChapterPosition(state.chapterIndex, position);
  }

  Future<void> seekBy(Duration delta) async {
    if (!_isReady) return;
    final newPos = state.position + delta;
    if (newPos.isNegative) {
      await seekTo(.zero);
    } else if (newPos > state.chapterDuration) {
      await seekTo(state.chapterDuration);
    } else {
      await seekTo(newPos);
    }
  }

  Future<void> previousChapter() async {
    if (!_isReady) return;
    final chapterIndex = state.chapterIndex;
    final position = state.position;
    final chapters = state.chapters;
    if (position.inSeconds > 3) {
      await seekTo(.zero);
      return;
    }
    if (chapterIndex == 0) {
      await seekTo(.zero);
      return;
    }
    final next = chapterIndex - 1;
    if (_isSingleSource(chapters)) {
      await _player!.seek(chapters[next].start);
    } else {
      await _player!.seek(.zero, index: next);
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      chapterIndex: next,
      position: .zero,
      clearChapterDurationOverride: true,
    );
    _captureCurrentDuration();
  }

  Future<void> nextChapter() async {
    if (!_isReady) return;
    final chapterIndex = state.chapterIndex;
    final chapters = state.chapters;
    if (chapterIndex >= chapters.length - 1) return;
    final next = chapterIndex + 1;
    if (_isSingleSource(chapters)) {
      await _player!.seek(chapters[next].start);
    } else {
      await _player!.seek(.zero, index: next);
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      chapterIndex: next,
      position: .zero,
      clearChapterDurationOverride: true,
    );
    _captureCurrentDuration();
  }

  Future<void> jumpToChapter(int index) async {
    if (!_isReady) return;
    await _seekToChapterPosition(index, .zero);
  }

  Future<void> seekToBookmark(AudioBookmark bookmark) async {
    if (!_isReady) return;
    await _seekToChapterPosition(bookmark.chapterIndex, bookmark.position);
  }

  Future<void> _seekToChapterPosition(
    int chapterIndex,
    Duration position,
  ) async {
    final chapters = state.chapters;
    if (_player == null || chapters.isEmpty) return;
    final clamped = chapterIndex.clamp(0, chapters.length - 1);
    final chapter = chapters[clamped];
    final target = _clampDuration(position, chapter.duration);
    if (_isSingleSource(chapters)) {
      await _player!.seek(chapter.start + target);
    } else {
      await _player!.seek(target, index: clamped);
    }
    if (!ref.mounted) return;
    final changedChapter = clamped != state.chapterIndex;
    state = state.copyWith(
      chapterIndex: clamped,
      position: target,
      clearChapterDurationOverride: changedChapter,
    );
    if (changedChapter) {
      _captureCurrentDuration();
    }
  }

  void _captureCurrentDuration() {
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (!ref.mounted || !_isReady) {
        return;
      }
      final duration = _player?.duration;
      if (duration != null && duration > .zero) {
        if (_syncSingleSourceFinalDuration(duration)) return;
        if (_canUsePlayerDuration(state.chapters)) {
          state = state.withCurrentChapterDuration(duration);
        }
      }
    });
  }

  Future<void> setSpeed(double speed) async {
    if (_player == null) return;
    await _player!.setSpeed(speed);
    if (!ref.mounted) return;
    state = state.copyWith(speed: speed);
  }

  void setSleepTimer(SleepTimerOption option) {
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();
    _endOfChapterPending = false;

    switch (option) {
      case SleepTimerOff():
        state = state.copyWith(sleepTimer: option, clearSleepRemaining: true);
      case SleepTimerEndOfChapter():
        _endOfChapterPending = true;
        state = state.copyWith(
          sleepTimer: option,
          sleepRemaining: state.remainingInChapter,
        );
        _startSleepCountdownToChapterEnd();
      case SleepTimerDuration(:final duration):
        state = state.copyWith(sleepTimer: option, sleepRemaining: duration);
        _sleepTimer = Timer(duration, () async {
          if (!ref.mounted) return;
          await _pauseForSleepTimer();
        });
        _sleepTickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!ref.mounted) return;
          final remaining = state.sleepRemaining;
          if (remaining == null || remaining <= const Duration(seconds: 1)) {
            state = state.copyWith(sleepRemaining: .zero);
            _sleepTickTimer?.cancel();
            return;
          }
          state = state.copyWith(
            sleepRemaining: remaining - const Duration(seconds: 1),
          );
        });
    }
  }

  void _startSleepCountdownToChapterEnd() {
    _sleepTickTimer?.cancel();
    _sleepTickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted || !_endOfChapterPending) {
        _sleepTickTimer?.cancel();
        return;
      }
      state = state.copyWith(sleepRemaining: state.remainingInChapter);
    });
  }

  Future<void> _triggerSleepAtChapterEnd() async {
    _endOfChapterPending = false;
    await _pauseForSleepTimer();
  }

  Future<void> _pauseForSleepTimer() async {
    _sleepPaused = true;
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTickTimer?.cancel();
    _endOfChapterPending = false;
    await _player?.pause();
    if (!ref.mounted) return;
    state = state.copyWith(
      playing: false,
      sleepTimer: const SleepTimerOff(),
      clearSleepRemaining: true,
    );
    await _saveProgress();
  }

  double _progressFraction() {
    final total = state.totalDuration.inMilliseconds;
    if (total <= 0) return 0;
    int played = state.position.inMilliseconds;
    for (int i = 0; i < state.chapterIndex && i < state.chapters.length; i++) {
      played += state.chapters[i].durationMs;
    }
    final fraction = played / total;
    if (fraction <= 0) return 0;
    if (fraction >= 1) return 1;
    return fraction;
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _saveProgress(),
    );
  }

  Future<void> _saveProgress() async {
    final book = state.book;
    if (book == null || state.chapters.isEmpty) return;
    final positionLabel =
        '${state.chapterIndex}:${state.position.inMilliseconds}';
    await _progressRepo.saveProgress(
      AudioProgress(
        bookId: book.id,
        chapterIndex: state.chapterIndex,
        positionMs: state.position.inMilliseconds,
        updatedAt: DateTime.now(),
      ),
    );
    await _bookRepo.updateProgress(book.id, _progressFraction(), positionLabel);
  }

  Future<void> _dispose() async {
    _autoSaveTimer?.cancel();
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();
    await _saveProgress();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _stateSub?.cancel();
    await _indexSub?.cancel();
    await _player?.dispose();
    _player = null;
  }
}
