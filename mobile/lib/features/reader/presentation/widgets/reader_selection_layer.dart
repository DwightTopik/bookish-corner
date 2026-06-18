import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/di/repository_providers.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/core/widgets/highlight_color_picker.dart';
import 'package:bookish_corner/features/reader/data/fb2_reader_engine.dart';
import 'package:bookish_corner/features/reader/data/fb2_render_controller.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';
import 'package:bookish_corner/features/reader/domain/reader_palette.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_chrome_insets_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_annotations_provider.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_selection_provider.dart';
import 'package:bookish_corner/features/reader/presentation/screens/reader_note_editor_screen.dart';

// ── Константы ──────────────────────────────────────────────────────────────

const double _kHandleRadius = 6.0;
const double _kHandleHitSlop = 20.0;
const double _kMenuWidth = 360.0;
const double _kMenuHeight = 60.0; // иконка над подписью
const double _kMenuColorPickerHeight = 52.0;
const double _kMenuVerticalGap = 8.0;

/// Резерв под верхний/нижний chrome.
const double _kChromeReserveTopVisible = 64.0;
const double _kChromeReserveTopHidden = 16.0;
const double _kChromeReserveBottomVisible = 220.0;
const double _kChromeReserveBottomHidden = 52.0;
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
      canvas.drawRect(r.translate(hMargin, vMargin), tintPaint);
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

  Offset? _startHandleCenter;
  Offset? _endHandleCenter;
  Rect? _menuAnchor;

  // Тапнутый хайлайт и bbox его меню (в экранных коорд.).
  ReaderAnnotation? _tappedAnnotation;
  Rect? _highlightMenuAnchor;

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

  void _updateGeometry(
      ReaderSelectionState sel, double topSafe, double bottomSafe) {
    final rc = _renderController();
    if (rc == null) return;

    final ReaderSelectionState(:charStart, :charEnd) = sel;
    final selRects = rc.rectsForCharRange(charStart, charEnd);
    if (selRects case []) {
      _startHandleCenter = null;
      _endHandleCenter = null;
      return;
    }

    final Rect firstRect = selRects.first;
    final Rect lastRect = selRects.last;
    Rect bbox = firstRect;
    for (final r in selRects) {
      bbox = bbox.expandToInclude(r);
    }
    final double hm = rc.onGeometry?.call()?.hMargin ?? 0;
    final double vm = rc.onGeometry?.call()?.vMargin ?? 0;
    _menuAnchor = bbox.translate(hm, vm);

    final double startY =
        (firstRect.bottom + vm + _kHandleRadius).clamp(topSafe, bottomSafe);
    final double endY =
        (lastRect.bottom + vm + _kHandleRadius).clamp(topSafe, bottomSafe);
    _startHandleCenter = Offset(firstRect.left + hm, startY);
    _endHandleCenter = Offset(lastRect.right + hm, endY);
  }

  // ── Тап по хайлайту ───────────────────────────────────────────────────

  void _onAnnotationTap(ReaderAnnotation annotation, Rect screenBbox) {
    setState(() {
      _tappedAnnotation = annotation;
      _highlightMenuAnchor = screenBbox;
    });
  }

  void _dismissHighlightMenu() {
    setState(() {
      _tappedAnnotation = null;
      _highlightMenuAnchor = null;
    });
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

    final int charStart = drag == .start ? newOffset : sel.charStart;
    final int charEnd = drag == .end ? newOffset : sel.charEnd;

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

    final rc = _renderController();
    if (rc != null) _bindRc(rc);

    final bool chromeVisible =
        ref.watch(readerControllerProvider(widget.bookId)).chromeVisible;
    final MediaQueryData mq = MediaQuery.of(context);
    final double screenH = mq.size.height;
    final double topSafe;
    final double bottomSafe;
    if (chromeVisible) {
      final ReaderChromeInsets insets =
          ref.watch(readerChromeInsetsProvider(widget.bookId));
      topSafe = insets.topHeight > 0
          ? insets.topHeight + _kChromeGap
          : mq.padding.top + _kChromeReserveTopVisible;
      bottomSafe = insets.bottomHeight > 0
          ? screenH - insets.bottomHeight - _kChromeGap
          : screenH - mq.padding.bottom - _kChromeReserveBottomVisible;
    } else {
      topSafe = mq.padding.top + _kChromeReserveTopHidden;
      bottomSafe = screenH - mq.padding.bottom - _kChromeReserveBottomHidden;
    }

    if (sel != null) {
      _updateGeometry(sel, topSafe, bottomSafe);
    } else {
      _startHandleCenter = null;
      _endHandleCenter = null;
      _menuAnchor = null;
    }

    final bool active = sel != null && !sel.isEmpty;

    List<Rect> paintRects = const [];
    double hMargin = 0;
    double vMargin = 0;
    if (active && rc != null) {
      final ReaderSelectionState(:charStart, :charEnd) = sel;
      paintRects = rc.rectsForCharRange(charStart, charEnd);
      hMargin = rc.onGeometry?.call()?.hMargin ?? 0;
      vMargin = rc.onGeometry?.call()?.vMargin ?? 0;
    }

    // Аннотации текущей страницы — для bbox-таргетов тапа.
    final annotations = ref
        .watch(readerAnnotationsProvider(widget.bookId))
        .asData
        ?.value ?? const <ReaderAnnotation>[];
    final int? currentChapter = rc?.chapterIndex;
    final double hm = rc?.onGeometry?.call()?.hMargin ?? 0;
    final double vm = rc?.onGeometry?.call()?.vMargin ?? 0;

    // Список (annotation, left, top, width, height) для текущей страницы.
    final List<(ReaderAnnotation, double, double, double, double)>
        visibleAnnotations = [
      if (rc != null && currentChapter != null)
        for (final a in annotations)
          if (a.chapterIndex == currentChapter)
            ...() {
              final rects = rc.rectsForCharRange(a.charStart, a.charEnd);
              if (rects.isEmpty) return const [];
              Rect bbox = rects.first;
              for (final r in rects) {
                bbox = bbox.expandToInclude(r);
              }
              final Rect(:left, :top, :width, :height) = bbox.translate(hm, vm);
              return [(a, left, top, width, height)];
            }(),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: active
                ? HitTestBehavior.opaque
                : HitTestBehavior.translucent,
            onLongPressStart: (d) {
              // Тап-меню хайлайта сбрасываем при long-press.
              if (_tappedAnnotation != null) _dismissHighlightMenu();
              _onLongPressStart(d);
            },
            onPanStart: active ? _onPanStart : null,
            onPanUpdate: active ? _onPanUpdate : null,
            onPanEnd: active ? _onPanEnd : null,
            onTapDown: active ? _onTapDown : null,
          ),
        ),
        // Translucent-таргеты по bbox каждого хайлайта (только в inactive).
        if (!active)
          for (final (annotation, left, top, width, height)
              in visibleAnnotations)
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _onAnnotationTap(
                  annotation,
                  Rect.fromLTWH(left, top, width, height),
                ),
              ),
            ),
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
        if (active && _menuAnchor != null)
          _SelectionMenu(
            bookId: widget.bookId,
            anchor: _menuAnchor!,
            topSafe: topSafe,
            bottomSafe: bottomSafe,
            onDismiss: () => _notifier().clear(),
          ),
        // Барьер: пока меню хайлайта открыто — тап вне закрывает его и
        // поглощается (opaque не пускает тап в gesture layer ниже). Под самим
        // меню в Stack, так что тап по меню барьер не перехватывает.
        if (!active && _tappedAnnotation != null && _highlightMenuAnchor != null)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismissHighlightMenu,
            ),
          ),
        if (!active && _tappedAnnotation != null && _highlightMenuAnchor != null)
          _HighlightMenu(
            bookId: widget.bookId,
            annotation: _tappedAnnotation!,
            anchor: _highlightMenuAnchor!,
            topSafe: topSafe,
            bottomSafe: bottomSafe,
            onDismiss: _dismissHighlightMenu,
            onOpenEditor: (a) {
              _dismissHighlightMenu();
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => ReaderNoteEditorScreen(
                    bookId: widget.bookId,
                    text: a.text,
                    charStart: a.charStart,
                    charEnd: a.charEnd,
                    chapterIndex: a.chapterIndex ?? 0,
                    initialColor: a.color,
                    initialNote: a.noteText,
                    existingId: a.id,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ── Контекст-меню ──────────────────────────────────────────────────────────

class _SelectionMenu extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<_SelectionMenu> createState() => _SelectionMenuState();
}

class _SelectionMenuState extends ConsumerState<_SelectionMenu> {
  bool _showColorPicker = false;
  final HighlightColor _pendingColor = .coral;
  bool _pendingIsNote = false;

  Fb2RenderController? _rc() {
    final engine = ref.read(readerEngineProvider(widget.bookId));
    if (engine is Fb2ReaderEngine) return engine.renderController;
    return null;
  }

  String _selectedText() {
    final sel = ref.read(readerSelectionProvider(widget.bookId));
    if (sel == null) return '';
    return _rc()?.textForRange(sel.charStart, sel.charEnd) ?? '';
  }

  ReaderSelectionState? _sel() =>
      ref.read(readerSelectionProvider(widget.bookId));

  Future<void> _saveQuote(HighlightColor color) async {
    final sel = _sel();
    if (sel == null) return;
    final text = _selectedText();
    if (text.isEmpty) return;
    final repo = ref.read(readerAnnotationRepositoryProvider);
    final ReaderSelectionState(:charStart, :charEnd, :chapterIndex) = sel;
    await repo.addAnnotation(ReaderAnnotation(
      id: const Uuid().v4(),
      bookId: widget.bookId,
      type: .quote,
      charStart: charStart,
      charEnd: charEnd,
      chapterIndex: chapterIndex,
      text: text,
      color: color,
      createdAt: DateTime.now(),
    ));
    widget.onDismiss();
  }

  void _openNoteEditor(HighlightColor color) {
    final sel = _sel();
    if (sel == null) return;
    final text = _selectedText();
    final ReaderSelectionState(:charStart, :charEnd, :chapterIndex) = sel;
    widget.onDismiss();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => ReaderNoteEditorScreen(
          bookId: widget.bookId,
          text: text,
          charStart: charStart,
          charEnd: charEnd,
          chapterIndex: chapterIndex,
          initialColor: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.sizeOf(context).width;
    final ReaderPalette palette = ReaderPalette.resolve(
      ref.watch(readerControllerProvider(widget.bookId)).settings.background,
      context.appColors,
    );

    final double barH =
        _showColorPicker ? _kMenuColorPickerHeight : _kMenuHeight;
    final double menuAbove = widget.anchor.top - _kMenuVerticalGap - barH;
    final double menuBelow = widget.anchor.bottom + _kMenuVerticalGap;
    final double menuTop;
    if (menuAbove >= widget.topSafe) {
      menuTop = menuAbove;
    } else if (menuBelow + barH <= widget.bottomSafe) {
      menuTop = menuBelow;
    } else {
      menuTop = menuAbove.clamp(
        widget.topSafe,
        math.max(widget.topSafe, widget.bottomSafe - barH),
      );
    }

    double menuLeft = widget.anchor.center.dx - _kMenuWidth / 2;
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
      height: barH,
      child: Material(
        color: Colors.transparent,
        child: _showColorPicker
            ? _ColorPickerBar(
                palette: palette,
                initialColor: _pendingColor,
                onSelect: (color) {
                  if (_pendingIsNote) {
                    _openNoteEditor(color);
                  } else {
                    _saveQuote(color);
                  }
                },
              )
            : _MenuBar(
                palette: palette,
                onCopy: () {
                  final text = _selectedText();
                  if (text.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: text));
                  }
                  widget.onDismiss();
                },
                onShare: () async {
                  final text = _selectedText();
                  if (text.isNotEmpty) {
                    await SharePlus.instance.share(ShareParams(text: text));
                  }
                  widget.onDismiss();
                },
                onQuote: () => setState(() {
                  _pendingIsNote = false;
                  _showColorPicker = true;
                }),
                onNote: () => setState(() {
                  _pendingIsNote = true;
                  _showColorPicker = true;
                }),
              ),
      ),
    );
  }
}

