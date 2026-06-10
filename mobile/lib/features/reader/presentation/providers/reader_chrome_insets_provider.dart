import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Фактически измеренные высоты chrome-панелей ридера (topbar / нижняя панель).
///
/// Зависят от системного масштаба шрифта и локали, поэтому измеряются в рантайме
/// (см. `MeasureSize` в reader_screen), а не хардкодятся. Потребитель — слой
/// выделения: клампит меню и ручки так, чтобы они не уходили под видимый chrome.
/// `0` означает «ещё не измерено» — потребитель использует фолбэк-константу.
class ReaderChromeInsets {
  const ReaderChromeInsets({this.topHeight = 0, this.bottomHeight = 0});

  final double topHeight;
  final double bottomHeight;

  ReaderChromeInsets copyWith({double? topHeight, double? bottomHeight}) {
    return .new(
      topHeight: topHeight ?? this.topHeight,
      bottomHeight: bottomHeight ?? this.bottomHeight,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderChromeInsets &&
      other.topHeight == topHeight &&
      other.bottomHeight == bottomHeight;

  @override
  int get hashCode => Object.hash(topHeight, bottomHeight);
}

class ReaderChromeInsetsNotifier extends Notifier<ReaderChromeInsets> {
  // ignore: unused_element
  ReaderChromeInsetsNotifier(String _);

  @override
  ReaderChromeInsets build() => const .new();

  void setTopHeight(double height) {
    if (state.topHeight != height) {
      state = state.copyWith(topHeight: height);
    }
  }

  void setBottomHeight(double height) {
    if (state.bottomHeight != height) {
      state = state.copyWith(bottomHeight: height);
    }
  }
}

/// Family по bookId — как остальные reader-провайдеры. autoDispose: снимается
/// вместе с экраном.
final readerChromeInsetsProvider = NotifierProvider.family<
    ReaderChromeInsetsNotifier, ReaderChromeInsets, String>(
  ReaderChromeInsetsNotifier.new,
  isAutoDispose: true,
);
