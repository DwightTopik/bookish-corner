import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/data/fb2_reader_engine.dart';
import 'package:bookish_corner/features/reader/data/fb2_render_controller.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_chrome_insets_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_selection_provider.dart';

// ── Константы ──────────────────────────────────────────────────────────────

const double _kHandleRadius = 6.0;
const double _kHandleHitSlop = 20.0;
// Оценка фактической ширины бара (4 кириллические подписи) — используется только
// для горизонтального clamp позиции, сам бар сжимается под контент.
const double _kMenuWidth = 360.0;
const double _kMenuHeight = 44.0;
const double _kMenuVerticalGap = 8.0;

/// Резерв под верхний/нижний chrome (topbar / панель+футер). Меню и ручки
/// рисуются в selection layer ПОД chrome в Stack, поэтому в крайних позициях их
/// перекрывает topbar сверху и панель снизу. Клампим в зону за вычетом резерва.
///
/// Зависит от видимости chrome: при видимом — резервируем высоту полных панелей
/// (topbar / bottom panel + toolbar), при скрытом — только иммерсивный футер.
/// Фолбэк-резервы, пока фактические высоты chrome ещё не измерены
/// (`readerChromeInsetsProvider`). После первого кадра используются реальные.
const double _kChromeReserveTopVisible = 64.0;
const double _kChromeReserveTopHidden = 16.0;
const double _kChromeReserveBottomVisible = 220.0;
const double _kChromeReserveBottomHidden = 52.0;

/// Зазор между краем видимого chrome и ручкой/меню.
const double _kChromeGap = 8.0;

// ── Painter выделения + ручек ──────────────────────────────────────────────

class _SelectionPainter extends CustomPainter {
  const _SelectionPainter({
    required this.rects,
    required this.startHandleCenter,
    required this.endHandleCenter,
    required this.tintColor,
    required this.handleColor,
    required this.hMargin,
    required this.vMargin,
  });

  final List<Rect> rects;
  final Offset? startHandleCenter;
  final Offset? endHandleCenter;
  final Color tintColor;
  final Color handleColor;
  final double hMargin;
  final double vMargin;

  @override
  void paint(Canvas canvas, Size size) {
    if (rects.isEmpty) return;

    final tintPaint = Paint()..color = tintColor;
    final handlePaint = Paint()..color = handleColor;

    for (final r in rects) {
      // Контентные координаты → экранные (добавляем margins).
      final screenRect = r.translate(hMargin, vMargin);
      canvas.drawRect(screenRect, tintPaint);
    }

    if (startHandleCenter != null) {
      canvas.drawCircle(startHandleCenter!, _kHandleRadius, handlePaint);
    }
    if (endHandleCenter != null) {
      canvas.drawCircle(endHandleCenter!, _kHandleRadius, handlePaint);
    }
  }

  @override
  bool shouldRepaint(_SelectionPainter old) =>
      !identical(old.rects, rects) ||
      old.startHandleCenter != startHandleCenter ||
      old.endHandleCenter != endHandleCenter ||
      old.tintColor != tintColor ||
      old.handleColor != handleColor;
}

// ── Основной виджет ────────────────────────────────────────────────────────

