import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Дескриптор одной текстовой строки на странице — минимальный срез данных,
/// нужных для char↔box преобразований. Заполняется вью из _TextLineItem.
class PageLineDescriptor {
  const PageLineDescriptor({
    required this.painter,
    required this.lineIndex,
    required this.lineMetrics,
    required this.yOnPage,
    required this.blockPlainStart,
    required this.isFirstLineOfBlock,
    required this.paragraphIndent,
  });

  final TextPainter painter;
  final int lineIndex;
  final List<LineMetrics> lineMetrics;

  /// Верх строки в контентных координатах страницы (без hMargin/vMargin).
  final double yOnPage;

  /// Символьный старт блока в `ReaderChapter.plainText`.
  final int blockPlainStart;
  final bool isFirstLineOfBlock;
  final double paragraphIndent;

  double get _lineTop {
    double top = 0;
    for (int j = 0; j < lineIndex; j++) {
      top += lineMetrics[j].height;
    }
    return top;
  }

  double get _xOffset =>
      isFirstLineOfBlock && painter.textAlign == .left ? paragraphIndent : 0.0;

  double get lineHeight =>
      lineIndex < lineMetrics.length ? lineMetrics[lineIndex].height : 0;

  /// Диапазон символов блока, покрываемый этой строкой (painter-local).
  ///
  /// Начало строки ищем в painter-локальной x=0: абзацный отступ применяется
  /// ВНЕШНЕ при рисовании (`painter.paint(canvas, Offset(indent, …))`), внутри
  /// painter'а текст всегда начинается с 0. Если передать сюда indent — первые
  /// символы первой строки абзаца выпадут из диапазона.
  (int, int) get _painterCharRange {
    if (lineMetrics.isEmpty) return (0, 0);
    final lm = lineMetrics[lineIndex];
    final start = painter
        .getPositionForOffset(Offset(0, lm.baseline - lm.ascent + 0.5))
        .offset;
    final isLast = lineIndex == lineMetrics.length - 1;
    final int end;
    if (isLast) {
      end = painter.text?.toPlainText().length ?? start;
    } else {
      final nextLm = lineMetrics[lineIndex + 1];
      end = painter
          .getPositionForOffset(
            Offset(0, nextLm.baseline - nextLm.ascent + 0.5),
          )
          .offset;
    }
    return (start, end);
  }
}

/// Геометрия одной отрендеренной страницы: умеет переводить точку на экране
/// в символьный offset и диапазон символов в список прямоугольников.
///
/// Координаты результатов — контентные (без hMargin/vMargin); caller добавляет
/// margins сам через [screenToContent].
class PageTextGeometry {
  const PageTextGeometry({
    required this.lines,
    required this.hMargin,
    required this.vMargin,
    required this.contentWidth,
  });

  final List<PageLineDescriptor> lines;
  final double hMargin;
  final double vMargin;
  final double contentWidth;

  /// Переводит точку в локальных координатах виджета в контентные.
  Offset screenToContent(Offset screen) {
    return Offset(screen.dx - hMargin, screen.dy - vMargin);
  }

  // ── Hit-test: точка → строка ────────────────────────────────────────────

  PageLineDescriptor? _lineAt(Offset contentPt) {
    PageLineDescriptor? best;
    for (final line in lines) {
      final double top = line.yOnPage;
      final double bottom = top + line.lineHeight;
      if (contentPt.dy >= top && contentPt.dy < bottom) return line;
      if (contentPt.dy >= top) best = line;
    }
    return best;
  }

  /// Символьный offset в `ReaderChapter.plainText` для точки [screenPt].
  /// Возвращает `null` если страница пуста или точка не попадает ни в строку.
  int? charOffsetAt(Offset screenPt) {
    final cp = screenToContent(screenPt);
    final line = _lineAt(cp);
    if (line == null) return null;
    final PageLineDescriptor(
      :painter,
      :yOnPage,
      :blockPlainStart,
      :_lineTop,
      :_xOffset,
    ) = line;

    final double painterY = (cp.dy - yOnPage) + _lineTop;
    final double painterX = math.max(0, cp.dx - _xOffset);

    final int localOffset =
        painter.getPositionForOffset(Offset(painterX, painterY)).offset;
    return blockPlainStart + localOffset;
  }

  /// Границы слова вокруг точки [screenPt]. Возвращает `null` при промахе.
  (int, int)? wordRangeAt(Offset screenPt) {
    final cp = screenToContent(screenPt);
    final line = _lineAt(cp);
    if (line == null) return null;
    final PageLineDescriptor(
      :painter,
      :yOnPage,
      :blockPlainStart,
      :_lineTop,
      :_xOffset,
    ) = line;

    final double painterY = (cp.dy - yOnPage) + _lineTop;
    final double painterX = math.max(0, cp.dx - _xOffset);

    final TextPosition pos =
        painter.getPositionForOffset(Offset(painterX, painterY));
    final TextRange range = painter.getWordBoundary(pos);
    if (range.start == range.end) return null;
    return (blockPlainStart + range.start, blockPlainStart + range.end);
  }

