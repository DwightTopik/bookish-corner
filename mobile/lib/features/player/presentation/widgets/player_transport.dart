import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/player/presentation/widgets/seek_button.dart';

class PlayerTransport extends StatelessWidget {
  const PlayerTransport({
    super.key,
    required this.playing,
    required this.onPrevious,
    required this.onBack,
    required this.onPlayPause,
    required this.onForward,
    required this.onNext,
  });

  final bool playing;
  final VoidCallback onPrevious;
  final VoidCallback onBack;
  final VoidCallback onPlayPause;
  final VoidCallback onForward;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :bg) = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Предыдущая глава',
          onPressed: onPrevious,
          icon: Icon(
            Icons.skip_previous,
            color: textPrimary,
            size: AppDimensions.playerSkipButtonSize,
          ),
        ),
        const Gap(AppDimensions.playerControlsHGap),
        SeekButton(
          seconds: -15,
          onTap: onBack,
          size: AppDimensions.playerSeekButtonSize,
        ),
        const Gap(AppDimensions.playerControlsHGap),
        SizedBox.square(
          dimension: AppDimensions.playerPlayButtonSize,
          child: FilledButton(
            onPressed: onPlayPause,
            style: FilledButton.styleFrom(
              backgroundColor: textPrimary,
              foregroundColor: bg,
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            child: Icon(playing ? Icons.pause : Icons.play_arrow, size: 34),
          ),
        ),
        const Gap(AppDimensions.playerControlsHGap),
        SeekButton(
          seconds: 30,
          onTap: onForward,
          size: AppDimensions.playerSeekButtonSize,
        ),
        const Gap(AppDimensions.playerControlsHGap),
        IconButton(
          tooltip: 'Следующая глава',
          onPressed: onNext,
          icon: Icon(
            Icons.skip_next,
            color: textPrimary,
            size: AppDimensions.playerSkipButtonSize,
          ),
        ),
      ],
    );
  }
}