/// Прозрачный слой над [ReaderGestureLayer]:
/// - неактивен → long-press запускает выделение слова, остальные события
///   проходят насквозь к gesture layer ниже;
/// - активен → перехватывает tap/drag для ручек и снятия выделения.
class ReaderSelectionLayer extends ConsumerStatefulWidget {
  const ReaderSelectionLayer({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<ReaderSelectionLayer> createState() =>
      _ReaderSelectionLayerState();
}

class _ReaderSelectionLayerState extends ConsumerState<ReaderSelectionLayer> {
  SelectionHandle? _dragging;
  Fb2RenderController? _boundRc;

  // Вычисленные из rects центры ручек и bbox меню в экранных координатах.
  // Хранятся локально — вычисляются в build(), чтобы не трогать провайдер во время билда.
  Offset? _startHandleCenter;
  Offset? _endHandleCenter;
  Rect? _menuAnchor;

  @override
  void dispose() {
    _unbindRc();
    super.dispose();
  }

  void _bindRc(Fb2RenderController rc) {
    if (_boundRc == rc) return;
    _unbindRc();
    _boundRc = rc;
    rc.onSelectionReset = _onSelectionReset;
  }

  void _unbindRc() {
    final rc = _boundRc;
    if (rc != null && rc.onSelectionReset == _onSelectionReset) {
      rc.onSelectionReset = null;
    }
    _boundRc = null;
  }

  void _onSelectionReset() {
    _notifier().clear();
  }

  Fb2RenderController? _renderController() {
    final engine = ref.read(readerEngineProvider(widget.bookId));
    if (engine is Fb2ReaderEngine) return engine.renderController;
    return null;
  }

  ReaderSelectionNotifier _notifier() =>
      ref.read(readerSelectionProvider(widget.bookId).notifier);

  int? _currentChapter() {
    final engine = ref.read(readerEngineProvider(widget.bookId));
    if (engine is Fb2ReaderEngine) {
      return engine.renderController.chapterIndex;
    }
    return null;
  }

  // ── Геометрия ──────────────────────────────────────────────────────────

  void _updateGeometry(ReaderSelectionState sel, double topSafe,
      double bottomSafe) {
    final rc = _renderController();
    if (rc == null) return;

    final ReaderSelectionState(:charStart, :charEnd) = sel;
    final selRects = rc.rectsForCharRange(charStart, charEnd);
    if (selRects case []) {
      _startHandleCenter = null;
      _endHandleCenter = null;
      return;
    }

    // bbox всего выделения для меню.
    final Rect firstRect = selRects.first;
    final Rect lastRect = selRects.last;
    Rect bbox = firstRect;
    for (final r in selRects) {
      bbox = bbox.expandToInclude(r);
    }
    final double hm = rc.onGeometry?.call()?.hMargin ?? 0;
    final double vm = rc.onGeometry?.call()?.vMargin ?? 0;
    // Переводим bbox в экранные координаты — храним локально, не в провайдере,
    // чтобы не модифицировать state во время build().
    _menuAnchor = bbox.translate(hm, vm);

    // Ручки: start — нижний-левый угол первого rect, end — нижний-правый
    // последнего. Y клампим в видимую зону, чтобы ручка у нижнего/верхнего края
    // страницы не пряталась за панелью/topbar.
    final double startY =
        (firstRect.bottom + vm + _kHandleRadius).clamp(topSafe, bottomSafe);
    final double endY =
        (lastRect.bottom + vm + _kHandleRadius).clamp(topSafe, bottomSafe);
    _startHandleCenter = Offset(firstRect.left + hm, startY);
    _endHandleCenter = Offset(lastRect.right + hm, endY);
  }

  // ── Long-press → выделить слово ────────────────────────────────────────

  void _onLongPressStart(LongPressStartDetails details) {
    final rc = _renderController();
    if (rc == null) return;
    final range = rc.wordRangeAt(details.localPosition);
    if (range == null) return;
    final ci = _currentChapter();
    if (ci == null) return;
    HapticFeedback.selectionClick();
    _notifier().startWord(ci, range.$1, range.$2);
  }

  // ── Drag ручек ─────────────────────────────────────────────────────────

  bool _isNearHandle(Offset point, Offset? handle) {
    if (handle == null) return false;
    return (point - handle).distance <= _kHandleHitSlop;
  }

  void _onPanStart(DragStartDetails details) {
    final pt = details.localPosition;
    if (_isNearHandle(pt, _startHandleCenter)) {
      _dragging = .start;
      _notifier().setActiveHandle(.start);
    } else if (_isNearHandle(pt, _endHandleCenter)) {
      _dragging = .end;
      _notifier().setActiveHandle(.end);
    } else {
      _dragging = null;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final SelectionHandle? drag = _dragging;
    if (drag == null) return;
    final rc = _renderController();
    if (rc == null) return;
    final sel = ref.read(readerSelectionProvider(widget.bookId));
    if (sel == null) return;

    final newOffset = rc.charOffsetAt(details.localPosition);
    if (newOffset == null) return;

    final int charStart =
        drag == .start ? newOffset : sel.charStart;
    final int charEnd =
        drag == .end ? newOffset : sel.charEnd;

    // clamp: start всегда < end; при сжатии до нуля — не сбрасываем.
    if (charStart >= charEnd) return;
    _notifier().updateRange(charStart: charStart, charEnd: charEnd);
  }

  void _onPanEnd(DragEndDetails _) {
    _dragging = null;
    _notifier().clearActiveHandle();
  }

  // ── Tap вне выделения → снять ──────────────────────────────────────────

  void _onTapDown(TapDownDetails details) {
    final sel = ref.read(readerSelectionProvider(widget.bookId));
    if (sel == null) return;
    final pt = details.localPosition;
    // Касание по ручке (центр которой лежит ниже текста) — это начало drag,
    // НЕ тап «мимо». Иначе левая ручка сбрасывала бы выделение вместо перетаскивания.
    if (_isNearHandle(pt, _startHandleCenter) ||
        _isNearHandle(pt, _endHandleCenter)) {
      return;
    }
    final rc = _renderController();
    if (rc == null) {
      _notifier().clear();
      return;
    }
    final rects = rc.rectsForCharRange(sel.charStart, sel.charEnd);
    final hm = rc.onGeometry?.call()?.hMargin ?? 0;
    final vm = rc.onGeometry?.call()?.vMargin ?? 0;
    final bool insideSelection = rects.any(
      (r) => r.translate(hm, vm).contains(pt),
    );
    if (!insideSelection) _notifier().clear();
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sel = ref.watch(readerSelectionProvider(widget.bookId));
    final colors = context.appColors;

    // Подписываемся на onSelectionReset при каждом rebuild — безопасно благодаря
    // guard _boundRc == rc.
    final rc = _renderController();
    if (rc != null) _bindRc(rc);

    // Видимая вертикальная зона (за вычетом safe-area и chrome).
    final bool chromeVisible =
        ref.watch(readerControllerProvider(widget.bookId)).chromeVisible;
    final MediaQueryData mq = MediaQuery.of(context);
    final double screenH = mq.size.height;
    final double topSafe;
    final double bottomSafe;
    if (chromeVisible) {
      // Панели видны: клампим за их фактические высоты, измеренные виджетом
      // MeasureSize. Фолбэк на константу действует пока высота равна нулю —
      // то есть до первого кадра, когда измерение ещё не пришло.
      final ReaderChromeInsets insets =
          ref.watch(readerChromeInsetsProvider(widget.bookId));
      topSafe = insets.topHeight > 0
          ? insets.topHeight + _kChromeGap
          : mq.padding.top + _kChromeReserveTopVisible;
      bottomSafe = insets.bottomHeight > 0
          ? screenH - insets.bottomHeight - _kChromeGap
          : screenH - mq.padding.bottom - _kChromeReserveBottomVisible;
    } else {
      // Chrome скрыт → перекрывает только иммерсивный футер; зона почти во весь
      // экран.
      topSafe = mq.padding.top + _kChromeReserveTopHidden;
      bottomSafe = screenH - mq.padding.bottom - _kChromeReserveBottomHidden;
    }

    // При смене состояния выделения пересчитываем геометрию.
    // _updateGeometry пишет только в локальные поля (_menuAnchor, handle centers),
    // провайдер не трогает — нет риска "modify provider while building".
    if (sel != null) {
      _updateGeometry(sel, topSafe, bottomSafe);
    } else {
      _startHandleCenter = null;
      _endHandleCenter = null;
      _menuAnchor = null;
    }

    final bool active = sel != null && !sel.isEmpty;

    // Rects для painter — пересчитываем из render controller.
    List<Rect> paintRects = const [];
    double hMargin = 0;
    double vMargin = 0;
    if (active && rc != null) {
      final ReaderSelectionState(:charStart, :charEnd) = sel;
      paintRects = rc.rectsForCharRange(charStart, charEnd);
      hMargin = rc.onGeometry?.call()?.hMargin ?? 0;
      vMargin = rc.onGeometry?.call()?.vMargin ?? 0;
    }

    return Stack(
      children: [
        // Слой жестов.
        Positioned.fill(
          child: GestureDetector(
            behavior: active
                ? HitTestBehavior.opaque
                : HitTestBehavior.translucent,
            onLongPressStart: _onLongPressStart,
            onPanStart: active ? _onPanStart : null,
            onPanUpdate: active ? _onPanUpdate : null,
            onPanEnd: active ? _onPanEnd : null,
            onTapDown: active ? _onTapDown : null,
          ),
        ),
        // Слой рисования (поверх жестов, под меню).
        if (active)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SelectionPainter(
                  rects: paintRects,
                  startHandleCenter: _startHandleCenter,
                  endHandleCenter: _endHandleCenter,
                  tintColor: colors.readerSelectionTint,
                  handleColor: colors.readerSelectionHandle,
                  hMargin: hMargin,
                  vMargin: vMargin,
                ),
              ),
            ),
          ),
        // Контекст-меню.
        if (active && _menuAnchor != null)
          _SelectionMenu(
            bookId: widget.bookId,
            anchor: _menuAnchor!,
            topSafe: topSafe,
            bottomSafe: bottomSafe,
            onDismiss: () => _notifier().clear(),
          ),
      ],
    );
  }
}

