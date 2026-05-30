import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/data/document/reader_document.dart';
import 'package:bookish_corner/features/reader/data/fb2_reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_engine.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';

// ─────────────────────────────── Типографика ────────────────────────────────

class _TextTheme {
  _TextTheme({
    required this.bodySize,
    required this.headingSize,
    required this.lineHeight,
    required this.textAlign,
    required this.bodyColor,
    required this.bgColor,
  });

  final double bodySize;
  final double headingSize;
  final double lineHeight;
  final TextAlign textAlign;
  final Color bodyColor;
  final Color bgColor;

  static const List<String> _serifFallback = ['Georgia', 'Times New Roman', 'serif'];

  static _TextTheme resolve(ReaderSettings s, AppColors colors) {
    final ReaderSettings(
      :background,
      :fontSizeStep,
      :lineHeight,
      :textAlign,
    ) = s;
    final AppColors(
      :bg,
      :textPrimary,
      :readerWhiteBg,
      :readerWhiteText,
      :readerSepiaBg,
      :readerSepiaText,
      :readerGrayBg,
      :readerGrayText,
      :readerBlackBg,
      :readerBlackText,
    ) = colors;
    final (Color bgColor, Color textColor) = switch (background) {
      .white  => (readerWhiteBg, readerWhiteText),
      .sepia  => (readerSepiaBg, readerSepiaText),
      .gray   => (readerGrayBg,  readerGrayText),
      .black  => (readerBlackBg, readerBlackText),
      .system => (bg, textPrimary),
    };
    final double bodySize = AppDimensions.readerFontSize(fontSizeStep);
    return _TextTheme(
      bodySize: bodySize,
      headingSize: bodySize * AppDimensions.readerHeadingScale,
      lineHeight: lineHeight,
      textAlign: textAlign == .justify ? TextAlign.justify : TextAlign.left,
      bodyColor: textColor,
      bgColor: bgColor,
    );
  }

  TextStyle get bodyStyle => .new(
    fontFamilyFallback: _serifFallback,
    fontSize: bodySize,
    height: lineHeight,
    color: bodyColor,
  );

  TextStyle get headingStyle => .new(
    fontFamilyFallback: _serifFallback,
    fontSize: headingSize,
    height: lineHeight,
    fontWeight: FontWeight.w700,
    color: bodyColor,
  );

  int get settingsHash =>
      Object.hash(bodySize, headingSize, lineHeight, textAlign, bgColor, bodyColor);
}

// ───────────────────────────── Пагинатор главы ──────────────────────────────

/// Атом отрисовки страницы — строка текста или картинка. Sealed: painter
/// исчерпывающе матчит варианты.
sealed class _PageItem {
  const _PageItem({required this.yOnPage});

  /// Верх атома относительно начала контентной области страницы.
  final double yOnPage;
}

/// Одна строка блочного текста (painter-на-блок, страница = срез строк).
class _TextLineItem extends _PageItem {
  const _TextLineItem({
    required this.painter,
    required this.lineIndex,
    required super.yOnPage,
    required this.lineMetrics,
    required this.isFirstLineOfBlock,
  });

  final TextPainter painter;
  final int lineIndex;
  final List<LineMetrics> lineMetrics;
  final bool isFirstLineOfBlock;
}

/// Блочная картинка как единый атом: вписана по ширине (или по высоте, если
/// выше страницы) с сохранением пропорций, центрирована по X.
class _ImageItem extends _PageItem {
  const _ImageItem({
    required this.image,
    required this.displayWidth,
    required this.displayHeight,
    required this.xOffset,
    required super.yOnPage,
  });

  final ui.Image image;
  final double displayWidth;
  final double displayHeight;
  final double xOffset;
}

class _PageLayout {
  const _PageLayout({required this.units, required this.startCharOffset});

  final List<_PageItem> units;
  final int startCharOffset;
}

class _LayoutKey {
  const _LayoutKey(this.chapterIndex, this.widthPx, this.settingsHash);

  final int chapterIndex;
  final int widthPx;
  final int settingsHash;

