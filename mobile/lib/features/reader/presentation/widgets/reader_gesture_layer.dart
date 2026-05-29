import 'package:flutter/material.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';

/// Прозрачный слой жестов над [ReaderView] и под overlay-панелями (по z-order).
///
/// Три вертикальные зоны (центр чуть шире): тап слева → [onPrev], по центру →
/// [onToggle], справа → [onNext]. Горизонтальный свайп листает по знаку
/// `primaryVelocity`. Зоны активны в обоих состояниях chrome; панели top/bottom
/// выше по z-order и съедают свои тапы. Никакой анимации контента — только
/// вызов интентов.
class ReaderGestureLayer extends StatelessWidget {
  const ReaderGestureLayer({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onToggle,
  });

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToggle;

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity <= -AppDimensions.readerSwipeVelocityThreshold) {
      onNext();
    } else if (velocity >= AppDimensions.readerSwipeVelocityThreshold) {
      onPrev();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Row(
        children: [
          Expanded(
            flex: (AppDimensions.readerZoneLeftFraction * 100).round(),
            child: _ReaderTapZone(onTap: onPrev),
          ),
          Expanded(
            flex: (AppDimensions.readerZoneCenterFraction * 100).round(),
            child: _ReaderTapZone(onTap: onToggle),
          ),
          Expanded(
            flex: (AppDimensions.readerZoneRightFraction * 100).round(),
            child: _ReaderTapZone(onTap: onNext),
          ),
        ],
      ),
    );
  }
}

class _ReaderTapZone extends StatelessWidget {
  const _ReaderTapZone({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const SizedBox.expand(),
    );
  }
}
