import 'package:flutter_test/flutter_test.dart';

import 'package:bookish_corner/features/reader/data/document/reader_document.dart';
import 'package:bookish_corner/features/reader/data/document/txt_parser.dart';

void main() {
  group('TxtParser', () {
    test('одна глава с заголовком книги, абзацы по пустым строкам', () {
      const text = 'Первый абзац.\n\nВторой абзац.\n\nТретий абзац.';
      final doc = TxtParser.parse(text, title: 'Мой текст');

      expect(doc.chapters, hasLength(1));
      expect(doc.chapters.first.title, equals('Мой текст'));
      expect(doc.chapters.first.depth, equals(0));
      expect(doc.chapters.first.blocks, hasLength(3));
      expect(doc.chapters.first.blocks.first, isA<ParagraphBlock>());
    });

    test('CRLF нормализуется, переносы внутри абзаца схлопываются', () {
      const text = 'Строка один\r\nстрока два\r\n\r\nНовый абзац.';
      final doc = TxtParser.parse(text, title: 'T');
      final blocks = doc.chapters.first.blocks;

      expect(blocks, hasLength(2));
      expect((blocks.first as ParagraphBlock).text, equals('Строка один строка два'));
    });

    test('пустой текст даёт главу без блоков, не кидает', () {
      final doc = TxtParser.parse('   \n\n  ', title: 'Пусто');

      expect(doc.chapters, hasLength(1));
      expect(doc.chapters.first.blocks, isEmpty);
      expect(doc.totalChars, equals(0));
    });
  });
}
