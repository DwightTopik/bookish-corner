import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bookish_corner/features/reader/presentation/providers/reader_book_provider.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/fake_reader_view.dart';
import 'package:bookish_corner/features/reader/presentation/widgets/fb2_reader_view.dart';

/// Seam поверхности рендера ридера: рендер ≠ движок.
///
/// [ReaderEngine] (domain) — чистая логика без виджетов. Поверхность рендера —
/// отдельный presentation-виджет на формат. Это единственная точка выбора
/// поверхности под активный движок (по аналогии с `readerEngineProvider`):
/// fb2/txt → [Fb2ReaderView], epub/pdf пока → [FakeReaderView].
///
/// Chrome оборачивает слот с [ReaderView] и НЕ знает, что внутри. Анимация
/// перелистывания страниц принадлежит реальной поверхности, не chrome.
class ReaderView extends ConsumerWidget {
  const ReaderView({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Поверхность монтируется только в ready-стейте, т.е. книга уже загружена.
    final format = ref.watch(readerBookProvider(bookId)).asData?.value?.format;
    return switch (format) {
      .fb2 || .txt => Fb2ReaderView(bookId: bookId),
      _ => FakeReaderView(bookId: bookId),
    };
  }
}
