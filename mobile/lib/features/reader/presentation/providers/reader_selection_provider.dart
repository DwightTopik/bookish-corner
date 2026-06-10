import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Активная ручка выделения: стартовая или конечная.
enum SelectionHandle { start, end }

/// UI-состояние активного выделения текста на странице.
///
/// [charStart]/[charEnd] — диапазон в `ReaderChapter.plainText` текущей главы.
/// Геометрия (боксы, bbox меню) вычисляется снаружи через шов render-controller
/// и НЕ хранится здесь — это presentation-деталь, зависящая от вёрстки.
class ReaderSelectionState {
  const ReaderSelectionState({
    required this.chapterIndex,
    required this.charStart,
    required this.charEnd,
    this.activeHandle,
  });

  final int chapterIndex;
  final int charStart;
  final int charEnd;

  /// Ручка, которую сейчас тянет пользователь. `null` — drag не активен.
  final SelectionHandle? activeHandle;

  bool get isEmpty => charStart == charEnd;

  ReaderSelectionState copyWith({
    int? chapterIndex,
    int? charStart,
    int? charEnd,
    SelectionHandle? activeHandle,
    bool clearHandle = false,
  }) {
    return ReaderSelectionState(
      chapterIndex: chapterIndex ?? this.chapterIndex,
      charStart: charStart ?? this.charStart,
      charEnd: charEnd ?? this.charEnd,
      activeHandle: clearHandle ? null : (activeHandle ?? this.activeHandle),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderSelectionState &&
      other.chapterIndex == chapterIndex &&
      other.charStart == charStart &&
      other.charEnd == charEnd &&
      other.activeHandle == activeHandle;

  @override
  int get hashCode => Object.hash(chapterIndex, charStart, charEnd, activeHandle);
}

class ReaderSelectionNotifier extends Notifier<ReaderSelectionState?> {
  // ignore: unused_element
  ReaderSelectionNotifier(String _);

  @override
  ReaderSelectionState? build() => null;

  /// Начать выделение слова по [chapterIndex] + диапазон `[start, end)`.
  void startWord(int chapterIndex, int start, int end) {
    state = ReaderSelectionState(
      chapterIndex: chapterIndex,
      charStart: start,
      charEnd: end,
    );
  }

  /// Обновить диапазон при перетаскивании ручки (clamp: start ≤ end).
  void updateRange({required int charStart, required int charEnd}) {
    final current = state;
    if (current == null) return;
    final s = charStart <= charEnd ? charStart : charEnd;
    final e = charStart <= charEnd ? charEnd : charStart;
    state = current.copyWith(charStart: s, charEnd: e);
  }

  /// Сменить активную ручку (начало drag).
  void setActiveHandle(SelectionHandle handle) {
    state = state?.copyWith(activeHandle: handle);
  }

  /// Завершить drag ручки.
  void clearActiveHandle() {
    state = state?.copyWith(clearHandle: true);
  }

  /// Сбросить выделение (тап вне, relayout).
  void clear() {
    state = null;
  }
}

/// Provider выделения для конкретной книги. Family по bookId — соответствует
/// остальным reader-провайдерам. autoDispose: снимается вместе с экраном.
final readerSelectionProvider =
    NotifierProvider.family<ReaderSelectionNotifier, ReaderSelectionState?,
        String>(
  ReaderSelectionNotifier.new,
  isAutoDispose: true,
);
