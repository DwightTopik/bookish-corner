import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookish_corner/features/reader/data/fb2_page_geometry.dart';

// ─── Вспомогательная фабрика ──────────────────────────────────────────────────

/// Строит реальный TextPainter для [text] шириной [width] и возвращает его
/// вместе с вычисленными LineMetrics. Тест использует реальный layout, чтобы
/// charOffsetAt/rectsForCharRange работали на живых данных — не моках.
(TextPainter, List<LineMetrics>) _buildPainter(
  String text, {
  double width = 200,
  TextAlign align = .left,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    ),
    textDirection: .ltr,
    textAlign: align,
  )..layout(maxWidth: width);
  return (painter, painter.computeLineMetrics());
}

/// Строит [PageTextGeometry] из единственного блока с нулевыми отступами.
PageTextGeometry _singleBlockGeometry(
  String text, {
  double width = 200,
  double hMargin = 0,
  double vMargin = 0,
  int blockPlainStart = 0,
  double paragraphIndent = 0,
}) {
  final (painter, metrics) = _buildPainter(text, width: width);

  double y = 0;
  final lines = <PageLineDescriptor>[];
  for (int i = 0; i < metrics.length; i++) {
    lines.add(PageLineDescriptor(
      painter: painter,
      lineIndex: i,
      lineMetrics: metrics,
      yOnPage: y,
      blockPlainStart: blockPlainStart,
      isFirstLineOfBlock: i == 0,
      paragraphIndent: paragraphIndent,
    ));
    y += metrics[i].height;
  }

  return PageTextGeometry(
    lines: lines,
    hMargin: hMargin,
    vMargin: vMargin,
    contentWidth: width,
  );
}

// ─── Тесты ───────────────────────────────────────────────────────────────────

