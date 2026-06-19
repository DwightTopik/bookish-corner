/// Чем умеет конкретный движок — для адаптивного UI: chrome по этим флагам
/// скрывает недоступные контролы. pdf вернёт большинство `false`.
class ReaderCapabilities {
  const ReaderCapabilities({
    required this.supportsFontResize,
    required this.supportsThemeColors,
    required this.supportsScrollMode,
    required this.supportsTextSelection,
    required this.supportsHighlights,
    required this.supportsSearch,
  });

  final bool supportsFontResize;
  final bool supportsThemeColors;
  final bool supportsScrollMode;
  final bool supportsTextSelection;
  final bool supportsHighlights;
  final bool supportsSearch;
}
