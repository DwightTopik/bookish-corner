import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/player/domain/sleep_timer_option.dart';
import 'package:bookish_corner/features/player/presentation/providers/player_providers.dart';
import 'package:bookish_corner/features/player/presentation/widgets/horizontal_picker.dart';

class SleepTimerSheet extends ConsumerWidget {
  const SleepTimerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final initial = _selectedIndex(state.sleepTimer);
    final AppColors(:elevated, :textPrimary) = context.appColors;
    return SafeArea(
      top: false,
      child: ColoredBox(
        color: elevated,
        child: Padding(
          padding: const .fromLTRB(16, 10, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              const Gap(28),
              Text(
                'Таймер сна',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              HorizontalPicker<SleepTimerOption>(
                values: sleepTimerPresets,
                initialIndex: initial,
                labelFor: (value) => value.label,
                onSettled: (value) {
                  ref.read(playerProvider.notifier).setSleepTimer(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _selectedIndex(SleepTimerOption current) {
    for (int i = 0; i < sleepTimerPresets.length; i++) {
      final preset = sleepTimerPresets[i];
      if (current.runtimeType != preset.runtimeType) continue;
      if (current is SleepTimerDuration && preset is SleepTimerDuration) {
        if (current.duration == preset.duration) return i;
      } else {
        return i;
      }
    }
    return 0;
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: context.appColors.textTertiary,
        borderRadius: const .all(.circular(99)),
      ),
    );
  }
}
