import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_providers.dart';
import 'package:bookish_corner/features/player/presentation/widgets/horizontal_picker.dart';

class SpeedPickerSheet extends ConsumerWidget {
  const SpeedPickerSheet({super.key});

  static const values = <double>[0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final speed = ref.watch(playerProvider).speed;
    final initial = values.indexWhere((value) => value == speed);
    return _PlayerSheetFrame(
      title: 'Скорость',
      backgroundColor: colors.elevated,
      child: HorizontalPicker<double>(
        values: values,
        initialIndex: initial < 0 ? 2 : initial,
        labelFor: _formatSpeed,
        onChanged: (value) => ref.read(playerProvider.notifier).setSpeed(value),
        onSettled: (value) => ref.read(playerProvider.notifier).setSpeed(value),
      ),
    );
  }

  String _formatSpeed(double value) {
    if (value == 0.75) return '0.75x';
    return '${value.toStringAsFixed(1)}x';
  }
}

class _PlayerSheetFrame extends StatelessWidget {
  const _PlayerSheetFrame({
    required this.title,
    required this.child,
    required this.backgroundColor,
  });

  final String title;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      top: false,
      child: ColoredBox(
        color: backgroundColor,
        child: Padding(
          padding: const .fromLTRB(16, 10, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textTertiary,
                  borderRadius: const .all(.circular(99)),
                ),
              ),
              const Gap(28),
              Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
