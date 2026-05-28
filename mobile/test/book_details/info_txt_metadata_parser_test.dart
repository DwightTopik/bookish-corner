import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:bookish_corner/features/book_details/data/info_txt_metadata_parser.dart';
import 'package:bookish_corner/features/book_details/data/info_txt_metadata_source.dart';
import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';
import 'package:bookish_corner/features/library/domain/book.dart';
import 'package:bookish_corner/features/library/domain/book_format.dart';

void main() {
  group('InfoTxtMetadataParser', () {
    test('parses common audiobook fields defensively', () {
      const parser = InfoTxtMetadataParser();

      final metadata = parser.parse('''
Title: Dune
Author: Frank Herbert
Series: Dune #1
Duration: 21 ч 02 мин
Genre: Sci-Fi, Adventure
Description: First line.
Second line.
Age restriction: 16+
Release date: 1965
Written date: 1963
ISBN: 9780441172719
Translator: Translator Name
Reader: Narrator Name
Right holder: Rights Company
Table of contents:
1. Chapter One
2. Chapter Two
''');
      final BookDetailsMetadata(
        :title,
        :author,
        :series,
        :duration,
        :categories,
        :description,
        :ageRestriction,
        :publishedDate,
        :writtenDate,
        :isbn,
        :translator,
        :narrator,
        :rightHolder,
        :tableOfContents,
      ) = metadata;

      expect(title, equals('Dune'));
      expect(author, equals('Frank Herbert'));
      expect(series, equals('Dune #1'));
      expect(duration, equals('21 ч 02 мин'));
      expect(categories, equals(['Sci-Fi', 'Adventure']));
      expect(description, equals('First line.\nSecond line.'));
      expect(ageRestriction, equals('16+'));
      expect(publishedDate, equals('1965'));
      expect(writtenDate, equals('1963'));
      expect(isbn, equals('9780441172719'));
      expect(translator, equals('Translator Name'));
      expect(narrator, equals('Narrator Name'));
      expect(rightHolder, equals('Rights Company'));
      expect(tableOfContents, equals(['Chapter One', 'Chapter Two']));
    });

    test('ignores unknown keys and malformed lines', () {
      const parser = InfoTxtMetadataParser();

      final metadata = parser.parse('''
Something random
Unknown key: value
Жанр - Фэнтези / Приключения
Оглавление
- Вступление
''');
      final BookDetailsMetadata(:title, :categories, :tableOfContents) =
          metadata;

      expect(title, isNull);
      expect(categories, equals(['Фэнтези', 'Приключения']));
      expect(tableOfContents, equals(['Вступление']));
    });

    test('parses multiline Russian sections with blank lines', () {
      const parser = InfoTxtMetadataParser();

      final metadata = parser.parse('''
Автор: Робин Хобб
Из серии: Сага о Видящих

Описание:

Очень длинное описание
в несколько строк.

Сохраняет абзацы до следующей секции.

Подробная информация:

ISBN: 978-5-17-123456-7
Чтец: Александр Городиский
Жанр: Фэнтези, Зарубежная фантастика
Возрастное ограничение: 16+
Дата выхода: 2020
Дата написания: 1995
Переводчик: Мария Семенова
Правообладатель: Издательство АСТ
Издательство: АСТ
Оглавление:
- Пролог
- Глава первая
''');

      final BookDetailsMetadata(
        :author,
        :series,
        :description,
        :isbn,
        :narrator,
        :categories,
        :ageRestriction,
        :publishedDate,
        :writtenDate,
        :translator,
        :rightHolder,
        :publisher,
        :tableOfContents,
      ) = metadata;

      expect(author, equals('Робин Хобб'));
      expect(series, equals('Сага о Видящих'));
      expect(
        description,
        equals(
          'Очень длинное описание\nв несколько строк.\n\n'
          'Сохраняет абзацы до следующей секции.',
        ),
      );
      expect(isbn, equals('9785171234567'));
      expect(narrator, equals('Александр Городиский'));
      expect(categories, equals(['Фэнтези', 'Зарубежная фантастика']));
      expect(ageRestriction, equals('16+'));
      expect(publishedDate, equals('2020'));
      expect(writtenDate, equals('1995'));
      expect(translator, equals('Мария Семенова'));
      expect(rightHolder, equals('Издательство АСТ'));
      expect(publisher, equals('АСТ'));
      expect(tableOfContents, equals(['Пролог', 'Глава первая']));
    });

    test('does not leak adjacent labels into single-value fields', () {
      const parser = InfoTxtMetadataParser();

      final metadata = parser.parse('''
Возрастное ограничение: 16+ Дата выхода на ЛитРес: 2021
Длительность: 18 ч. 32 мин. 12 сек.
18 ч. 32 мин. 12 сек.
ISBN: 978-5-389-20464-5 Правообладатель: Азбука-Аттикус
''');
      final BookDetailsMetadata(:ageRestriction, :duration, :isbn) = metadata;

      expect(ageRestriction, equals('16+'));
      expect(duration, equals('18 ч. 32 мин. 12 сек.'));
      expect(isbn, equals('9785389204645'));
    });
  });

  group('BookDetailsMetadata', () {
    test('keeps primary metadata and fills only missing fields', () {
      final local = BookDetailsMetadata.fromBook(
        Book(
          id: 'id',
          title: 'Local title',
          author: 'Local author',
          narrator: 'Local narrator',
          filePath: 'book.mp3',
          format: BookFormat.mp3,
          addedAt: DateTime(2026),
          description: 'Local description',
        ),
      );
      const remote = BookDetailsMetadata(
        title: 'Remote title',
        author: 'Remote author',
        description: 'Remote description',
        categories: ['Drama'],
        isbn: '123',
      );

      final merged = local.mergeMissing(remote);
      final BookDetailsMetadata(
        :title,
        :author,
        :description,
        :narrator,
        :categories,
        :isbn,
      ) = merged;

      expect(title, equals('Local title'));
      expect(author, equals('Local author'));
      expect(description, equals('Local description'));
      expect(narrator, equals('Local narrator'));
      expect(categories, equals(['Drama']));
      expect(isbn, equals('123'));
    });

    test('does not keep placeholder empty values', () {
      const local = BookDetailsMetadata(
        title: 'unknown',
        author: 'Author',
        categories: ['null', 'Mystery'],
      );

      final merged = local.mergeMissing(
        const BookDetailsMetadata(title: 'Real title'),
      );

      expect(merged.title, equals('Real title'));
      expect(merged.categories, equals(['Mystery']));
    });

    test('keeps info metadata when Google data is missing', () {
      const info = BookDetailsMetadata(
        description: 'Info description',
        categories: ['Фэнтези'],
        narrator: 'Reader',
      );

      final merged = info.mergeMissing(null);
      final BookDetailsMetadata(:description, :categories, :narrator) = merged;

      expect(description, equals('Info description'));
      expect(categories, equals(['Фэнтези']));
      expect(narrator, equals('Reader'));
    });
  });

  group('InfoTxtMetadataSource', () {
    test('discovers sibling text file named like audiobook folder', () async {
      final temp = await Directory.systemTemp.createTemp('book_details_test');
      addTearDown(() => temp.delete(recursive: true));
      final bookDir = Directory(p.join(temp.path, '1. Ученик убийцы'));
      await bookDir.create();
      final info = File(p.join(temp.path, '1. Ученик убийцы.txt'));
      await info.writeAsString('''
Описание:

Описание из соседнего файла.
Чтец: Александр Городиский
''');

      const source = InfoTxtMetadataSource(InfoTxtMetadataParser());
      final diagnostics = await source.inspect(
        Book(
          id: 'id',
          title: 'Ученик убийцы',
          author: 'Робин Хобб',
          filePath: bookDir.path,
          format: BookFormat.audioFolder,
          addedAt: DateTime(2026),
        ),
      );

      expect(diagnostics.found, isTrue);
      expect(diagnostics.foundPath, equals(info.path));
      expect(diagnostics.parsedSummary.hasDescription, isTrue);
      expect(
        diagnostics.parsedSummary.narrator,
        equals('Александр Городиский'),
      );
    });
  });
}
