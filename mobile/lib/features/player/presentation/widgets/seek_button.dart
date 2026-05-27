import 'package:flutter/material.dart';

import 'package:bookish_corner/core/theme/app_colors.dart';

class SeekButton extends StatelessWidget {
  const SeekButton({
    super.key,
    required this.seconds,
    required this.onTap,
    this.size = 36,
    this.iconColor,
  });

  final int seconds;
  final VoidCallback onTap;
  final double size;
  final Color? iconColor;

  bool get _isForward => seconds > 0;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? context.appColors.textPrimary;

    final icon = Transform.scale(
      scaleX: _isForward ? -1.0 : 1.0,
      child: Icon(Icons.replay, color: color, size: size),
    );

    return InkResponse(
      onTap: onTap,
      radius: size * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          icon,
          Text(
            '${seconds.abs()}',
            style: TextStyle(
              color: color,
              fontSize: size * 0.36,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
