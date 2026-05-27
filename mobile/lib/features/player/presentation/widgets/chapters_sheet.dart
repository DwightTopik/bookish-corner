import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/player/domain/audio_chapter.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_providers.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_state.dart';

class ChaptersSheet extends ConsumerWidget {
  const ChaptersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final AppColors(:elevated, :border) = colors;
    final state = ref.watch(playerProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.48,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return ColoredBox(
          color: elevated,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const .only(left: 20, top: 10, right: 20),
              child: Column(
                children: [
                  const _SheetHandle(),
                  const Gap(18),
                  _SheetHeader(count: state.chapters.length),
                  const Gap(12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const .only(bottom: 18),
                      itemCount: state.chapters.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: border),
                      itemBuilder: (context, index) {
                        return _ChapterRow(
                          state: state,
                          chapter: state.chapters[index],
                          index: index,
                          active: index == state.chapterIndex,
                          onTap: () {
                            ref
                                .read(playerProvider.notifier)
                                .jumpToChapter(index);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 5,
      decoration: BoxDecoration(
        color: context.appColors.textTertiary.withValues(alpha: 0.65),
        borderRadius: const .all(.circular(99)),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :textTertiary) = context.appColors;
    return Row(
      children: [
        IconButton(
          tooltip: 'Закрыть',
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: textPrimary),
        ),
        Expanded(
          child: Text(
            'Оглавление',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            color: textTertiary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.state,
    required this.chapter,
    required this.index,
    required this.active,
    required this.onTap,
  });

  final PlayerState state;
  final AudioChapter chapter;
  final int index;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final AppColors(:textPrimary, :textSecondary, :textTertiary, :accent) =
        colors;
    final titleColor = active ? textPrimary : textSecondary;
    final metaColor = active ? accent : textTertiary;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 68,
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: metaColor,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                chapter.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ),
            const Gap(12),
            Text(
              _durationFor(state, chapter),
              style: TextStyle(
                color: textTertiary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _durationFor(PlayerState state, AudioChapter chapter) {
    final duration = active && state.chapterDuration > .zero
        ? state.chapterDuration
        : chapter.duration;
    if (duration <= .zero) return '--:--:--';
    return _format(duration);
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
