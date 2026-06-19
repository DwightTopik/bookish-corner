import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/di/reader_providers.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/core/theme/highlight_colors.dart';
import 'package:bookish_corner/features/reader/data/fb2_reader_engine.dart';
import 'package:bookish_corner/features/reader/data/fb2_render_controller.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_annotations_provider.dart';

// ── Painter ──────────────────────────────────────────────────────────────────

class _HighlightsPainter extends CustomPainter {
  _HighlightsPainter({
    required this.annotations,
    required this.rc,
    required this.colors,
    required this.slideDx,
  });

  final List<ReaderAnnotation> annotations;
  final Fb2RenderController rc;
  final AppColors colors;

  /// Смещение входящей страницы по X (кадр слайд-анимации). Хайлайт «едет»
  /// вместе с текстом.
  final double slideDx;

  @override
  void paint(Canvas canvas, Size size) {
    final int? chapter = rc.chapterIndex;
    if (chapter == null) return;
    final double hm = (rc.onGeometry?.call()?.hMargin ?? 0) + slideDx;
    final double vm = rc.onGeometry?.call()?.vMargin ?? 0;

    for (final ReaderAnnotation(
          chapterIndex: aChapter,
          :charStart,
          :charEnd,
          :color,
          :type,
        ) in annotations) {
      if (aChapter != chapter) continue;

      switch (type) {
        case .note:
          // Заметка — подчёркивание у базовой линии насыщенным цветом.
          final unders = rc.underlinesForCharRange(
            charStart,
            charEnd,
            thickness: AppDimensions.readerHighlightUnderlineThickness,
            gap: AppDimensions.readerHighlightUnderlineGap,
          );
          if (unders.isEmpty) continue;
          final paint = Paint()..color = highlightSwatchColor(color, colors);
          for (final r in unders) {
            canvas.drawRect(r.translate(hm, vm), paint);
          }
        case .quote:
          // Цитата — полупрозрачная заливка-маркер.
          final rects = rc.rectsForCharRange(charStart, charEnd);
          if (rects.isEmpty) continue;
          final paint = Paint()..color = highlightTint(color, colors);
          for (final r in rects) {
            canvas.drawRect(r.translate(hm, vm), paint);
          }
      }
    }
  }

  @override
  bool shouldRepaint(_HighlightsPainter old) =>
      !identical(old.annotations, annotations) ||
      old.rc != rc ||
      old.colors != colors ||
      old.slideDx != slideDx;
}

// ── Виджет ───────────────────────────────────────────────────────────────────

/// IgnorePointer слой над ReaderView: рисует char-based хайлайты сохранённых
/// аннотаций. Repaint на каждый rc.notifyListeners (смена страницы/главы/
/// relayout). Вне _LayoutKey — add/remove/color = repaint, не relayout.
class ReaderHighlightsLayer extends ConsumerWidget {
  const ReaderHighlightsLayer({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annotationsAsync = ref.watch(readerAnnotationsProvider(bookId));
    final annotations = annotationsAsync.asData?.value ?? const <ReaderAnnotation>[];
    final colors = context.appColors;

    final engine = ref.watch(readerEngineProvider(bookId));
    if (engine is! Fb2ReaderEngine) return const SizedBox.shrink();
    final Fb2RenderController rc = engine.renderController;

    // Вложенные ListenableBuilder'ы. Внешний слушает rc (notify на смене
    // страницы/relayout) — его builder перезапускается при старте слайда (вью
    // зовёт beginPageSlide ДО _report), поэтому подхватывает rc.pageSlide.
    // Внутренний подписывается на анимацию слайда → покадровый repaint, пока
    // текст едет. Так подписка не зависит от перестроения ConsumerWidget.
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: rc,
        builder: (_, _) {
          final Listenable frameSignal = rc.pageSlide ?? rc;
          return ListenableBuilder(
            listenable: frameSignal,
            builder: (_, _) => CustomPaint(
              painter: _HighlightsPainter(
                annotations: annotations,
                rc: rc,
                colors: colors,
                slideDx: rc.incomingSlideDx,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}
