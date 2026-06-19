import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bookish_corner/core/di/app_preferences_provider.dart';
import 'package:bookish_corner/features/reader/domain/reader_settings.dart';

/// Глобальные настройки ридера (не per-book). Персистируются через
/// [sharedPreferencesProvider]. Инициализируется из сохранённых значений при
/// первом чтении; мутируется через [ReaderSettingsNotifier.save].
final readerSettingsProvider =
    NotifierProvider<ReaderSettingsNotifier, ReaderSettings>(
      ReaderSettingsNotifier.new,
    );

class ReaderSettingsNotifier extends Notifier<ReaderSettings> {
  static const String _prefix = 'reader_settings_';

  @override
  ReaderSettings build() => _load(ref.read(sharedPreferencesProvider));

  Future<void> save(ReaderSettings s) async {
    state = s;
    final SharedPreferences p = ref.read(sharedPreferencesProvider);
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
    await p.setString('${_prefix}background', background.name);
    await p.setBool('${_prefix}useSystemBrightness', useSystemBrightness);
    if (brightness != null) {
      await p.setDouble('${_prefix}brightness', brightness);
    } else {
      await p.remove('${_prefix}brightness');
    }
    await p.setString('${_prefix}fontFamily', fontFamily);
    await p.setInt('${_prefix}fontSizeStep', fontSizeStep);
    await p.setString('${_prefix}textAlign', textAlign.name);
    await p.setInt('${_prefix}marginStep', marginStep);
    await p.setInt('${_prefix}lineSpacingStep', lineSpacingStep);
  }

  static ReaderSettings _load(SharedPreferences p) {
    return ReaderSettings(
      background: ReaderBackground.values.asNameMap()[
            p.getString('${_prefix}background')
          ] ??
          .system,
      useSystemBrightness: p.getBool('${_prefix}useSystemBrightness') ?? true,
      brightness: p.getDouble('${_prefix}brightness'),
      fontFamily: p.getString('${_prefix}fontFamily') ?? 'Default',
      fontSizeStep: p.getInt('${_prefix}fontSizeStep') ?? 0,
      textAlign: ReaderTextAlign.values.asNameMap()[
            p.getString('${_prefix}textAlign')
          ] ??
          .left,
      marginStep: p.getInt('${_prefix}marginStep') ?? 1,
      lineSpacingStep: p.getInt('${_prefix}lineSpacingStep') ?? 1,
    );
  }
}
