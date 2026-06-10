import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Offset, Rect;

import 'package:bookish_corner/features/reader/data/fb2_page_geometry.dart';

/// Точка двунаправленной связки движок↔вью для fb2/txt-ридера.
///
/// Конкретный класс (а не интерфейс — это не три движка, абстракцию не плодим).
/// Постраничная вёрстка зависит от вьюпорта и шрифта, поэтому ею владеет ВЬЮ
/// (B1b), а движок — мост: он считает символьный offset, а вью переводит его в
/// страницы.
///
/// Поток данных:
/// - вью при смене страницы/ре-вёрстке зовёт [updatePosition] с актуальными
///   (глава, символьный offset) и page-метриками + [notifyListeners]; движок
///   слушает, пересчитывает символьный progress и переотдаёт всё в
///   `ReaderProgress`;
/// - page-навигация: [next]/[prev] дёргают хуки вью ([onNext]/[onPrev]), вью
///   листает и репортит новый offset через [updatePosition];
/// - seek по progress / TOC: движок считает offset и просит вью показать
///   страницу с этим offset через [jumpToOffset] → [onJump];
/// - смена настроек: движок зовёт [relayout] → [onRelayout], вью
///   пере-пагинирует, сохраняя позицию.
/// - геометрия выделения: вью выставляет [onGeometry]; [charOffsetAt],
///   [wordRangeAt], [rectsForCharRange], [textForRange] делегируют в
///   [PageTextGeometry] текущей страницы. Headless — возвращают null/[].
///
/// Пока хуки не выставлены вьюхой (headless), [next]/[prev]/[jumpToOffset]/
/// [relayout] — no-op, а позиционные/page-поля остаются `null`.
class Fb2RenderController extends ChangeNotifier {
  Fb2RenderController();

  int? _chapterIndex;
  int? _charOffset;
  int? _currentPage;
  int? _totalPages;
  int? _pagesToNextChapter;

  /// Текущая позиция, отрепорченная вьюхой: глава и символьное смещение начала
  /// видимой страницы (в `ReaderChapter.plainText`). Движок строит из них
  /// локатор.
  int? get chapterIndex => _chapterIndex;
  int? get charOffset => _charOffset;

  int? get currentPage => _currentPage;
  int? get totalPages => _totalPages;
  int? get pagesToNextChapter => _pagesToNextChapter;

  /// Хуки выставляет вью в B1b. Пока `null` — методы ниже no-op.
  VoidCallback? onNext;
  VoidCallback? onPrev;
  void Function(int chapterIndex, int charOffset)? onJump;
  VoidCallback? onRelayout;

  /// Хук геометрии: вью выставляет геттер актуальной [PageTextGeometry]
  /// текущей страницы. Пока `null` (headless) — все geometry-методы no-op.
  PageTextGeometry? Function()? onGeometry;

  /// Вызывается вью при _needsRelayout == true (смена шрифта/полей/etc).
  /// Слой выделения подписывается и сбрасывает активное выделение.
  VoidCallback? onSelectionReset;

  /// Вью сообщает движку актуальную позицию + page-метрики после вёрстки/смены
  /// страницы.
  void updatePosition({
    required int chapterIndex,
    required int charOffset,
    int? currentPage,
    int? totalPages,
    int? pagesToNextChapter,
  }) {
    _chapterIndex = chapterIndex;
    _charOffset = charOffset;
    _currentPage = currentPage;
    _totalPages = totalPages;
    _pagesToNextChapter = pagesToNextChapter;
    notifyListeners();
  }

  void next() => onNext?.call();

  void prev() => onPrev?.call();

  /// Движок просит вью показать страницу, содержащую [charOffset] в главе
  /// [chapterIndex] (seek слайдером, переход по TOC/поиску).
  void jumpToOffset(int chapterIndex, int charOffset) =>
      onJump?.call(chapterIndex, charOffset);

  /// Применение `ReaderSettings`: вью пере-пагинирует, сохраняя позицию.
  void relayout() => onRelayout?.call();

  // ── Геометрия текущей страницы (D1) ──────────────────────────────────────

  /// Символьный offset в `ReaderChapter.plainText` для точки [screenPt].
  /// `null` если вью не смонтирована (headless) или точка вне текста.
  int? charOffsetAt(Offset screenPt) => onGeometry?.call()?.charOffsetAt(screenPt);

  /// Диапазон слова вокруг точки [screenPt]. `null` headless или промах.
  (int, int)? wordRangeAt(Offset screenPt) =>
      onGeometry?.call()?.wordRangeAt(screenPt);

  /// Прямоугольники (контентные координаты страницы) для диапазона символов.
  List<Rect> rectsForCharRange(int charStart, int charEnd) =>
      onGeometry?.call()?.rectsForCharRange(charStart, charEnd) ?? const [];

  /// Текст для диапазона символов из текущей страницы.
  String textForRange(int charStart, int charEnd) =>
      onGeometry?.call()?.textForRange(charStart, charEnd) ?? '';
}