void main() {
  // TextPainter требует хотя бы инициализированного тест-биндинга.
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── screenToContent ──────────────────────────────────────────────────────

  test('screenToContent вычитает margins', () {
    const geo = PageTextGeometry(
      lines: [],
      hMargin: 20,
      vMargin: 30,
      contentWidth: 200,
    );
    final result = geo.screenToContent(const Offset(80, 90));
    expect(result.dx, closeTo(60, 0.01));
    expect(result.dy, closeTo(60, 0.01));
  });

  // ── charOffsetAt ─────────────────────────────────────────────────────────

  test('charOffsetAt: начало строки → offset 0 при одной строке', () {
    const text = 'Hello';
    final geo = _singleBlockGeometry(text, width: 400);
    // Тап в начало первой строки.
    final (painter, metrics) = _buildPainter(text, width: 400);
    final firstLineY = metrics[0].baseline - metrics[0].ascent + 0.5;
    final offset = geo.charOffsetAt(Offset(0, firstLineY));
    expect(offset, isNotNull);
    expect(offset, equals(0));
    painter.dispose();
  });

  test('charOffsetAt: конец строки → offset близко к длине текста', () {
    const text = 'Hello';
    final geo = _singleBlockGeometry(text, width: 400);
    final (_, metrics) = _buildPainter(text, width: 400);
    final y = metrics[0].baseline - metrics[0].ascent + 0.5;
    final offset = geo.charOffsetAt(Offset(399, y));
    expect(offset, isNotNull);
    expect(offset, greaterThan(0));
  });

  test('charOffsetAt: учитывает blockPlainStart', () {
    const text = 'World';
    const bps = 10; // предыдущий блок занимал 10 символов
    final geo = _singleBlockGeometry(text, width: 400, blockPlainStart: bps);
    final (_, metrics) = _buildPainter(text, width: 400);
    final y = metrics[0].baseline - metrics[0].ascent + 0.5;
    final offset = geo.charOffsetAt(Offset(0, y));
    expect(offset, greaterThanOrEqualTo(bps));
  });

  test('charOffsetAt: учитывает hMargin и vMargin', () {
    const text = 'Hello';
    final geo = _singleBlockGeometry(
      text,
      width: 400,
      hMargin: 24,
      vMargin: 40,
    );
    final (_, metrics) = _buildPainter(text, width: 400);
    // Координата с учётом margins.
    final y = 40 + (metrics[0].baseline - metrics[0].ascent + 0.5);
    final offset = geo.charOffsetAt(Offset(24, y));
    expect(offset, isNotNull);
    expect(offset, equals(0));
  });

  test('charOffsetAt: возвращает null для пустой геометрии', () {
    const geo = PageTextGeometry(
      lines: [],
      hMargin: 0,
      vMargin: 0,
      contentWidth: 200,
    );
    expect(geo.charOffsetAt(const Offset(10, 10)), isNull);
  });

  // ── wordRangeAt ──────────────────────────────────────────────────────────

  test('wordRangeAt: тап в середину слова → диапазон всего слова', () {
    const text = 'Hello World';
    final geo = _singleBlockGeometry(text, width: 400);
    final (painter, metrics) = _buildPainter(text, width: 400);
    final y = metrics[0].baseline - metrics[0].ascent + 0.5;
    // Находим x середины "Hello" (символ 2).
    final midX = painter.getOffsetForCaret(
      const TextPosition(offset: 2),
      Rect.zero,
    ).dx;
    final range = geo.wordRangeAt(Offset(midX, y));
    expect(range, isNotNull);
    final (start, end) = range!;
    // 'Hello' = [0,5)
    expect(start, equals(0));
    expect(end, equals(5));
    painter.dispose();
  });

  test('wordRangeAt: учитывает blockPlainStart при выводе диапазона', () {
    const text = 'Foo Bar';
    const bps = 7;
    final geo = _singleBlockGeometry(text, width: 400, blockPlainStart: bps);
    final (painter, metrics) = _buildPainter(text, width: 400);
    final y = metrics[0].baseline - metrics[0].ascent + 0.5;
    final xFoo = painter.getOffsetForCaret(
      const TextPosition(offset: 1),
      Rect.zero,
    ).dx;
    final range = geo.wordRangeAt(Offset(xFoo, y));
    expect(range, isNotNull);
    // 'Foo' в painter [0,3) → с blockPlainStart = 7 даёт [7, 10)
    expect(range!.$1, equals(bps));
    expect(range.$2, equals(bps + 3));
    painter.dispose();
  });

  // ── rectsForCharRange ────────────────────────────────────────────────────

  test('rectsForCharRange: диапазон внутри одной строки → непустой список', () {
    const text = 'Hello World';
    final geo = _singleBlockGeometry(text, width: 400);
    // 'Hello' = [0, 5)
    final rects = geo.rectsForCharRange(0, 5);
    expect(rects, isNotEmpty);
    for (final r in rects) {
      expect(r.width, greaterThan(0));
      expect(r.height, greaterThan(0));
    }
  });

  test('rectsForCharRange: диапазон через границу блоков', () {
    const text1 = 'First';
    const text2 = 'Second';
    final (p1, m1) = _buildPainter(text1, width: 300);
    final (p2, m2) = _buildPainter(text2, width: 300);

    double y = 0;
    final lines = <PageLineDescriptor>[];

    for (int i = 0; i < m1.length; i++) {
      lines.add(PageLineDescriptor(
        painter: p1,
        lineIndex: i,
        lineMetrics: m1,
        yOnPage: y,
        blockPlainStart: 0,
        isFirstLineOfBlock: i == 0,
        paragraphIndent: 0,
      ));
      y += m1[i].height;
    }
    for (int i = 0; i < m2.length; i++) {
      lines.add(PageLineDescriptor(
        painter: p2,
        lineIndex: i,
        lineMetrics: m2,
        yOnPage: y,
        blockPlainStart: 6, // 'First' (5) + '\n' (1)
        isFirstLineOfBlock: i == 0,
        paragraphIndent: 0,
      ));
      y += m2[i].height;
    }

    final geo = PageTextGeometry(
      lines: lines,
      hMargin: 0,
      vMargin: 0,
      contentWidth: 300,
    );

    // Диапазон [3, 9) захватывает конец "First" и начало "Second".
    final rects = geo.rectsForCharRange(3, 9);
    expect(rects, isNotEmpty);
    // Должны быть боксы хотя бы из двух разных y-уровней.
    final yValues = rects.map((r) => r.top).toSet();
    expect(yValues.length, greaterThan(1));

    p1.dispose();
    p2.dispose();
  });

  test('rectsForCharRange: пустой диапазон → пустой список', () {
    const text = 'Hello';
    final geo = _singleBlockGeometry(text, width: 400);
    expect(geo.rectsForCharRange(3, 3), isEmpty);
  });

  test('rectsForCharRange: диапазон вне строк → пустой список', () {
    const text = 'Hello';
    final geo = _singleBlockGeometry(text, width: 400);
    // 100–200 далеко за пределами блока (5 символов).
    expect(geo.rectsForCharRange(100, 200), isEmpty);
  });

  // ── underlinesForCharRange ───────────────────────────────────────────────

  test('underlinesForCharRange: тонкий rect у базовой линии (одна строка)', () {
    // 'Hello' умещается в одну строку при width 400 → один подчёркивающий rect.
    const text = 'Hello';
    final geo = _singleBlockGeometry(text, width: 400);
    final (_, metrics) = _buildPainter(text, width: 400);
    const thickness = 2.0;
    const gap = 1.5;

    final unders =
        geo.underlinesForCharRange(0, 5, thickness: thickness, gap: gap);
    expect(unders, hasLength(1));
    final Rect(:top, :height, :width, :left, :right) = unders.first;
    final Rect(left: fillLeft, right: fillRight, bottom: fillBottom) =
        geo.rectsForCharRange(0, 5).first;

    // Толщина = токен; ширина положительная.
    expect(height, closeTo(thickness, 0.01));
    expect(width, greaterThan(0));
    // Подчёркивание сидит у базовой линии (первая строка → _lineTop = 0).
    expect(top, closeTo(metrics[0].baseline + gap, 0.5));
    // Внутри line-box заливки (выше его нижней границы при height = 1.5).
    expect(top, lessThan(fillBottom));
    // Горизонтальные края совпадают с заливкой.
    expect(left, closeTo(fillLeft, 0.01));
    expect(right, closeTo(fillRight, 0.01));
  });

  test('underlinesForCharRange: пустой диапазон → пустой список', () {
    final geo = _singleBlockGeometry('Hello', width: 400);
    expect(
      geo.underlinesForCharRange(3, 3, thickness: 2, gap: 1.5),
      isEmpty,
    );
  });

  // ── textForRange ─────────────────────────────────────────────────────────

  test('textForRange: извлекает текст из одного блока', () {
    const text = 'Hello World';
    final geo = _singleBlockGeometry(text, width: 400);
    expect(geo.textForRange(0, 5), equals('Hello'));
    expect(geo.textForRange(6, 11), equals('World'));
  });

  test('textForRange: учитывает blockPlainStart', () {
    const text = 'World';
    const bps = 6;
    final geo = _singleBlockGeometry(text, width: 400, blockPlainStart: bps);
    expect(geo.textForRange(bps, bps + 5), equals('World'));
  });

  test('textForRange: пустой диапазон → пустая строка', () {
    final geo = _singleBlockGeometry('Hello', width: 400);
    expect(geo.textForRange(2, 2), equals(''));
  });
}
