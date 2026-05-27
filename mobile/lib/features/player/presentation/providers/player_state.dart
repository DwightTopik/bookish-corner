import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/domain/sleep_timer_option.dart';

class PlayerState {
  const PlayerState({
    this.book,
    this.chapters = const [],
    this.chapterIndex = 0,
    this.position = .zero,
    this.playing = false,
    this.speed = 1.0,
    this.sleepTimer = const SleepTimerOff(),
    this.sleepRemaining,
    this.bookmarked = false,
    this.loading = false,
    this.chapterDurationOverride,
  });

  final Book? book;
  final List<AudioChapter> chapters;
  final int chapterIndex;
  final Duration position;
  final bool playing;
  final double speed;
  final SleepTimerOption sleepTimer;
  final Duration? sleepRemaining;
  final bool bookmarked;
  final bool loading;
  final Duration? chapterDurationOverride;

  bool get hasBook => book != null && chapters.isNotEmpty;

  AudioChapter? get currentChapter => chapters.isEmpty
      ? null
      : chapters[chapterIndex.clamp(0, chapters.length - 1)];

  Duration get chapterDuration {
    final override = chapterDurationOverride;
    if (override != null && override > .zero) return override;
    return currentChapter?.duration ?? .zero;
  }

  Duration get remainingInChapter {
    final d = chapterDuration - position;
    return d.isNegative ? .zero : d;
  }

  Duration get totalDuration {
    int ms = 0;
    for (final c in chapters) {
      ms += c.durationMs;
    }
    return .new(milliseconds: ms);
  }

  PlayerState copyWith({
    Book? book,
    List<AudioChapter>? chapters,
    int? chapterIndex,
    Duration? position,
    bool? playing,
    double? speed,
    SleepTimerOption? sleepTimer,
    Duration? sleepRemaining,
    bool clearSleepRemaining = false,
    bool? bookmarked,
    bool? loading,
    Duration? chapterDurationOverride,
    bool clearChapterDurationOverride = false,
  }) {
    return PlayerState(
      book: book ?? this.book,
      chapters: chapters ?? this.chapters,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      position: position ?? this.position,
      playing: playing ?? this.playing,
      speed: speed ?? this.speed,
      sleepTimer: sleepTimer ?? this.sleepTimer,
      sleepRemaining: clearSleepRemaining
          ? null
          : (sleepRemaining ?? this.sleepRemaining),
      bookmarked: bookmarked ?? this.bookmarked,
      loading: loading ?? this.loading,
      chapterDurationOverride: clearChapterDurationOverride
          ? null
          : (chapterDurationOverride ?? this.chapterDurationOverride),
    );
  }

  PlayerState withCurrentChapterDuration(Duration duration) {
    if (duration <= .zero || chapters.isEmpty) return this;
    final idx = chapterIndex.clamp(0, chapters.length - 1);
    final updated = [...chapters];
    updated[idx] = updated[idx].copyWith(durationMs: duration.inMilliseconds);
    return copyWith(chapters: updated, chapterDurationOverride: duration);
  }
}
