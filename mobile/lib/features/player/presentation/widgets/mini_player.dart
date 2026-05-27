import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_providers.dart';
import 'package:bookish_corner/features/player/presentation/widgets/seek_button.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final book = state.book;
    if (book == null) return const SizedBox.shrink();
    final colors = context.appColors;
    final AppColors(:elevated, :border, :accent, :textPrimary, :textSecondary) =
        colors;
    final Book(:id, :coverImagePath, :title) = book;

    return Material(
      color: elevated,
      child: InkWell(
        onTap: () => context.push('/player/$id'),
        child: SizedBox(
          height: AppDimensions.miniPlayerHeight,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: state.chapterDuration.inMilliseconds <= 0
                    ? 0
                    : state.position.inMilliseconds /
                          state.chapterDuration.inMilliseconds,
                minHeight: 1,
                backgroundColor: border,
                color: accent,
              ),
              Expanded(
                child: Padding(
                  padding: const .symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      _MiniCover(path: coverImagePath),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.currentChapter?.title ?? title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SeekButton(
                        seconds: -15,
                        size: 30,
                        onTap: () {
                          ref
                              .read(playerProvider.notifier)
                              .seekBy(const Duration(seconds: -15));
                        },
                      ),
                      IconButton(
                        tooltip: state.playing ? 'Пауза' : 'Играть',
                        onPressed: () {
                          ref.read(playerProvider.notifier).togglePlay();
                        },
                        icon: Icon(
                          state.playing ? Icons.pause : Icons.play_arrow,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCover extends StatelessWidget {
  const _MiniCover({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final AppColors(:surface, :textTertiary) = context.appColors;
    final coverPath = path;
    return ClipRRect(
      borderRadius: const .all(.circular(AppDimensions.miniPlayerCoverRadius)),
      child: SizedBox.square(
        dimension: AppDimensions.miniPlayerCoverSize,
        child: coverPath != null && File(coverPath).existsSync()
            ? Image.file(File(coverPath), fit: BoxFit.cover)
            : ColoredBox(
                color: surface,
                child: Icon(Icons.headphones, color: textTertiary, size: 22),
              ),
      ),
    );
  }
}
