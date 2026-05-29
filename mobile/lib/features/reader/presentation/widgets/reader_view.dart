import 'package:flutter/material.dart';

import 'package:bookish_corner/features/reader/presentation/widgets/fake_reader_view.dart';

/// Seam поверхности рендера ридера: рендер ≠ движок.
///
/// [ReaderEngine] (domain) — чистая логика без виджетов. Поверхность рендера —
/// отдельный presentation-виджет на формат. Это единственная точка выбора
/// поверхности под активный движок (по аналогии с `readerEngineProvider`):
/// позже здесь появится switch по формату → `Fb2ReaderView` / `EpubReaderView`.
///
/// Chrome оборачивает слот с [ReaderView] и НЕ знает, что внутри. Анимация
/// перелистывания страниц принадлежит реальной поверхности, не chrome.
class ReaderView extends StatelessWidget {
  const ReaderView({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    // B2: единственная реализация — плейсхолдер-поверхность на фейк-движке.
    return FakeReaderView(bookId: bookId);
  }
}