// ── Контекст-меню ──────────────────────────────────────────────────────────

class _SelectionMenu extends ConsumerWidget {
  const _SelectionMenu({
    required this.bookId,
    required this.anchor,
    required this.topSafe,
    required this.bottomSafe,
    required this.onDismiss,
  });

  final String bookId;
  final Rect anchor;
  final double topSafe;
  final double bottomSafe;
  final VoidCallback onDismiss;

  Fb2RenderController? _rc(WidgetRef ref) {
    final engine = ref.read(readerEngineProvider(bookId));
    if (engine is Fb2ReaderEngine) return engine.renderController;
    return null;
  }

  String _selectedText(WidgetRef ref) {
    final sel = ref.read(readerSelectionProvider(bookId));
    if (sel == null) return '';
    return _rc(ref)?.textForRange(sel.charStart, sel.charEnd) ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenW = MediaQuery.sizeOf(context).width;

    // topSafe/bottomSafe приходят из слоя — та же зона, что для ручек.
    // Позиционируем меню: предпочитаем НАД выделением, но только если оно не
    // залезает в верхнюю chrome-зону (иначе topbar его перекроет). Иначе — ПОД.
    // Если не помещается ни там, ни там — клампим в видимую зону.
    final double menuAbove = anchor.top - _kMenuVerticalGap - _kMenuHeight;
    final double menuBelow = anchor.bottom + _kMenuVerticalGap;
    final double menuTop;
    if (menuAbove >= topSafe) {
      menuTop = menuAbove;
    } else if (menuBelow + _kMenuHeight <= bottomSafe) {
      menuTop = menuBelow;
    } else {
      menuTop = menuAbove.clamp(
        topSafe,
        math.max(topSafe, bottomSafe - _kMenuHeight),
      );
    }

    // Горизонтально: центрируем по bbox, clamp в экран.
    double menuLeft = anchor.center.dx - _kMenuWidth / 2;
    menuLeft = menuLeft.clamp(
      AppDimensions.readerHMarginMin,
      math.max(
        AppDimensions.readerHMarginMin,
        screenW - _kMenuWidth - AppDimensions.readerHMarginMin,
      ),
    );

    return Positioned(
      left: menuLeft,
      top: menuTop,
      height: _kMenuHeight,
      // Без фиксированной width — бар сам сжимается под контент (кириллические
      // подписи в 300px не влезали → debug-overflow). _kMenuWidth остаётся только
      // оценкой для горизонтального clamp.
      child: Material(
        color: Colors.transparent,
        child: _MenuBar(
          onCopy: () {
            final text = _selectedText(ref);
            if (text.isNotEmpty) Clipboard.setData(ClipboardData(text: text));
            onDismiss();
          },
          onShare: () async {
            final text = _selectedText(ref);
            if (text.isNotEmpty) {
              await SharePlus.instance.share(ShareParams(text: text));
            }
            onDismiss();
          },
          // D1b: персист цитат/заметок — заглушки.
          onQuote: null,
          onNote: null,
        ),
      ),
    );
  }
}

class _MenuBar extends StatelessWidget {
  const _MenuBar({
    required this.onCopy,
    required this.onShare,
    required this.onQuote,
    required this.onNote,
  });

  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onQuote;
  final VoidCallback? onNote;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(8);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D21),
        borderRadius: const .all(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuButton(label: 'Скопировать', onTap: onCopy),
          _MenuButton(label: 'Поделиться', onTap: onShare),
          _MenuButton(
            label: 'Цитата',
            onTap: onQuote,
            disabled: true,
          ),
          _MenuButton(
            label: 'Заметка',
            onTap: onNote,
            disabled: true,
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Padding(
        padding: const .symmetric(horizontal: 8, vertical: 10),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: disabled
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
