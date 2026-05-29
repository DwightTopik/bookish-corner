import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_ui_state.dart';

/// Нижняя панель chrome (над тулбаром, видна при `chromeVisible`).
///
/// Ряд A — глава (display-only) + сколько страниц до следующей.
/// Ряд B — слайдер прогресса по всей книге (со scrubbing).
/// Ряд C — «% от всей книги» + «Назад»/«Вперёд» (undo/redo = D6, сейчас скрыты).
class ReaderBottomPanel extends StatelessWidget {
  const ReaderBottomPanel({
    super.key,
    required this.state,
    required this.onSeek,
    required this.onBack,
    required this.onForward,
  });

  final ReaderUiState state;
  final ValueChanged<double> onSeek;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :textSecondary) = context.appColors;
    final progress = state.progress;
    final chapterIndex = progress?.locator.chapterIndex ?? 0;
    final pagesToNext = progress?.pagesToNextChapter;
    final bookProgress = progress?.locator.progress ?? 0;

    return Padding(
      padding: const .symmetric(
        horizontal: AppDimensions.readerPanelHPadding,
        vertical: AppDimensions.readerPanelVPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 18,
                    color: textSecondary,
                  ),
                  const Gap(AppDimensions.smallGap),
                  Text(
                    'Глава ${chapterIndex + 1}',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (pagesToNext != null)
                Text(
                  'ещё $pagesToNext стр',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
            ],
          ),
          const Gap(AppDimensions.readerPanelRowGap),
          _BookProgressSlider(value: bookProgress, onSeek: onSeek),
          const Gap(AppDimensions.readerPanelRowGap),
          _ProgressFooterRow(
            bookProgress: bookProgress,
            canGoBack: state.navHistory.canGoBack,
            canGoForward: state.navHistory.canGoForward,
            onBack: onBack,
            onForward: onForward,
          ),
        ],
      ),
    );
  }
}

/// Слайдер прогресса по всей книге со scrubbing: пока тащим — держим локальное
/// значение и показываем живой %, на onChangeEnd → [onSeek]. Пока тащим, стрим
/// движка не влияет на позицию ручки (чтобы не дёргалось).
class _BookProgressSlider extends StatefulWidget {
  const _BookProgressSlider({required this.value, required this.onSeek});

  final double value;
  final ValueChanged<double> onSeek;

  @override
  State<_BookProgressSlider> createState() => _BookProgressSliderState();
}

class _BookProgressSliderState extends State<_BookProgressSlider> {
  double? _scrubValue;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :border) = context.appColors;
    final value = (_scrubValue ?? widget.value).clamp(0.0, 1.0);
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        activeTrackColor: textPrimary,
        inactiveTrackColor: border,
        thumbColor: textPrimary,
        overlayColor: textPrimary.withValues(alpha: 0.12),
      ),
      child: Slider(
        value: value,
        onChanged: (v) => setState(() => _scrubValue = v),
        onChangeEnd: (v) {
          widget.onSeek(v);
          setState(() => _scrubValue = null);
        },
      ),
    );
  }
}

class _ProgressFooterRow extends StatelessWidget {
  const _ProgressFooterRow({
    required this.bookProgress,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final double bookProgress;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.appColors.textSecondary;
    final percent = (bookProgress.clamp(0.0, 1.0) * 100).round();
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Text(
            '$percent% от всей книги',
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (canGoBack)
              TextButton(onPressed: onBack, child: const Text('Назад'))
            else
              const SizedBox.shrink(),
            if (canGoForward)
              TextButton(onPressed: onForward, child: const Text('Вперёд'))
            else
              const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}