  @override
  bool operator ==(Object other) =>
      other is _LayoutKey &&
      other.chapterIndex == chapterIndex &&
      other.widthPx == widthPx &&
      other.settingsHash == settingsHash;

  @override
  int get hashCode => Object.hash(chapterIndex, widthPx, settingsHash);
}

class _ChapterLayout {
  _ChapterLayout({required this.pages, required this.painterList});

  final List<_PageLayout> pages;
  // Держим painters живыми, пока canvas их рисует.
  final List<TextPainter> painterList;

  int get pageCount => pages.length;

  int pageForOffset(int charOffset) {
    for (int i = pages.length - 1; i >= 0; i--) {
      if (pages[i].startCharOffset <= charOffset) return i;
    }
    return 0;
  }
}

/// Верстает [chapter] в страницы: painter-на-блок, страница = срез строк.
/// [images] — декодированные картинки по id `<binary>` (для [ImageBlock]).
_ChapterLayout _layoutChapter(
  ReaderChapter chapter,
  double contentWidth,
  double pageHeight,
  _TextTheme theme,
  Map<String, ui.Image> images,
) {
  // null на позиции image-блока — картинки рисуются не painter'ом.
  final List<TextPainter?> builtPainters = <TextPainter?>[];
  final List<int> blockPlainStarts = <int>[];
  int runningOffset = 0;

  // 1. Построить TextPainter для каждого текстового блока.
  for (final ReaderBlock block in chapter.blocks) {
    blockPlainStarts.add(runningOffset);
    runningOffset += block.text.length + 1; // +1 за '\n'-разделитель

    if (block is ImageBlock) {
      builtPainters.add(null);
      continue;
    }

    final TextStyle baseStyle;
    final TextAlign align;
    final _TextTheme(:headingStyle, :bodyStyle, :textAlign) = theme;
    if (block is HeadingBlock) {
      baseStyle = headingStyle;
      align = TextAlign.center;
    } else {
      baseStyle = bodyStyle;
      align = textAlign;
    }

    final List<TextSpan> spans = [
      for (final ReaderRun(:text, :bold, :italic) in block.runs)
        TextSpan(
          text: text,
          style: baseStyle.copyWith(
            fontWeight: bold ? FontWeight.w700 : null,
            fontStyle: italic ? FontStyle.italic : null,
          ),
        ),
    ];

    builtPainters.add(
      TextPainter(
        text: TextSpan(children: spans, style: baseStyle),
        textAlign: align,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: contentWidth),
    );
  }

  // 2. Разбить на страницы построчно (картинка — единым атомом).
  final List<_PageLayout> resultPages = <_PageLayout>[];
  List<_PageItem> currentUnits = <_PageItem>[];
  double currentY = 0;
  bool isFirstBlock = true;
  int pageStartOffset = 0;
  bool pageStartSet = false;

  void flushPage() {
    if (currentUnits.isEmpty) return;
    resultPages.add(_PageLayout(
      units: List.unmodifiable(currentUnits),
      startCharOffset: pageStartOffset,
    ));
    currentUnits = [];
    currentY = 0;
    pageStartSet = false;
  }

  for (int bi = 0; bi < chapter.blocks.length; bi++) {
    final ReaderBlock block = chapter.blocks[bi];
    final int plainStart = blockPlainStarts[bi];

    final double topSpacing;
    if (isFirstBlock) {
      topSpacing = 0;
      isFirstBlock = false;
    } else if (block is HeadingBlock) {
      topSpacing = AppDimensions.readerHeadingTopSpacing;
    } else {
      topSpacing = AppDimensions.readerParagraphSpacing;
    }

    // Картинка — единый атом: вписать по ширине; если выше остатка страницы →
    // на следующую; если выше всей страницы → масштаб до высоты, центр по X.
    if (block is ImageBlock) {
      final ui.Image? image = images[block.id];
      if (image == null) continue; // нет декода — нулевой вклад, как пустой блок
      double displayW = contentWidth;
      double displayH = contentWidth * image.height / image.width;
      if (displayH > pageHeight) {
        displayH = pageHeight;
        displayW = pageHeight * image.width / image.height;
      }
      if (currentY + topSpacing + displayH > pageHeight &&
          currentUnits.isNotEmpty) {
        flushPage();
      }
      final double spacing = currentUnits.isEmpty ? 0.0 : topSpacing;
      if (!pageStartSet) {
        pageStartOffset = plainStart;
        pageStartSet = true;
      }
      currentUnits.add(_ImageItem(
        image: image,
        displayWidth: displayW,
        displayHeight: displayH,
        xOffset: (contentWidth - displayW) / 2,
        yOnPage: currentY + spacing,
      ));
      currentY += spacing + displayH;
      continue;
    }

    final TextPainter blockPainter = builtPainters[bi]!;
    final List<LineMetrics> metrics = blockPainter.computeLineMetrics();

    final double paraIndent =
        block is ParagraphBlock ? AppDimensions.readerParagraphIndent : 0.0;

    for (int li = 0; li < metrics.length; li++) {
      final LineMetrics lm = metrics[li];
      final bool isFirstLine = li == 0;
      final double spacing = isFirstLine ? topSpacing : 0.0;
      final double lineH = lm.height;

      if (currentY + spacing + lineH > pageHeight && currentUnits.isNotEmpty) {
        flushPage();
      }

      final int lineCharOffset = plainStart +
          blockPainter
              .getPositionForOffset(Offset(paraIndent, lm.baseline - lm.ascent + 0.5))
              .offset;

      if (!pageStartSet) {
        pageStartOffset = lineCharOffset;
        pageStartSet = true;
      }

      currentUnits.add(_TextLineItem(
        painter: blockPainter,
        lineIndex: li,
        yOnPage: currentY + spacing,
        lineMetrics: metrics,
        isFirstLineOfBlock: isFirstLine,
      ));
      currentY += spacing + lineH;
    }

    if (block is HeadingBlock && bi < chapter.blocks.length - 1) {
      currentY += AppDimensions.readerHeadingBottomSpacing;
    }
  }
  flushPage();

  if (resultPages.isEmpty) {
    resultPages.add(const _PageLayout(units: <_PageItem>[], startCharOffset: 0));
  }

  return _ChapterLayout(
    pages: resultPages,
    painterList: builtPainters.whereType<TextPainter>().toList(),
  );
}

