import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookish_corner/core/database/app_database.dart';
import 'package:bookish_corner/features/reader/data/drift_reader_annotation_repository.dart';
import 'package:bookish_corner/features/reader/data/drift_reader_bookmark_repository.dart';
import 'package:bookish_corner/features/reader/data/drift_reader_progress_repository.dart';
import 'package:bookish_corner/features/reader/domain/reader_annotation.dart';
import 'package:bookish_corner/features/reader/domain/reader_bookmark.dart';
import 'package:bookish_corner/features/reader/domain/reader_locator.dart';

// NativeDatabase.memory() doesn't inherit app-level PRAGMA from beforeOpen in
// the same connection lifecycle as production. Set FK enforcement at the sqlite3
// level via setup so ON DELETE CASCADE works in tests.
AppDatabase _openDb() => .new(
  NativeDatabase.memory(setup: (rawDb) => rawDb.execute('PRAGMA foreign_keys = ON')),
);

Future<void> _insertBook(AppDatabase db, String id) async {
  await db.into(db.books).insert(
    BooksCompanion.insert(
      id: id,
      title: 'Test Book',
      author: 'Author',
      filePath: '/tmp/test.fb2',
      format: 'fb2',
      addedAt: DateTime(2026),
    ),
  );
}

void main() {
  group('schema v7 — все таблицы доступны', () {
    late AppDatabase db;

    setUp(() => db = _openDb());
    tearDown(() => db.close());

    test('books + book_chapters + audio + reader таблицы создаются', () async {
      await _insertBook(db, 'b1');
      final rows = await db.select(db.books).get();
      expect(rows, hasLength(1));

      final AppDatabase(:readerProgress, :readerBookmarks, :readerAnnotations) = db;
      // Reader таблицы доступны — вставка без ошибки.
      await db.into(readerProgress).insert(
        ReaderProgressCompanion.insert(
          bookId: 'b1',
          charOffset: 0,
          percent: 0.0,
          updatedAt: DateTime(2026),
        ),
      );
      await db.into(readerBookmarks).insert(
        ReaderBookmarksCompanion.insert(
          id: 'bm1',
          bookId: 'b1',
          charOffset: 100,
          previewText: 'preview',
          createdAt: DateTime(2026),
        ),
      );
      await db.into(readerAnnotations).insert(
        ReaderAnnotationsCompanion.insert(
          id: 'an1',
          bookId: 'b1',
          type: 0,
          charStart: 10,
          charEnd: 20,
          body: 'quote text',
          createdAt: DateTime(2026),
        ),
      );
      expect(await db.select(readerProgress).get(), hasLength(1));
      expect(await db.select(readerBookmarks).get(), hasLength(1));
      expect(await db.select(readerAnnotations).get(), hasLength(1));
    });
  });

  group('ReaderProgress', () {
    late AppDatabase db;
    late DriftReaderProgressRepository repo;

    setUp(() async {
      db = _openDb();
      repo = DriftReaderProgressRepository(db);
      await _insertBook(db, 'book1');
    });
    tearDown(() => db.close());

    test('save → get возвращает эквивалентный ReaderLocator', () async {
      const loc = ReaderLocator(progress: 0.25, anchor: '2:1500', chapterIndex: 2);
      await repo.saveProgress('book1', loc);
      final result = await repo.getProgress('book1');
      expect(result, isNotNull);
      expect(result!.progress, closeTo(0.25, 0.0001));
      expect(result.chapterIndex, equals(2));
    });

    test('повторный save обновляет, count = 1', () async {
      const loc1 = ReaderLocator(progress: 0.1, anchor: '0:100');
      const loc2 = ReaderLocator(progress: 0.5, anchor: '3:2000', chapterIndex: 3);
      await repo.saveProgress('book1', loc1);
      await repo.saveProgress('book1', loc2);
      final rows = await db.select(db.readerProgress).get();
      expect(rows, hasLength(1));
      final result = await repo.getProgress('book1');
      expect(result!.progress, closeTo(0.5, 0.0001));
    });

    test('watchProgress эмитит изменения', () async {
      const loc = ReaderLocator(progress: 0.3, anchor: '1:300', chapterIndex: 1);
      final stream = repo.watchProgress('book1');
      expect(stream, emitsThrough(isNotNull));
      await repo.saveProgress('book1', loc);
    });

    test('getProgress возвращает null для неизвестной книги', () async {
      final result = await repo.getProgress('unknown');
      expect(result, isNull);
    });
  });

  group('ReaderBookmarks', () {
    late AppDatabase db;
    late DriftReaderBookmarkRepository repo;

    setUp(() async {
      db = _openDb();
      repo = DriftReaderBookmarkRepository(db);
      await _insertBook(db, 'book2');
    });
    tearDown(() => db.close());

    ReaderBookmark bm(String id, int offset) => .new(
      id: id,
      bookId: 'book2',
      charOffset: offset,
      previewText: 'preview $id',
      createdAt: .new(2026, 1, offset),
    );

    test('addBookmark → watchBookmarks эмитит список', () async {
      final b = bm('bm1', 100);
      final stream = repo.watchBookmarks('book2');
      await repo.addBookmark(b);
      await expectLater(
        stream,
        emitsThrough(predicate<List<ReaderBookmark>>((l) => l.any((x) => x.id == 'bm1'))),
      );
    });

    test('removeBookmark удаляет запись', () async {
      await repo.addBookmark(bm('bm2', 200));
      await repo.removeBookmark('bm2');
      final bms = await db.select(db.readerBookmarks).get();
      expect(bms.where((r) => r.id == 'bm2'), isEmpty);
    });

    test('isBookmarked корректен', () async {
      await repo.addBookmark(bm('bm3', 300));
      expect(await repo.isBookmarked('book2', 300), isTrue);
      expect(await repo.isBookmarked('book2', 999), isFalse);
    });

    test('watchBookmarks сортирует по createdAt DESC', () async {
      await repo.addBookmark(bm('bm-a', 1));
      await repo.addBookmark(bm('bm-b', 2));
      final bms = await repo.watchBookmarks('book2').first;
      expect(bms.first.id, equals('bm-b'));
    });
  });

  group('ReaderAnnotations', () {
    late AppDatabase db;
    late DriftReaderAnnotationRepository repo;

    setUp(() async {
      db = _openDb();
      repo = DriftReaderAnnotationRepository(db);
      await _insertBook(db, 'book3');
    });
    tearDown(() => db.close());

    ReaderAnnotation ann(String id, ReaderAnnotationType type) => .new(
      id: id,
      bookId: 'book3',
      type: type,
      charStart: 10,
      charEnd: 50,
      text: 'annotation text $id',
      color: HighlightColor.coral,
      createdAt: DateTime(2026),
    );

    test('addAnnotation → watchAnnotations без фильтра возвращает обе', () async {
      await repo.addAnnotation(ann('q1', ReaderAnnotationType.quote));
      await repo.addAnnotation(ann('n1', ReaderAnnotationType.note));
      final list = await repo.watchAnnotations('book3').first;
      expect(list, hasLength(2));
    });

    test('watchAnnotations с фильтром quote возвращает только цитаты', () async {
      await repo.addAnnotation(ann('q2', ReaderAnnotationType.quote));
      await repo.addAnnotation(ann('n2', ReaderAnnotationType.note));
      final quotes = await repo
          .watchAnnotations('book3', type: ReaderAnnotationType.quote)
          .first;
      expect(quotes, hasLength(1));
      expect(quotes.first.type, equals(ReaderAnnotationType.quote));
    });

    test('updateNote обновляет noteText', () async {
      await repo.addAnnotation(ann('n3', ReaderAnnotationType.note));
      await repo.updateNote('n3', 'my note content');
      final list = await repo.watchAnnotations('book3').first;
      final updated = list.firstWhere((a) => a.id == 'n3');
      expect(updated.noteText, equals('my note content'));
    });

    test('removeAnnotation удаляет запись', () async {
      await repo.addAnnotation(ann('q3', ReaderAnnotationType.quote));
      await repo.removeAnnotation('q3');
      final list = await repo.watchAnnotations('book3').first;
      expect(list.where((a) => a.id == 'q3'), isEmpty);
    });

    test('addAnnotation сохраняет color, _toDomain читает верно', () async {
      await repo.addAnnotation(
        ReaderAnnotation(
          id: 'col1',
          bookId: 'book3',
          type: ReaderAnnotationType.quote,
          charStart: 1,
          charEnd: 10,
          text: 'colored',
          color: HighlightColor.teal,
          createdAt: DateTime(2026),
        ),
      );
      final list = await repo.watchAnnotations('book3').first;
      expect(list.first.color, equals(HighlightColor.teal));
    });

    test('updateColor меняет цвет аннотации', () async {
      await repo.addAnnotation(ann('col2', ReaderAnnotationType.quote));
      await repo.updateColor('col2', HighlightColor.blue);
      final list = await repo.watchAnnotations('book3').first;
      final updated = list.firstWhere((a) => a.id == 'col2');
      expect(updated.color, equals(HighlightColor.blue));
    });

    test('null color в БД читается как coral', () async {
      // Прямая вставка без color (NULL) — имитирует строки v7-схемы.
      await db.into(db.readerAnnotations).insert(
        ReaderAnnotationsCompanion.insert(
          id: 'legacy',
          bookId: 'book3',
          type: ReaderAnnotationType.quote.index,
          charStart: 0,
          charEnd: 5,
          body: 'legacy text',
          createdAt: DateTime(2026),
        ),
      );
      final list = await repo.watchAnnotations('book3').first;
      final row = list.firstWhere((a) => a.id == 'legacy');
      expect(row.color, equals(HighlightColor.coral));
    });
  });

  group('cascade delete', () {
    late AppDatabase db;
    late DriftReaderProgressRepository progressRepo;
    late DriftReaderBookmarkRepository bookmarkRepo;
    late DriftReaderAnnotationRepository annotationRepo;

    setUp(() async {
      db = _openDb();
      progressRepo = DriftReaderProgressRepository(db);
      bookmarkRepo = DriftReaderBookmarkRepository(db);
      annotationRepo = DriftReaderAnnotationRepository(db);
      await _insertBook(db, 'cascade-book');

      await progressRepo.saveProgress(
        'cascade-book',
        const ReaderLocator(progress: 0.5, anchor: '1:500', chapterIndex: 1),
      );
      await bookmarkRepo.addBookmark(
        ReaderBookmark(
          id: 'bmc1',
          bookId: 'cascade-book',
          charOffset: 100,
          previewText: 'preview',
          createdAt: DateTime(2026),
        ),
      );
      await annotationRepo.addAnnotation(
        ReaderAnnotation(
          id: 'anc1',
          bookId: 'cascade-book',
          type: ReaderAnnotationType.quote,
          charStart: 10,
          charEnd: 30,
          text: 'quoted',
          color: HighlightColor.coral,
          createdAt: DateTime(2026),
        ),
      );
    });
    tearDown(() => db.close());

    test('удаление книги удаляет progress + bookmarks + annotations', () async {
      final AppDatabase(:books, :readerProgress, :readerBookmarks, :readerAnnotations) = db;
      await (db.delete(books)..where((t) => t.id.equals('cascade-book'))).go();

      expect(await db.select(readerProgress).get(), isEmpty);
      expect(await db.select(readerBookmarks).get(), isEmpty);
      expect(await db.select(readerAnnotations).get(), isEmpty);
    });
  });

  group('migration v7 → v8', () {
    test('color column добавляется, старые данные целы', () async {
      // Открываем БД с v7-схемой: reader_annotations без колонки color.
      final db = AppDatabase(
        NativeDatabase.memory(
          setup: (rawDb) {
            rawDb.execute('''
              CREATE TABLE books (
                id TEXT NOT NULL PRIMARY KEY,
                title TEXT NOT NULL,
                author TEXT NOT NULL,
                cover_url TEXT,
                file_path TEXT,
                file_format TEXT NOT NULL,
                added_at INTEGER NOT NULL,
                last_opened_at INTEGER
              )
            ''');
            rawDb.execute('''
              CREATE TABLE reader_annotations (
                id TEXT NOT NULL PRIMARY KEY,
                book_id TEXT NOT NULL,
                type INTEGER NOT NULL,
                char_start INTEGER NOT NULL,
                char_end INTEGER NOT NULL,
                chapter_index INTEGER,
                body TEXT NOT NULL,
                note_text TEXT,
                created_at INTEGER NOT NULL,
                FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
              )
            ''');
            rawDb.execute(
              "INSERT INTO books VALUES ('b1','T','A',NULL,NULL,'fb2',0,NULL)",
            );
            rawDb.execute(
              "INSERT INTO reader_annotations VALUES ('a1','b1',0,5,15,NULL,'old text',NULL,0)",
            );
            // Устанавливаем user_version=7 — Drift вызовет onUpgrade(m,7,8).
            rawDb.execute('PRAGMA user_version = 7');
          },
        ),
      );
      addTearDown(db.close);

      // Чтение форсирует открытие БД и запуск миграции.
      final rows = await db.select(db.readerAnnotations).get();
      expect(rows, hasLength(1));
      expect(rows.first.id, equals('a1'));
      // После миграции колонка color существует и равна NULL для старых строк.
      expect(rows.first.color == null, isTrue);
    });
  });
}