  /// Горизонтальный отрезок диапазона на одной строке + вертикальные метрики.
  /// Общий шов для [rectsForCharRange] (заливка) и [underlinesForCharRange]
  /// (подчёркивание): первый строит полный rect, второй — тонкий у базовой линии.
  ({
    double left,
    double right,
    double yOnPage,
    double lineHeight,
    double baselineFromLineTop,
  })? _lineSpan(PageLineDescriptor line, int charStart, int charEnd) {
    final PageLineDescriptor(
      :blockPlainStart,
      :painter,
      :yOnPage,
      :_painterCharRange,
      :_xOffset,
      :_lineTop,
      :lineHeight,
      :lineIndex,
      :lineMetrics,
    ) = line;
    final (int rangeStart, int rangeEnd) = _painterCharRange;
    final int globalStart = blockPlainStart + rangeStart;
    final int globalEnd = blockPlainStart + rangeEnd;

    if (charEnd <= globalStart || charStart >= globalEnd) return null;

    final int localStart = math.max(charStart, globalStart) - blockPlainStart;
    final int localEnd = math.min(charEnd, globalEnd) - blockPlainStart;

    final List<TextBox> boxes = painter.getBoxesForSelection(
      TextSelection(baseOffset: localStart, extentOffset: localEnd),
    );
    if (boxes.isEmpty) return null;

    double minLeft = .infinity;
    double maxRight = .negativeInfinity;
    for (final box in boxes) {
      if (box.left < minLeft) minLeft = box.left;
      if (box.right > maxRight) maxRight = box.right;
    }

    // baseline у LineMetrics отсчитывается от верха painter; _lineTop — верх
    // этой строки в painter; их разница — базовая линия от верха строки.
    final double baselineFromLineTop =
        lineIndex < lineMetrics.length ? lineMetrics[lineIndex].baseline - _lineTop : 0;

    return (
      left: minLeft + _xOffset,
      right: maxRight + _xOffset,
      yOnPage: yOnPage,
      lineHeight: lineHeight,
      baselineFromLineTop: baselineFromLineTop,
    );
  }

  /// Список прямоугольников (контентные координаты) для диапазона
  /// `[charStart, charEnd)` в `ReaderChapter.plainText`.
  List<Rect> rectsForCharRange(int charStart, int charEnd) {
    if (charStart >= charEnd) return const [];
    final List<Rect> result = <Rect>[];

    for (final line in lines) {
      final span = _lineSpan(line, charStart, charEnd);
      if (span == null) continue;
      // Один прямоугольник на строку: горизонтальные края — из боксов, вертикаль
      // — ровно высота строки на странице. Так подсветки соседних строк не
      // перекрываются (иначе полупрозрачный тинт темнеет на стыках из-за leading).
      result.add(Rect.fromLTRB(
        span.left,
        span.yOnPage,
        span.right,
        span.yOnPage + span.lineHeight,
      ));
    }

    return result;
  }

  /// Тонкие прямоугольники-подчёркивания у базовой линии каждой строки диапазона
  /// (для аннотаций-заметок). [thickness] — высота линии, [gap] — отступ ниже
  /// базовой линии.
  List<Rect> underlinesForCharRange(
    int charStart,
    int charEnd, {
    required double thickness,
    required double gap,
  }) {
    if (charStart >= charEnd) return const [];
    final List<Rect> result = <Rect>[];

    for (final line in lines) {
      final span = _lineSpan(line, charStart, charEnd);
      if (span == null) continue;
      final double top = span.yOnPage + span.baselineFromLineTop + gap;
      result.add(Rect.fromLTRB(span.left, top, span.right, top + thickness));
    }

    return result;
  }

  /// Извлекает plainText для диапазона `[charStart, charEnd)` из строк страницы.
  String textForRange(int charStart, int charEnd) {
    if (charStart >= charEnd) return '';
    final StringBuffer buf = StringBuffer();
    final Set<TextPainter> seen = {};
    for (final line in lines) {
      final PageLineDescriptor(:painter, :blockPlainStart) = line;
      if (seen.contains(painter)) continue;
      seen.add(painter);
      final String full = painter.text?.toPlainText() ?? '';
      final int gs = blockPlainStart;
      final int ge = gs + full.length;
      if (charEnd <= gs || charStart >= ge) continue;
      final int ls = math.max(charStart, gs) - gs;
      final int le = math.min(charEnd, ge) - gs;
      buf.write(full.substring(ls, le.clamp(ls, full.length)));
    }
    return buf.toString();
  }
}
