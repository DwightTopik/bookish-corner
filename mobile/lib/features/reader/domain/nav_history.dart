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

  NavHistory push(ReaderLocator locator) => .new(entries: [...entries, locator]);

  NavHistory pop() => entries.isEmpty
      ? this
      : .new(entries: entries.sublist(0, entries.length - 1));
}
