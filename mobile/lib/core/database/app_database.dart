import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('BookRow')
class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get narrator => text().nullable()();
  TextColumn get filePath => text()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get format => text()();
  IntColumn get fileSize => integer().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
  RealColumn get readingProgress => real().withDefault(const Constant(0.0))();
  TextColumn get lastPosition => text().nullable()();
  IntColumn get totalPages => integer().nullable()();
  IntColumn get totalDuration => integer().nullable()();
  TextColumn get linkedBookId => text().nullable()();
  TextColumn get readingStatus =>
      text().withDefault(const Constant('notStarted'))();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get userRating => integer().nullable()();
  RealColumn get rating => real().nullable()();
  IntColumn get ratingCount => integer().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get language => text().nullable()();
  IntColumn get pageCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'bookish'));

  @override
  int get schemaVersion => 1;
}
