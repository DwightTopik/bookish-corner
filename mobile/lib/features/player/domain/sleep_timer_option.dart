sealed class SleepTimerOption {
  const SleepTimerOption();

  String get label;
}

class SleepTimerOff extends SleepTimerOption {
  const SleepTimerOff();
  @override
  String get label => '—';
}

class SleepTimerEndOfChapter extends SleepTimerOption {
  const SleepTimerEndOfChapter();
  @override
  String get label => 'КОНЕЦ ГЛАВЫ';
}

class SleepTimerDuration extends SleepTimerOption {
  const SleepTimerDuration(this.duration);
  final Duration duration;

  @override
  String get label {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:$mm:$ss';
    return '$mm:$ss';
  }
}

const sleepTimerPresets = <SleepTimerOption>[
  SleepTimerOff(),
  SleepTimerEndOfChapter(),
  SleepTimerDuration(Duration(minutes: 5)),
  SleepTimerDuration(Duration(minutes: 10)),
  SleepTimerDuration(Duration(minutes: 15)),
  SleepTimerDuration(Duration(minutes: 20)),
  SleepTimerDuration(Duration(minutes: 30)),
  SleepTimerDuration(Duration(minutes: 45)),
  SleepTimerDuration(Duration(hours: 1)),
  SleepTimerDuration(Duration(hours: 1, minutes: 30)),
  SleepTimerDuration(Duration(hours: 2)),
];
