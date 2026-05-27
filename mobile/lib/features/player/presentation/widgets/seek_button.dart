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
    return IconButton(
      onPressed: onTap,
      icon: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              _isForward ? Icons.refresh : Icons.refresh,
              size: size,
              color: color,
              textDirection: _isForward ? TextDirection.ltr : TextDirection.rtl,
            ),
            Padding(
              padding: const .only(top: 4),
              child: Text(
                seconds.abs().toString(),
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
