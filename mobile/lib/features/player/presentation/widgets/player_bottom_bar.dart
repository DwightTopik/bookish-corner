import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_state.dart';

class PlayerBottomBar extends StatelessWidget {
  const PlayerBottomBar({
    super.key,
    required this.state,
    required this.onChapters,
    required this.onSleep,
    required this.onSpeed,
    required this.onBookmark,
  });

  final PlayerState state;
  final VoidCallback onChapters;
  final VoidCallback onSleep;
  final VoidCallback onSpeed;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.playerBottomBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BarAction(
            icon: Icons.format_list_bulleted,
            label: 'Главы',
            onTap: onChapters,
          ),
          _BarAction(
            icon: Icons.bedtime_outlined,
            label: _sleepLabel(),
            onTap: onSleep,
          ),
          _BarAction(
            icon: Icons.speed,
            label: '${state.speed.toStringAsFixed(1)}x',
            onTap: onSpeed,
          ),
          _BarAction(
            icon: state.bookmarked ? Icons.bookmark : Icons.bookmark_border,
            label: 'Метка',
            onTap: onBookmark,
          ),
        ],
      ),
    );
  }

  String _sleepLabel() {
    final remaining = state.sleepRemaining;
    if (remaining == null) return 'Таймер';
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    if (remaining.inHours > 0) return '${remaining.inHours}:$minutes:$seconds';
    return '$minutes:$seconds';
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.appColors.textSecondary;
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textSecondary, size: 22),
            const Gap(5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
