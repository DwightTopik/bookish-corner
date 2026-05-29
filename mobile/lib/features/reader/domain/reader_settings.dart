/// Фон страницы ридера.
enum ReaderBackground { white, sepia, gray, black, system }

/// Выравнивание текста.
enum ReaderTextAlign { left, justify }

/// Режим листания.
enum ReaderScrollMode { paginated, scroll }

/// Настройки ридера — общая модель, применяется к активному движку через
/// [ReaderEngine.applySettings]. Движки, не поддерживающие ту или иную опцию
/// (см. [ReaderCapabilities]), игнорируют соответствующие поля.
///
/// Sheet настроек (задача B3) может расширить модель — поля держим плоскими и
/// расширяемыми, но сейчас не усложняем.
class ReaderSettings {
  const ReaderSettings({
    this.background = ReaderBackground.system,
    this.useSystemBrightness = true,
    this.brightness,
    this.fontFamily = 'Default',
    this.fontSizeStep = 0,
    this.textAlign = ReaderTextAlign.left,
    this.marginStep = 1,
    this.lineHeight = 1.5,
    this.scrollMode = ReaderScrollMode.paginated,
  });

  final ReaderBackground background;
  final bool useSystemBrightness;

  /// `null` = использовать системную яркость.
  final double? brightness;

  /// Имя шрифта; `'Default'` = резолвится движком/CSS.
  final String fontFamily;

  /// Шаг размера шрифта относительно базового (0 = базовый).
  final int fontSizeStep;
  final ReaderTextAlign textAlign;

  /// Шаг величины полей относительно базового.
  final int marginStep;
  final double lineHeight;
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
    double? lineHeight,
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
      lineHeight: lineHeight ?? this.lineHeight,
      scrollMode: scrollMode ?? this.scrollMode,
    );
  }
}
