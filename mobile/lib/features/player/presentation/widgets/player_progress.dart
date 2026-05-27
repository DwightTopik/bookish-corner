import 'package:flutter/material.dart';

import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_state.dart';

class PlayerProgress extends StatelessWidget {
  const PlayerProgress({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final PlayerState state;
  final ValueChanged<Duration> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors(:textPrimary, :textSecondary, :border) = context.appColors;
    final maxMs = state.chapterDuration.inMilliseconds;
    final valueMs = state.position.inMilliseconds.clamp(0, maxMs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: textPrimary,
            inactiveTrackColor: border,
            thumbColor: textPrimary,
            overlayColor: textPrimary.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: valueMs.toDouble(),
            max: maxMs <= 0 ? 1 : maxMs.toDouble(),
            onChanged: maxMs <= 0
                ? null
                : (value) => onChanged(Duration(milliseconds: value.round())),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _format(state.position),
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
            Text(
              _format(state.chapterDuration),
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '${d.inMinutes}:$seconds';
  }
}