// ────────────────────────────── CustomPainter ───────────────────────────────

class _PagePainter extends CustomPainter {
  const _PagePainter({
    required this.units,
    required this.contentWidth,
    required this.hMargin,
    required this.vMargin,
    required this.paragraphIndent,
  });

  final List<_PageItem> units;
  final double contentWidth;
  final double hMargin;
  final double vMargin;
  final double paragraphIndent;

  static double _lineTop(List<LineMetrics> lm, int i) {
    double top = 0;
    for (int j = 0; j < i; j++) {
      top += lm[j].height;
    }
    return top;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(hMargin, vMargin);

    for (final _PageItem item in units) {
      switch (item) {
        case _TextLineItem(
            :final painter,
            :final lineIndex,
            :final yOnPage,
            :final lineMetrics,
            :final isFirstLineOfBlock,
          ):
          if (lineMetrics.isEmpty) continue;

          final double painterY = yOnPage - _lineTop(lineMetrics, lineIndex);
          final double lineH = lineMetrics[lineIndex].height;

          canvas.save();
          canvas.clipRect(Rect.fromLTWH(0, yOnPage, contentWidth, lineH));

          final double xOffset =
              isFirstLineOfBlock && painter.textAlign == .left
                  ? paragraphIndent
                  : 0.0;

          painter.paint(canvas, Offset(xOffset, painterY));
          canvas.restore();
        case _ImageItem(
            :final image,
            :final displayWidth,
            :final displayHeight,
            :final xOffset,
            :final yOnPage,
          ):
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            Rect.fromLTWH(xOffset, yOnPage, displayWidth, displayHeight),
            Paint()..filterQuality = FilterQuality.medium,
          );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PagePainter old) =>
      old.units.length != units.length ||
      old.contentWidth != contentWidth ||
      old.hMargin != hMargin ||
      old.vMargin != vMargin;
}

// ─────────────────────────────── Основной виджет ────────────────────────────

/// Поверхность рендера для fb2/txt книг. Верстает текущую главу построчно
/// (painter-на-блок), отображает одну страницу, связывает вью с
/// [Fb2RenderController]. Анимирует смежные переходы (next/prev) горизонтальным
/// слайдом; прыжки (onJump/onRelayout) мгновенны.
class Fb2ReaderView extends ConsumerStatefulWidget {
  const Fb2ReaderView({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<Fb2ReaderView> createState() => _Fb2ReaderViewState();
}

class _Fb2ReaderViewState extends ConsumerState<Fb2ReaderView>
    with SingleTickerProviderStateMixin {
  final Map<_LayoutKey, _ChapterLayout> _cache = {};

  int _chapterIndex = 0;
  int _localPage = 0;

  double _pageHeight = 0;
  double _contentWidth = 0;
  double _hMargin = 0;
  double _vMargin = 0;

  // Не владеем dispose движка — им владеет readerEngineProvider через ref.onDispose.
  Fb2ReaderEngine? _engine;
  _ChapterLayout? _layout;

  // ── Анимация слайда ─────────────────────────────────────────────────────

  late final AnimationController _animCtrl;
  late final Animation<double> _animSlide;

  /// Уходящая страница: non-null пока идёт слайд-анимация.
  List<_PageItem>? _outgoingUnits;

  /// +1 = next (уходящая → влево, входящая въезжает справа).
  /// -1 = prev (уходящая → вправо, входящая въезжает слева).
  int _animDir = 1;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.readerPageTurnAnimMs),
    );
    _animSlide = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.addStatusListener((AnimationStatus status) {
      if (status == .completed && mounted) {
        setState(() => _outgoingUnits = null);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    // Снимаем хуки; движок принадлежит readerEngineProvider (ref.onDispose),
    // но вызываем dispose здесь тоже — он идемпотентен.
    _engine?.dispose();
    _unbindEngine();
    super.dispose();
  }

  // ── Привязка/отвязка хуков ──────────────────────────────────────────────

  void _bindEngine(Fb2ReaderEngine engine) {
    if (_engine == engine) return;
    _unbindEngine();
    _engine = engine;
    final rc = engine.renderController;
    rc.onNext = _onNext;
    rc.onPrev = _onPrev;
    rc.onJump = _onJump;
    rc.onRelayout = _onRelayout;
  }

  void _unbindEngine() {
    final rc = _engine?.renderController;
    if (rc != null) {
      rc.onNext = null;
      rc.onPrev = null;
      rc.onJump = null;
      rc.onRelayout = null;
    }
    _engine = null;
  }

  // ── Навигация ───────────────────────────────────────────────────────────

  void _onNext() {
    final _ChapterLayout? layout = _layout;
    if (layout == null) return;

    // Захватить уходящую страницу ДО setState.
    final List<_PageItem> outgoing =
        layout.pages.elementAtOrNull(_localPage)?.units ?? const [];

    int newPage = _localPage;
    int newChapter = _chapterIndex;
    _ChapterLayout? newLayout = layout;

    if (_localPage < layout.pageCount - 1) {
      newPage = _localPage + 1;
    } else {
      final List<ReaderChapter> chapters = _engine?.document.chapters ?? <ReaderChapter>[];
      if (_chapterIndex < chapters.length - 1) {
        newChapter = _chapterIndex + 1;
        newPage = 0;
        newLayout = null;
        _chapterIndex = newChapter;
        _layout = null;
        _ensureLayout();
        newLayout = _layout;
      }
    }

    setState(() {
      _chapterIndex = newChapter;
      _localPage = newPage;
      _layout = newLayout;
    });
    _report();

    _outgoingUnits = outgoing;
    _animDir = 1;
    _animCtrl.forward(from: 0.0);
  }

  void _onPrev() {
    // Захватить уходящую страницу ДО setState.
    final List<_PageItem> outgoing =
        _layout?.pages.elementAtOrNull(_localPage)?.units ?? const [];

    int newPage = _localPage;
    int newChapter = _chapterIndex;
    _ChapterLayout? newLayout = _layout;

    if (_localPage > 0) {
      newPage = _localPage - 1;
    } else if (_chapterIndex > 0) {
      newChapter = _chapterIndex - 1;
      _chapterIndex = newChapter;
      _layout = null;
      newLayout = _ensureLayout();
      newPage = newLayout == null ? 0 : math.max(0, newLayout.pageCount - 1);
    }

    setState(() {
      _chapterIndex = newChapter;
      _localPage = newPage;
      _layout = newLayout;
    });
    _report();

    _outgoingUnits = outgoing;
    _animDir = -1;
    _animCtrl.forward(from: 0.0);
  }

  void _onJump(int chapterIndex, int charOffset) {
    // Прыжок — мгновенно: останавливаем анимацию, если шла.
    _animCtrl.stop();
    _outgoingUnits = null;

    _chapterIndex = chapterIndex;
    _layout = null;
    final _ChapterLayout? layout = _ensureLayout();
    final int page = layout?.pageForOffset(charOffset) ?? 0;
    setState(() {
      _chapterIndex = chapterIndex;
      _localPage = page;
      _layout = layout;
    });
    _report();
  }

  void _onRelayout() {
    // Ре-вёрстка — мгновенно: останавливаем анимацию, если шла.
    _animCtrl.stop();
    _outgoingUnits = null;

    final int currentOffset =
        _layout?.pages.elementAtOrNull(_localPage)?.startCharOffset ?? 0;
    _layout = null;
    final _ChapterLayout? layout = _ensureLayout();
    final int page = layout?.pageForOffset(currentOffset) ?? 0;
    setState(() {
      _localPage = page;
      _layout = layout;
    });
    _report();
  }

  // ── Вёрстка ─────────────────────────────────────────────────────────────

  _ChapterLayout? _ensureLayout() {
    final Fb2ReaderEngine? engine = _engine;
    if (engine == null || _contentWidth == 0 || _pageHeight == 0) return null;
    final ReaderDocument doc = engine.document;
    if (doc.chapters.isEmpty) return null;
    final int ci = _chapterIndex.clamp(0, doc.chapters.length - 1);
    final ReaderChapter chapter = doc.chapters[ci];
    final _TextTheme theme = _TextTheme.resolve(engine.settings, context.appColors);
    final _LayoutKey key = _LayoutKey(ci, _contentWidth.round(), theme.settingsHash);
    final _ChapterLayout layout = _cache.putIfAbsent(
      key,
      () => _layoutChapter(
        chapter,
        _contentWidth,
        _pageHeight,
        theme,
        engine.images,
      ),
    );
    if (_layout != layout) _layout = layout;
    return layout;
  }

  // ── Репорт движку ────────────────────────────────────────────────────────

  void _report() {
    final _ChapterLayout? layout = _layout;
    final Fb2ReaderEngine? engine = _engine;
    if (layout == null || engine == null) return;
    final int page =
        _localPage.clamp(0, math.max(0, layout.pageCount - 1)).toInt();
    final int startOffset = layout.pages[page].startCharOffset;
    engine.renderController.updatePosition(
      chapterIndex: _chapterIndex,
      charOffset: startOffset,
      currentPage: page + 1,
      totalPages: layout.pageCount,
      pagesToNextChapter: layout.pageCount - page - 1,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ReaderEngine? engine = ref.watch(readerEngineProvider(widget.bookId));
    if (engine is Fb2ReaderEngine) _bindEngine(engine);

    final ReaderSettings settings = ref.watch(
      readerControllerProvider(widget.bookId).select((s) => s.settings),
    );
    final _TextTheme theme = _TextTheme.resolve(settings, context.appColors);

    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        final EdgeInsets padding = MediaQuery.paddingOf(ctx);
        final double hMargin = AppDimensions.readerHMargin(settings.marginStep);
        final double vMargin = AppDimensions.readerVMargin(settings.marginStep);
        final double contentWidth = constraints.maxWidth - 2 * hMargin;
        final double pageHeight = constraints.maxHeight
            - padding.top
            - padding.bottom
            - 2 * vMargin
            - AppDimensions.readerImmersiveFooterReservedHeight;

        final bool sizeChanged = contentWidth != _contentWidth ||
            pageHeight != _pageHeight ||
            hMargin != _hMargin ||
            vMargin != _vMargin;

        if (sizeChanged) {
          final int prevOffset =
              _layout?.pages.elementAtOrNull(_localPage)?.startCharOffset ?? 0;
          _hMargin = hMargin;
          _vMargin = vMargin;
          _contentWidth = contentWidth;
          _pageHeight = pageHeight;
          _layout = null;
          final _ChapterLayout? newLayout = _ensureLayout();
          if (newLayout != null) _localPage = newLayout.pageForOffset(prevOffset);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _report();
          });
        } else {
          _ensureLayout();
        }

        final _ChapterLayout? layout = _layout;
        final int localPage = layout == null
            ? 0
            : _localPage.clamp(0, math.max(0, layout.pageCount - 1)).toInt();
        final List<_PageItem> incomingUnits =
            layout?.pages.elementAtOrNull(localPage)?.units ?? const [];

        final List<_PageItem>? outgoing = _outgoingUnits;

        final Widget canvas = outgoing != null
            ? _SlideCanvas(
                animation: _animSlide,
                animDir: _animDir,
                outgoingUnits: outgoing,
                incomingUnits: incomingUnits,
                contentWidth: contentWidth,
                hMargin: hMargin,
                vMargin: vMargin + padding.top,
                paragraphIndent: AppDimensions.readerParagraphIndent,
                screenWidth: constraints.maxWidth,
              )
            : _PageCanvas(
                units: incomingUnits,
                contentWidth: contentWidth,
                hMargin: hMargin,
                vMargin: vMargin + padding.top,
                paragraphIndent: AppDimensions.readerParagraphIndent,
              );

        return ColoredBox(
          color: theme.bgColor,
          child: canvas,
        );
      },
    );
  }
}

