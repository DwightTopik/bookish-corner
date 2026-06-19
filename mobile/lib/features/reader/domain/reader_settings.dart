/// Фон страницы ридера.
enum ReaderBackground { white, sepia, gray, black, system }

/// Выравнивание текста.
enum ReaderTextAlign { left, justify }

/// Режим листания.
enum ReaderScrollMode { paginated, scroll }

/// Настройки ридера — общая модель, применяется к активному движку через
/// [ReaderEngine.applySettings]. Движки, не поддерживающие ту или иную опцию
/// (см. [ReaderCapabilities]), игнорируют соответствующие поля.
class ReaderSettings {
  const ReaderSettings({
    this.background = ReaderBackground.system,
    this.useSystemBrightness = true,
    this.brightness,
    this.fontFamily = 'Default',
    this.fontSizeStep = 0,
    this.textAlign = ReaderTextAlign.left,
    this.marginStep = 1,
    this.lineSpacingStep = 1,
    this.scrollMode = ReaderScrollMode.paginated,
  });

  final ReaderBackground background;
  final bool useSystemBrightness;

  /// `null` = использовать системную яркость.
  final double? brightness;

  /// Имя шрифта: 'Default' / 'Roboto' / 'PTSerif' / 'PTSans' / 'Playfair'.
  final String fontFamily;

  /// Шаг размера шрифта относительно базового (0 = базовый).
  final int fontSizeStep;
  final ReaderTextAlign textAlign;

  /// Шаг величины полей относительно базового (0..2).
  final int marginStep;

  /// Межстрочный интервал: 0=компактный, 1=обычный, 2=широкий.
  final int lineSpacingStep;

  final ReaderScrollMode scrollMode;

  ReaderSettings copyWith({
    ReaderBackground? background,
    bool? useSystemBrightness,
    double? brightness,
    bool clearBrightness = false,
    String? fontFamily,
    int? fontSizeStep,
    ReaderTextAlign? textAlign,
    int? marginStep,
    int? lineSpacingStep,
    ReaderScrollMode? scrollMode,
  }) {
    return ReaderSettings(
      background: background ?? this.background,
      useSystemBrightness: useSystemBrightness ?? this.useSystemBrightness,
      brightness: clearBrightness ? null : (brightness ?? this.brightness),
      fontFamily: fontFamily ?? this.fontFamily,
      fontSizeStep: fontSizeStep ?? this.fontSizeStep,
      textAlign: textAlign ?? this.textAlign,
      marginStep: marginStep ?? this.marginStep,
      lineSpacingStep: lineSpacingStep ?? this.lineSpacingStep,
      scrollMode: scrollMode ?? this.scrollMode,
    );
  }
}
