import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_controller.dart';

/// Открывает sheet настроек ридера. [context] должен быть в дереве выше [Scaffold].
void showReaderSettingsSheet(BuildContext context, String bookId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: ReaderSettingsSheet(bookId: bookId),
    ),
  );
}

/// Содержимое sheet настроек ридера. Публичный для тестирования.
class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(
      readerControllerProvider(bookId).select((s) => s.settings),
    );
    final colors = context.appColors;

    void update(ReaderSettings next) =>
        ref.read(readerControllerProvider(bookId).notifier).updateSettings(next);

    return DraggableScrollableSheet(
      initialChildSize: 0.50,
      minChildSize: 0.36,
      maxChildSize: 0.50,
      expand: false,
      builder: (_, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: const .vertical(top: .circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: .min,
            children: [
              const _DragHandle(),
              // ── Тема (pill-чипы) ──────────────────────────────────────────
              _BackgroundRow(
                selected: settings.background,
                colors: colors,
                onSelect: (bg) => update(settings.copyWith(background: bg)),
              ),
              _SettingsDivider(colors: colors),
              // ── Шрифт + размер (с точками под названием шрифта) ──────────
              _FontAndSizeRow(
                selectedFont: settings.fontFamily,
                fontSizeStep: settings.fontSizeStep,
                colors: colors,
                canDecrement: settings.fontSizeStep > -3,
                canIncrement: settings.fontSizeStep < 5,
                onPrevFont: () {
                  final int idx = _fontKeys.indexOf(settings.fontFamily);
                  final int next = (idx - 1).clamp(0, _fontKeys.length - 1);
                  update(settings.copyWith(fontFamily: _fontKeys[next]));
                },
                onNextFont: () {
                  final int idx = _fontKeys.indexOf(settings.fontFamily);
                  final int next = (idx + 1).clamp(0, _fontKeys.length - 1);
                  update(settings.copyWith(fontFamily: _fontKeys[next]));
                },
                onDecrement: () =>
                    update(settings.copyWith(fontSizeStep: settings.fontSizeStep - 1)),
                onIncrement: () =>
                    update(settings.copyWith(fontSizeStep: settings.fontSizeStep + 1)),
              ),
              _SettingsDivider(colors: colors),
              // ── Группа расположения: выравнивание + межстрочный ──────────
              _AlignSpacingRow(
                selectedAlign: settings.textAlign,
                selectedSpacing: settings.lineSpacingStep,
                colors: colors,
                onSelectAlign: (a) => update(settings.copyWith(textAlign: a)),
                onSelectSpacing: (s) => update(settings.copyWith(lineSpacingStep: s)),
              ),
              // ── Поля (тот же стиль, без дивайдера между ними) ────────────
              _MarginRow(
                selectedMargin: settings.marginStep,
                colors: colors,
                onSelect: (m) => update(settings.copyWith(marginStep: m)),
              ),
              _SettingsDivider(colors: colors),
              // ── Яркость ───────────────────────────────────────────────────
              _BrightnessRow(
                useSystem: settings.useSystemBrightness,
                brightness: settings.brightness ?? 1.0,
                colors: colors,
                onToggleSystem: () {
                  if (settings.useSystemBrightness) {
                    update(settings.copyWith(
                      useSystemBrightness: false,
                      brightness: 1.0,
                    ));
                  } else {
                    update(settings.copyWith(
                      useSystemBrightness: true,
                      clearBrightness: true,
                    ));
                  }
                },
                onBrightnessChange: (v) =>
                    update(settings.copyWith(brightness: v)),
              ),
              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> _fontKeys = [
    'Default', 'Roboto', 'PTSerif', 'PTSans', 'Playfair',
  ];
}

// ──────────────────────────── Drag handle ────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: AppDimensions.readerSettingsHandleWidth,
          height: AppDimensions.readerSettingsHandleHeight,
          decoration: BoxDecoration(
            color: context.appColors.textTertiary,
            borderRadius: const .all(
              .circular(AppDimensions.readerSettingsHandleHeight / 2),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── Divider ─────────────────────────────────────────

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: colors.border);
  }
}

// ──────────────────────────── Background (pill chips) ────────────────────────

class _BackgroundRow extends StatelessWidget {
  const _BackgroundRow({
    required this.selected,
    required this.colors,
    required this.onSelect,
  });

  final ReaderBackground selected;
  final AppColors colors;
  final ValueChanged<ReaderBackground> onSelect;

  Color _bgFor(ReaderBackground bg) => switch (bg) {
    .white  => colors.readerWhiteBg,
    .sepia  => colors.readerSepiaBg,
    .gray   => colors.readerGrayBg,
    .black  => colors.readerBlackBg,
    .system => colors.surface,
  };

  Color _textFor(ReaderBackground bg) => switch (bg) {
    .white  => colors.readerWhiteText,
    .sepia  => colors.readerSepiaText,
    .gray   => colors.readerGrayText,
    .black  => colors.readerBlackText,
    .system => colors.textPrimary,
  };

  @override
  Widget build(BuildContext context) {
    const options = [
      (ReaderBackground.white,  'Белый'),
      (ReaderBackground.sepia,  'Сепия'),
      (ReaderBackground.gray,   'Серый'),
      (ReaderBackground.black,  'Чёрный'),
      (ReaderBackground.system, 'Как в системе'),
    ];
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      padding: const .symmetric(
        horizontal: AppDimensions.screenHPadding,
        vertical: 10,
      ),
      child: Row(
        spacing: 8,
        children: [
          for (final (bg, label) in options)
            _ThemeChip(
              bgColor: _bgFor(bg),
              textColor: _textFor(bg),
              label: label,
              isSelected: selected == bg,
              accentColor: colors.accent,
              borderFallback: colors.border,
              onTap: () => onSelect(bg),
            ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.bgColor,
    required this.textColor,
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.borderFallback,
    required this.onTap,
  });

  final Color bgColor;
  final Color textColor;
  final String label;
  final bool isSelected;
  final Color accentColor;
  final Color borderFallback;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: AppDimensions.readerSettingsThemeChipHeight,
        padding: const .symmetric(
          horizontal: AppDimensions.readerSettingsThemeChipHPadding,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const .all(
            .circular(AppDimensions.readerSettingsThemeChipRadius),
          ),
          border: .fromBorderSide(
            BorderSide(
              color: isSelected ? accentColor : borderFallback,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.readerSettingsThemeChipFontSize,
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── Font carousel + size stepper ───────────────────

class _FontAndSizeRow extends StatelessWidget {
  const _FontAndSizeRow({
    required this.selectedFont,
    required this.fontSizeStep,
    required this.colors,
    required this.canDecrement,
    required this.canIncrement,
    required this.onPrevFont,
    required this.onNextFont,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String selectedFont;
  final int fontSizeStep;
  final AppColors colors;
  final bool canDecrement;
  final bool canIncrement;
  final VoidCallback onPrevFont;
  final VoidCallback onNextFont;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  static const List<(String, String, String?)> _fonts = [
    ('Default',  'По умолч.',   null),
    ('Roboto',   'Roboto',      'Roboto'),
    ('PTSerif',  'PT Serif',    'PT Serif'),
    ('PTSans',   'PT Sans',     'PT Sans'),
    ('Playfair', 'Playfair',    'Playfair Display'),
  ];

  static const List<String> _fontKeys = [
    'Default', 'Roboto', 'PTSerif', 'PTSans', 'Playfair',
  ];

  @override
  Widget build(BuildContext context) {
    final int idx =
        _fonts.indexWhere((e) => e.$1 == selectedFont).clamp(0, _fonts.length - 1);
    final (_, String label, String? family) = _fonts[idx];
    final double fontSize = AppDimensions.readerFontSize(fontSizeStep);

    return Padding(
      padding: const .symmetric(
        horizontal: AppDimensions.screenHPadding,
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          // ── Left: font carousel + dots below ────────────────────────────
          Expanded(
            child: Column(
              mainAxisSize: .min,
              children: [
                SizedBox(
                  height: AppDimensions.readerSettingsControlHeight,
                  child: Row(
                    children: [
                      _StepButton(
                        icon: Icons.chevron_left,
                        enabled: idx > 0,
                        colors: colors,
                        onTap: idx > 0 ? onPrevFont : null,
                      ),
                      Expanded(
                        child: Text(
                          label,
                          textAlign: .center,
                          style: TextStyle(
                            fontFamily: family,
                            fontSize: 16,
                            color: colors.textPrimary,
                            fontWeight: .w500,
                          ),
                        ),
                      ),
                      _StepButton(
                        icon: Icons.chevron_right,
                        enabled: idx < _fonts.length - 1,
                        colors: colors,
                        onTap: idx < _fonts.length - 1 ? onNextFont : null,
                      ),
                    ],
                  ),
                ),
                // Dots — centered under the font name segment
                Row(
                  mainAxisAlignment: .center,
                  spacing: AppDimensions.readerSettingsDotSpacing,
                  children: [
                    for (int i = 0; i < _fontKeys.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: AppDimensions.readerSettingsDotSize,
                        height: AppDimensions.readerSettingsDotSize,
                        decoration: BoxDecoration(
                          color: i == idx ? colors.accent : colors.border,
                          shape: .circle,
                        ),
                      ),
                  ],
                ),
                const Gap(6),
              ],
            ),
          ),
          // ── Separator ───────────────────────────────────────────────────
          Container(
            width: 1,
            height: 28,
            margin: const .symmetric(horizontal: 10),
            color: colors.border,
          ),
          // ── Right: size stepper ─────────────────────────────────────────
          _StepButton(
            icon: Icons.remove,
            enabled: canDecrement,
            colors: colors,
            onTap: canDecrement ? onDecrement : null,
          ),
          Padding(
            padding: const .symmetric(horizontal: 8),
            child: Text(
              '${fontSize.toInt()}pt',
              style: TextStyle(
                fontSize: 15,
                color: colors.textPrimary,
                fontWeight: .w500,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            enabled: canIncrement,
            colors: colors,
            onTap: canIncrement ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Alignment + line spacing ───────────────────────

class _AlignSpacingRow extends StatelessWidget {
  const _AlignSpacingRow({
    required this.selectedAlign,
    required this.selectedSpacing,
    required this.colors,
    required this.onSelectAlign,
    required this.onSelectSpacing,
  });

  final ReaderTextAlign selectedAlign;
  final int selectedSpacing;
  final AppColors colors;
  final ValueChanged<ReaderTextAlign> onSelectAlign;
  final ValueChanged<int> onSelectSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(
        horizontal: AppDimensions.screenHPadding,
        vertical: 4,
      ),
      child: SizedBox(
        height: AppDimensions.readerSettingsControlHeight,
        child: Row(
          children: [
            // Alignment chips
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: _CompactIconChip(
                      icon: Icons.format_align_left,
                      isSelected: selectedAlign == .left,
                      colors: colors,
                      onTap: () => onSelectAlign(.left),
                    ),
                  ),
                  Expanded(
                    child: _CompactIconChip(
                      icon: Icons.format_align_justify,
                      isSelected: selectedAlign == .justify,
                      colors: colors,
                      onTap: () => onSelectAlign(.justify),
                    ),
                  ),
                ],
              ),
            ),
            // Vertical separator
            Container(
              width: 1,
              margin: const .all(10),
              color: colors.border,
            ),
            // Line spacing chips
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: _CompactIconChip(
                      icon: Icons.density_small,
                      isSelected: selectedSpacing == 0,
                      colors: colors,
                      onTap: () => onSelectSpacing(0),
                    ),
                  ),
                  Expanded(
                    child: _CompactIconChip(
                      icon: Icons.density_medium,
                      isSelected: selectedSpacing == 1,
                      colors: colors,
                      onTap: () => onSelectSpacing(1),
                    ),
                  ),
                  Expanded(
                    child: _CompactIconChip(
                      icon: Icons.density_large,
                      isSelected: selectedSpacing == 2,
                      colors: colors,
                      onTap: () => onSelectSpacing(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────── Margins (icon chips) ───────────────────────────

class _MarginRow extends StatelessWidget {
  const _MarginRow({
    required this.selectedMargin,
    required this.colors,
    required this.onSelect,
  });

  final int selectedMargin;
  final AppColors colors;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(
        horizontal: AppDimensions.screenHPadding,
        vertical: 4,
      ),
      child: SizedBox(
        height: AppDimensions.readerSettingsControlHeight,
        child: Row(
          spacing: 8,
          children: [
            // Narrow margins — wide text column
            Expanded(
              child: _CompactIconChip(
                icon: Icons.view_headline,
                isSelected: selectedMargin == 0,
                colors: colors,
                onTap: () => onSelect(0),
              ),
            ),
            // Normal margins
            Expanded(
              child: _CompactIconChip(
                icon: Icons.notes,
                isSelected: selectedMargin == 1,
                colors: colors,
                onTap: () => onSelect(1),
              ),
            ),
            // Wide margins — narrow text column
            Expanded(
              child: _CompactIconChip(
                icon: Icons.short_text,
                isSelected: selectedMargin == 2,
                colors: colors,
                onTap: () => onSelect(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────── Brightness ─────────────────────────────────────

class _BrightnessRow extends StatelessWidget {
  const _BrightnessRow({
    required this.useSystem,
    required this.brightness,
    required this.colors,
    required this.onToggleSystem,
    required this.onBrightnessChange,
  });

  final bool useSystem;
  final double brightness;
  final AppColors colors;
  final VoidCallback onToggleSystem;
  final ValueChanged<double> onBrightnessChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: AppDimensions.screenHPadding),
      child: Column(
        children: [
          SizedBox(
            height: AppDimensions.readerSettingsControlHeight,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Системная яркость',
                    style: TextStyle(
                      fontSize: 15,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: useSystem,
                  onChanged: (_) => onToggleSystem(),
                  activeThumbColor: colors.accent,
                ),
              ],
            ),
          ),
          if (!useSystem)
            Padding(
              padding: const .only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_low_rounded,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                  Expanded(
                    child: Slider(
                      value: brightness,
                      min: 0.2,
                      max: 1.0,
                      activeColor: colors.accent,
                      inactiveColor: colors.border,
                      onChanged: onBrightnessChange,
                    ),
                  ),
                  Icon(
                    Icons.brightness_high_rounded,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Step button ────────────────────────────────────

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.readerSettingsControlHeight,
        height: AppDimensions.readerSettingsControlHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const .all(.circular(AppDimensions.readerSettingsPillRadius)),
          border: .fromBorderSide(
            BorderSide(
              color: enabled
                  ? colors.border
                  : colors.border.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: AppDimensions.readerSettingsStepperIconSize,
          color: enabled ? colors.textPrimary : colors.textTertiary,
        ),
      ),
    );
  }
}

// ──────────────────────────── Compact icon chip ───────────────────────────────

class _CompactIconChip extends StatelessWidget {
  const _CompactIconChip({
    required this.icon,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.readerSettingsControlHeight - 8,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: const .all(.circular(AppDimensions.readerSettingsPillRadius)),
          border: .fromBorderSide(
            BorderSide(
              color: isSelected ? colors.accent : colors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: AppDimensions.readerSettingsCompactIconSize,
          color: isSelected ? colors.accent : colors.textSecondary,
        ),
      ),
    );
  }
}
