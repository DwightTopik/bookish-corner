import 'package:bookish_corner/features/reader/domain/reader_locator.dart';

/// Стек позиций для навигации «назад» внутри ридера (после прыжков по TOC,
/// ссылкам, результатам поиска).
///
/// Immutable-класс — все мутации возвращают новый экземпляр. В A1 контроллер
/// его методы не вызывает (наполняется на задаче D6); поле существует в
/// состоянии заранее, чтобы форма не менялась потом.
class NavHistory {
  const NavHistory({this.entries = const []});

  final List<ReaderLocator> entries;

  bool get canGoBack => entries.isNotEmpty;

  /// Возможна ли навигация «вперёд» (redo). Стаб под D6 — пока всегда `false`;
  /// существует, чтобы chrome (B2) связал кнопку «Вперёд» сейчас, а D6 наполнил
  /// логику без изменения формы модели.
  bool get canGoForward => false;

  NavHistory push(ReaderLocator locator) => .new(entries: [...entries, locator]);

  NavHistory pop() => entries.isEmpty
      ? this
      : .new(entries: entries.sublist(0, entries.length - 1));
}
