class AppDimensions {
  const AppDimensions._();

  static const double playerCoverRadius = 16;
  static const double playerCoverRatio = 0.78;
  static const double playerCoverMinSize = 280;
  static const double playerCoverMaxSize = 340;
  static const double playerGlowBlurSigma = 70;
  static const double playerGlowScale = 1.4;
  static const double playerBookProgressTopGap = 12;
  static const double playerBookProgressBottomGap = 20;
  static const double playerChapterTitleTopGap = 10;
  static const double playerBookProgressHPadding = 18;
  static const double playerBookProgressVPadding = 8;
  static const double playerPlayButtonSize = 64;
  static const double playerSeekButtonSize = 36;
  static const double playerSkipButtonSize = 28;
  static const double playerControlsHGap = 24;
  static const double playerBottomBarHeight = 64;

  static const double miniPlayerHeight = 64;
  static const double miniPlayerCoverSize = 48;
  static const double miniPlayerCoverRadius = 8;

  static const double sheetPickerHeight = 140;
  static const double sheetPickerSelectedFont = 24;
  static const double sheetPickerNeighborFont = 16;
  static const double sheetPickerViewportFraction = 0.28;

  static const double readerZoneLeftFraction = 0.30;
  static const double readerZoneCenterFraction = 0.40;
  static const double readerZoneRightFraction = 0.30;
  static const double readerSwipeVelocityThreshold = 200;
  static const int readerChromeAnimMs = 220;
  static const int readerPageTurnAnimMs = 280;
  static const double readerToolbarHeight = 64;
  static const double readerToolbarIconSize = 22;
  static const double readerPanelHPadding = 20;
  static const double readerPanelVPadding = 14;
  static const double readerPanelRowGap = 14;
  static const double readerContentHPadding = 24;
  static const double readerContentVPadding = 16;
  static const double readerImmersiveFooterBottomGap = 12;

  /// Зарезервированная высота иммерсивного футера (bottomGap + строка текста).
  /// Всегда вычитается из pageHeight, чтобы текст не заходил под «N из M»
  /// даже когда футер прозрачен.
  static const double readerImmersiveFooterReservedHeight = 36;

  static const double screenHPadding = 20;
  static const double screenVPadding = 16;
  static const double sectionGap = 16;
  static const double smallGap = 8;

  static const double bookDetailsCoverRatio = 0.64;
  static const double bookDetailsCoverMinSize = 210;
  static const double bookDetailsCoverMaxSize = 300;
  static const double bookDetailsGlowScale = 1.55;
  static const double bookDetailsGlowBlurSigma = 80;
  static const double bookDetailsCoverRadius = 18;
  static const double bookDetailsInfoButtonSize = 38;
  static const double bookDetailsSectionGap = 26;
  static const double bookDetailsChipRadius = 999;
  static const double bookDetailsRecommendationCoverWidth = 78;
  static const double bookDetailsRecommendationCoverHeight = 112;
  static const double bookDetailsRecommendationWidth = 118;

  // --- Fb2ReaderView: типографика и геометрия ---

  /// Базовый размер шрифта тела (fontSizeStep == 0).
  static const double readerFontSizeBase = 18;

  /// Шаг изменения шрифта на единицу [ReaderSettings.fontSizeStep].
  static const double readerFontSizeStep = 2;

  /// Масштаб заголовка главы (HeadingBlock) относительно тела.
  static const double readerHeadingScale = 1.25;

  /// Отступ первой строки абзаца (красная строка), pt.
  static const double readerParagraphIndent = 20;

  /// Вертикальный отступ между абзацами (сверху каждого, кроме первого), pt.
  static const double readerParagraphSpacing = 6;

  /// Дополнительный вертикальный зазор перед заголовком главы, pt.
  static const double readerHeadingTopSpacing = 16;

  /// Дополнительный вертикальный зазор после заголовка главы, pt.
  static const double readerHeadingBottomSpacing = 12;

  /// Горизонтальные поля контента при marginStep == 0 (минимум).
  static const double readerHMarginMin = 16;

  /// Горизонтальные поля контента при marginStep == 1 (базовый).
  static const double readerHMarginBase = 24;

  /// Горизонтальные поля контента при marginStep == 2 (широкий).
  static const double readerHMarginWide = 40;

  /// Вертикальные поля контента при marginStep == 0.
  static const double readerVMarginMin = 12;

  /// Вертикальные поля контента при marginStep == 1.
  static const double readerVMarginBase = 20;

  /// Вертикальные поля контента при marginStep == 2.
  static const double readerVMarginWide = 32;

  /// Горизонтальное смещение для красной строки вычисляется из
  /// [readerParagraphIndent]; хранится отдельно, чтобы линт не жаловался на
  /// дублирование цифр в TextPainter.
  static double readerFontSize(int step) =>
      readerFontSizeBase + step * readerFontSizeStep;

  static double readerHMargin(int step) => switch (step) {
    0 => readerHMarginMin,
    1 => readerHMarginBase,
    _ => readerHMarginWide,
  };

  static double readerVMargin(int step) => switch (step) {
    0 => readerVMarginMin,
    1 => readerVMarginBase,
    _ => readerVMarginWide,
  };
}