// ── Общая поверхность меню ──────────────────────────────────────────────────

/// Фон контекст-меню в теме ридера ([ReaderPalette]) + поглощение тапа: тап по
/// самому меню не закрывает его (поглощается opaque-GD), а кнопки внутри (глубже
/// в дереве) выигрывают арену и срабатывают.
class _MenuSurface extends StatelessWidget {
  const _MenuSurface({required this.palette, required this.child});

  final ReaderPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: const .all(.circular(8)),
          border: .fromBorderSide(
            BorderSide(color: palette.muted.withValues(alpha: 0.25)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ── Бар с пикером цвета ────────────────────────────────────────────────────

class _ColorPickerBar extends StatefulWidget {
  const _ColorPickerBar({
    required this.palette,
    required this.initialColor,
    required this.onSelect,
  });

  final ReaderPalette palette;
  final HighlightColor initialColor;
  final ValueChanged<HighlightColor> onSelect;

  @override
  State<_ColorPickerBar> createState() => _ColorPickerBarState();
}

class _ColorPickerBarState extends State<_ColorPickerBar> {
  late HighlightColor _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return _MenuSurface(
      palette: widget.palette,
      child: Padding(
        padding: const .symmetric(horizontal: 8),
        child: HighlightColorPicker(
          selected: _selected,
          onSelect: (color) {
            setState(() => _selected = color);
            widget.onSelect(color);
          },
        ),
      ),
    );
  }
}

// ── Бар кнопок выделения ────────────────────────────────────────────────────

class _MenuBar extends StatelessWidget {
  const _MenuBar({
    required this.palette,
    required this.onCopy,
    required this.onShare,
    required this.onQuote,
    required this.onNote,
  });

  final ReaderPalette palette;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onQuote;
  final VoidCallback? onNote;

  @override
  Widget build(BuildContext context) {
    return _MenuSurface(
      palette: palette,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuButton(
            icon: Icons.content_copy,
            label: 'Скопировать',
            palette: palette,
            onTap: onCopy,
          ),
          _MenuButton(
            icon: Icons.ios_share,
            label: 'Поделиться',
            palette: palette,
            onTap: onShare,
          ),
          _MenuButton(
            icon: Icons.format_quote,
            label: 'Цитата',
            palette: palette,
            onTap: onQuote,
          ),
          _MenuButton(
            icon: Icons.edit_note,
            label: 'Заметка',
            palette: palette,
            onTap: onNote,
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.palette,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ReaderPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        onTap != null ? palette.text : palette.muted.withValues(alpha: 0.5);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const .symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppDimensions.readerMenuIconSize, color: color),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Бар кнопок хайлайта ────────────────────────────────────────────────────

class _HighlightActionBar extends StatelessWidget {
  const _HighlightActionBar({
    required this.palette,
    required this.onDelete,
    required this.onNote,
    required this.noteLabel,
    required this.onColor,
  });

  final ReaderPalette palette;
  final VoidCallback onDelete;
  final VoidCallback onNote;
  final String noteLabel;
  final VoidCallback onColor;

  @override
  Widget build(BuildContext context) {
    return _MenuSurface(
      palette: palette,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuButton(
            icon: Icons.delete_outline,
            label: 'Удалить',
            palette: palette,
            onTap: onDelete,
          ),
          _MenuButton(
            icon: Icons.edit_note,
            label: noteLabel,
            palette: palette,
            onTap: onNote,
          ),
          _MenuButton(
            icon: Icons.palette,
            label: 'Цвет',
            palette: palette,
            onTap: onColor,
          ),
        ],
      ),
    );
  }
}

// ── Меню тапа по хайлайту ──────────────────────────────────────────────────

class _HighlightMenu extends ConsumerStatefulWidget {
  const _HighlightMenu({
    required this.bookId,
    required this.annotation,
    required this.anchor,
    required this.topSafe,
    required this.bottomSafe,
    required this.onDismiss,
    required this.onOpenEditor,
  });

  final String bookId;
  final ReaderAnnotation annotation;
  final Rect anchor;
  final double topSafe;
  final double bottomSafe;
  final VoidCallback onDismiss;
  final ValueChanged<ReaderAnnotation> onOpenEditor;

  @override
  ConsumerState<_HighlightMenu> createState() => _HighlightMenuState();
}

class _HighlightMenuState extends ConsumerState<_HighlightMenu> {
  bool _showColorPicker = false;

  Future<void> _delete() async {
    widget.onDismiss();
    await ref
        .read(readerAnnotationRepositoryProvider)
        .removeAnnotation(widget.annotation.id);
  }

  Future<void> _changeColor(HighlightColor color) async {
    widget.onDismiss();
    await ref
        .read(readerAnnotationRepositoryProvider)
        .updateColor(widget.annotation.id, color);
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.sizeOf(context).width;
    final ReaderPalette palette = ReaderPalette.resolve(
      ref.watch(readerControllerProvider(widget.bookId)).settings.background,
      context.appColors,
    );

    final double barH =
        _showColorPicker ? _kMenuColorPickerHeight : _kMenuHeight;
    final double menuAbove = widget.anchor.top - _kMenuVerticalGap - barH;
    final double menuBelow = widget.anchor.bottom + _kMenuVerticalGap;
    final double menuTop;
    if (menuAbove >= widget.topSafe) {
      menuTop = menuAbove;
    } else if (menuBelow + barH <= widget.bottomSafe) {
      menuTop = menuBelow;
    } else {
      menuTop = menuAbove.clamp(
        widget.topSafe,
        math.max(widget.topSafe, widget.bottomSafe - barH),
      );
    }

    double menuLeft = widget.anchor.center.dx - _kMenuWidth / 2;
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
      height: barH,
      child: Material(
        color: Colors.transparent,
        child: _showColorPicker
            ? _ColorPickerBar(
                palette: palette,
                initialColor: widget.annotation.color,
                onSelect: _changeColor,
              )
            : _HighlightActionBar(
                palette: palette,
                onDelete: _delete,
                onNote: () => widget.onOpenEditor(widget.annotation),
                noteLabel: widget.annotation.type == .note
                    ? 'Редактировать'
                    : 'Заметка',
                onColor: () => setState(() => _showColorPicker = true),
              ),
      ),
    );
  }
}
