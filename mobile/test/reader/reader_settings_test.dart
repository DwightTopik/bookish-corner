import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bookish_corner/core/constants/app_dimensions.dart';
import 'package:bookish_corner/core/di/app_preferences_provider.dart';
import 'package:bookish_corner/core/theme/app_colors.dart';
import 'package:bookish_corner/features/reader/domain/reader_palette.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';
import 'package:bookish_corner/features/reader/presentation/providers/reader_settings_provider.dart';

/// Creates a new ProviderContainer wired to [prefs]. Used in persist tests
/// to simulate separate app launches sharing the same on-disk store.
ProviderContainer _makeContainer(SharedPreferences prefs) => .new(
  overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
);

/// Replicates the dim-overlay formula from reader_screen.dart so tests stay
/// in sync with the production formula without importing the widget layer.
double _dimOpacity(ReaderSettings s) {
  if (s.useSystemBrightness) return 0.0;
  return (1.0 - (s.brightness ?? 1.0)).clamp(0.0, 0.8);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── 1. Defaults ─────────────────────────────────────────────────────────────

  group('defaults', () {
    test('ReaderSettings() has expected field defaults', () {
      const s = ReaderSettings();
      final ReaderSettings(
        :background,
        :useSystemBrightness,
        :brightness,
        :fontFamily,
        :fontSizeStep,
        :textAlign,
        :marginStep,
        :lineSpacingStep,
      ) = s;
      expect(background, equals(ReaderBackground.system));
      expect(useSystemBrightness, isTrue);
      expect(brightness, isNull);
      expect(fontFamily, equals('Default'));
      expect(fontSizeStep, equals(0));
      expect(textAlign, equals(ReaderTextAlign.left));
      expect(marginStep, equals(1));
      expect(lineSpacingStep, equals(1));
    });
  });

  // ── 2. copyWith / clearBrightness ───────────────────────────────────────────

  group('copyWith', () {
    test('preserves unchanged fields', () {
      const s = ReaderSettings(fontFamily: 'PTSerif', fontSizeStep: 2);
      final s2 = s.copyWith(fontSizeStep: 3);
      final ReaderSettings(:fontFamily, :fontSizeStep, :lineSpacingStep) = s2;
      expect(fontFamily, equals('PTSerif'));
      expect(fontSizeStep, equals(3));
      expect(lineSpacingStep, equals(s.lineSpacingStep));
    });

    test('clearBrightness removes the brightness value', () {
      const s = ReaderSettings(
        useSystemBrightness: false,
        brightness: 0.7,
      );
      final s2 = s.copyWith(useSystemBrightness: true, clearBrightness: true);
      expect(s2.useSystemBrightness, isTrue);
      expect(s2.brightness, isNull);
    });

    test('clearBrightness: false leaves brightness intact', () {
      const s = ReaderSettings(useSystemBrightness: false, brightness: 0.5);
      expect(s.copyWith(fontSizeStep: 1).brightness, equals(0.5));
    });
  });

  // ── 3. Persist — full save/restore round-trip ───────────────────────────────

  group('persist', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves and restores all fields', () async {
      final prefs = await SharedPreferences.getInstance();
      const settings = ReaderSettings(
        background: .sepia,
        useSystemBrightness: false,
        brightness: 0.6,
        fontFamily: 'PTSerif',
        fontSizeStep: 2,
        textAlign: .justify,
        marginStep: 2,
        lineSpacingStep: 0,
      );
      final c1 = _makeContainer(prefs);
      addTearDown(c1.dispose);
      await c1.read(readerSettingsProvider.notifier).save(settings);

      // Отдельный контейнер симулирует рестарт приложения с теми же prefs.
      final c2 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c2.dispose);
      final ReaderSettings(
        :background,
        :useSystemBrightness,
        :brightness,
        :fontFamily,
        :fontSizeStep,
        :textAlign,
        :marginStep,
        :lineSpacingStep,
      ) = c2.read(readerSettingsProvider);
      expect(background, equals(ReaderBackground.sepia));
      expect(useSystemBrightness, isFalse);
      expect(brightness, closeTo(0.6, 0.001));
      expect(fontFamily, equals('PTSerif'));
      expect(fontSizeStep, equals(2));
      expect(textAlign, equals(ReaderTextAlign.justify));
      expect(marginStep, equals(2));
      expect(lineSpacingStep, equals(0));
    });

    test('unknown background key falls back to system', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reader_settings_background', 'unknown_value');
      final c = _makeContainer(prefs);
      addTearDown(c.dispose);
      expect(
        c.read(readerSettingsProvider).background,
        equals(ReaderBackground.system),
      );
    });

    test('missing keys return defaults', () async {
      final prefs = await SharedPreferences.getInstance();
      final c = _makeContainer(prefs);
      addTearDown(c.dispose);
      final s = c.read(readerSettingsProvider);
      final ReaderSettings(
        :background,
        :useSystemBrightness,
        :brightness,
        :fontFamily,
        :fontSizeStep,
        :textAlign,
        :marginStep,
        :lineSpacingStep,
      ) = s;
      expect(background, equals(ReaderBackground.system));
      expect(useSystemBrightness, isTrue);
      expect(brightness, isNull);
      expect(fontFamily, equals('Default'));
      expect(fontSizeStep, equals(0));
      expect(textAlign, equals(ReaderTextAlign.left));
      expect(marginStep, equals(1));
      expect(lineSpacingStep, equals(1));
    });
  });

  // ── 4. lineSpacingStep persist/restore ──────────────────────────────────────

  group('lineSpacingStep persist', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    for (final step in [0, 1, 2]) {
      test('step $step survives save/restore', () async {
        final prefs = await SharedPreferences.getInstance();
        final c1 = _makeContainer(prefs);
        addTearDown(c1.dispose);
        await c1.read(readerSettingsProvider.notifier).save(
          ReaderSettings(lineSpacingStep: step),
        );
        final c2 = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(c2.dispose);
        expect(c2.read(readerSettingsProvider).lineSpacingStep, equals(step));
      });
    }

    test('update triggers state change within same container', () async {
      final prefs = await SharedPreferences.getInstance();
      final c = _makeContainer(prefs);
      addTearDown(c.dispose);

      await c.read(readerSettingsProvider.notifier).save(
        const ReaderSettings(lineSpacingStep: 0),
      );
      expect(c.read(readerSettingsProvider).lineSpacingStep, equals(0));

      await c.read(readerSettingsProvider.notifier).save(
        const ReaderSettings(lineSpacingStep: 2),
      );
      expect(c.read(readerSettingsProvider).lineSpacingStep, equals(2));
    });
  });

  // ── 5. Dim opacity formula ──────────────────────────────────────────────────

  group('dim opacity', () {
    test('system brightness → 0.0', () {
      expect(
        _dimOpacity(const ReaderSettings(useSystemBrightness: true)),
        equals(0.0),
      );
    });

    test('manual brightness 1.0 → 0.0 (no dimming)', () {
      expect(
        _dimOpacity(const ReaderSettings(
          useSystemBrightness: false,
          brightness: 1.0,
        )),
        equals(0.0),
      );
    });

    test('manual brightness 0.5 → 0.5', () {
      expect(
        _dimOpacity(const ReaderSettings(
          useSystemBrightness: false,
          brightness: 0.5,
        )),
        closeTo(0.5, 0.001),
      );
    });

    test('manual brightness 0.0 → clamped to 0.8', () {
      expect(
        _dimOpacity(const ReaderSettings(
          useSystemBrightness: false,
          brightness: 0.0,
        )),
        closeTo(0.8, 0.001),
      );
    });

    test('brightness null with useSystemBrightness false → 0.0', () {
      expect(
        _dimOpacity(const ReaderSettings(useSystemBrightness: false)),
        equals(0.0),
      );
    });
  });

  // ── 6. readerLineHeight (font/spacing resolve) ───────────────────────────────

  group('readerLineHeight', () {
    test('step 0 → 1.3 (compact)', () {
      expect(AppDimensions.readerLineHeight(0), equals(1.3));
    });

    test('step 1 → 1.5 (normal)', () {
      expect(AppDimensions.readerLineHeight(1), equals(1.5));
    });

    test('step 2 → 1.8 (wide)', () {
      expect(AppDimensions.readerLineHeight(2), equals(1.8));
    });

    test('out-of-range values are clamped', () {
      expect(AppDimensions.readerLineHeight(-1), equals(1.3));
      expect(AppDimensions.readerLineHeight(5), equals(1.8));
    });
  });

  // ── 7. readerFontSize (layout step mapping) ──────────────────────────────────

  group('readerFontSize', () {
    test('step 0 → base 18pt', () {
      expect(AppDimensions.readerFontSize(0), equals(18.0));
    });

    test('step +1 → 20pt', () {
      expect(AppDimensions.readerFontSize(1), equals(20.0));
    });

    test('step -1 → 16pt', () {
      expect(AppDimensions.readerFontSize(-1), equals(16.0));
    });

    test('step +3 → 24pt', () {
      expect(AppDimensions.readerFontSize(3), equals(24.0));
    });

    test('step -3 → 12pt', () {
      expect(AppDimensions.readerFontSize(-3), equals(12.0));
    });
  });

  // ── 8. ReaderPalette.resolve ─────────────────────────────────────────────────

  group('ReaderPalette.resolve', () {
    test('white → fixed bg #FFFFFF / text #2D2D2D / muted #969696', () {
      final ReaderPalette(:bg, :text, :muted) =
          ReaderPalette.resolve(ReaderBackground.white, AppColors.dark);
      expect(bg,    equals(const Color(0xFFFFFFFF)));
      expect(text,  equals(const Color(0xFF2D2D2D)));
      expect(muted, equals(const Color(0xFF969696)));
    });

    test('sepia → fixed bg #FBF4E2 / text #59391F / muted #A89785', () {
      final ReaderPalette(:bg, :text, :muted) =
          ReaderPalette.resolve(ReaderBackground.sepia, AppColors.dark);
      expect(bg,    equals(const Color(0xFFFBF4E2)));
      expect(text,  equals(const Color(0xFF59391F)));
      expect(muted, equals(const Color(0xFFA89785)));
    });

    test('gray → fixed bg #4B4B4B / text #E3E3E3 / muted #969696', () {
      final ReaderPalette(:bg, :text, :muted) =
          ReaderPalette.resolve(ReaderBackground.gray, AppColors.dark);
      expect(bg,    equals(const Color(0xFF4B4B4B)));
      expect(text,  equals(const Color(0xFFE3E3E3)));
      expect(muted, equals(const Color(0xFF969696)));
    });

    test('black → fixed bg #010101 / text #C2C2C2 / muted #616161', () {
      final ReaderPalette(:bg, :text, :muted) =
          ReaderPalette.resolve(ReaderBackground.black, AppColors.dark);
      expect(bg,    equals(const Color(0xFF010101)));
      expect(text,  equals(const Color(0xFFC2C2C2)));
      expect(muted, equals(const Color(0xFF616161)));
    });

    test('gray tokens are identical in dark and light AppColors', () {
      final ReaderPalette(bg: bgD, text: textD, muted: mutedD) =
          ReaderPalette.resolve(ReaderBackground.gray, AppColors.dark);
      final ReaderPalette(bg: bgL, text: textL, muted: mutedL) =
          ReaderPalette.resolve(ReaderBackground.gray, AppColors.light);
      expect(bgD,    equals(bgL));
      expect(textD,  equals(textL));
      expect(mutedD, equals(mutedL));
    });

    test('system (dark) → app bg / textPrimary / textTertiary', () {
      final ReaderPalette(:bg, :text, :muted) =
          ReaderPalette.resolve(ReaderBackground.system, AppColors.dark);
      expect(bg,    equals(AppColors.dark.bg));
      expect(text,  equals(AppColors.dark.textPrimary));
      expect(muted, equals(AppColors.dark.textTertiary));
    });

    test('system (light) → app bg / textPrimary / textTertiary', () {
      final ReaderPalette(:bg, :text, :muted) =
          ReaderPalette.resolve(ReaderBackground.system, AppColors.light);
      expect(bg,    equals(AppColors.light.bg));
      expect(text,  equals(AppColors.light.textPrimary));
      expect(muted, equals(AppColors.light.textTertiary));
    });
  });
}