// ─────────────────────────── Дочерний виджет холста ─────────────────────────

class _PageCanvas extends StatelessWidget {
  const _PageCanvas({
    required this.units,
    required this.contentWidth,
    required this.hMargin,
    required this.vMargin,
    required this.paragraphIndent,
  });

  final List<_PageItem> units;
  final double contentWidth;
  final double hMargin;
  final double vMargin;
  final double paragraphIndent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PagePainter(
        units: units,
        contentWidth: contentWidth,
        hMargin: hMargin,
        vMargin: vMargin,
        paragraphIndent: paragraphIndent,
      ),
      child: const SizedBox.expand(),
    );
  }
}

// ─────────────── Анимированный виджет двух страниц (слайд) ──────────────────

/// Рисует уходящую и входящую страницы бок о бок со сдвигом по X, управляемым
/// [animation] (0.0 → 1.0). [animDir]: +1 = next, -1 = prev.
class _SlideCanvas extends StatelessWidget {
  const _SlideCanvas({
    required this.animation,
    required this.animDir,
    required this.outgoingUnits,
    required this.incomingUnits,
    required this.contentWidth,
    required this.hMargin,
    required this.vMargin,
    required this.paragraphIndent,
    required this.screenWidth,
  });

  final Animation<double> animation;
  final int animDir;
  final List<_PageItem> outgoingUnits;
  final List<_PageItem> incomingUnits;
  final double contentWidth;
  final double hMargin;
  final double vMargin;
  final double paragraphIndent;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext ctx, Widget? _) {
          final double t = animation.value;
          // Уходящая: двигается в сторону animDir (влево при next, вправо при prev).
          final double outTx = -animDir * t * screenWidth;
          // Входящая: въезжает с противоположной стороны к 0.
          final double inTx = animDir * (1.0 - t) * screenWidth;
          return Stack(
            children: [
              Transform.translate(
                offset: Offset(outTx, 0),
                child: _PageCanvas(
                  units: outgoingUnits,
                  contentWidth: contentWidth,
                  hMargin: hMargin,
                  vMargin: vMargin,
                  paragraphIndent: paragraphIndent,
                ),
              ),
              Transform.translate(
                offset: Offset(inTx, 0),
                child: _PageCanvas(
                  units: incomingUnits,
                  contentWidth: contentWidth,
                  hMargin: hMargin,
                  vMargin: vMargin,
                  paragraphIndent: paragraphIndent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
