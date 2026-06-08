// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, BookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _narratorMeta = const VerificationMeta(
    'narrator',
  );
  @override
  late final GeneratedColumn<String> narrator = GeneratedColumn<String>(
    'narrator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readingProgressMeta = const VerificationMeta(
    'readingProgress',
  );
  @override
  late final GeneratedColumn<double> readingProgress = GeneratedColumn<double>(
    'reading_progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastPositionMeta = const VerificationMeta(
    'lastPosition',
  );
  @override
  late final GeneratedColumn<String> lastPosition = GeneratedColumn<String>(
    'last_position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDurationMeta = const VerificationMeta(
    'totalDuration',
  );
  @override
  late final GeneratedColumn<int> totalDuration = GeneratedColumn<int>(
    'total_duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedBookIdMeta = const VerificationMeta(
    'linkedBookId',
  );
  @override
  late final GeneratedColumn<String> linkedBookId = GeneratedColumn<String>(
    'linked_book_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readingStatusMeta = const VerificationMeta(
    'readingStatus',
  );
  @override
  late final GeneratedColumn<String> readingStatus = GeneratedColumn<String>(
    'reading_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('notStarted'),
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userRatingMeta = const VerificationMeta(
    'userRating',
  );
  @override
  late final GeneratedColumn<int> userRating = GeneratedColumn<int>(
    'user_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingCountMeta = const VerificationMeta(
    'ratingCount',
  );
  @override
  late final GeneratedColumn<int> ratingCount = GeneratedColumn<int>(
    'rating_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverImagePathMeta = const VerificationMeta(
    'coverImagePath',
  );
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
    'cover_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    narrator,
    filePath,
    coverUrl,
    format,
    fileSize,
    addedAt,
    lastOpenedAt,
    readingProgress,
    lastPosition,
    totalPages,
    totalDuration,
    linkedBookId,
    readingStatus,
    finishedAt,
    userRating,
    rating,
    ratingCount,
    description,
    language,
    pageCount,
    coverImagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('narrator')) {
      context.handle(
        _narratorMeta,
        narrator.isAcceptableOrUnknown(data['narrator']!, _narratorMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    }
    if (data.containsKey('reading_progress')) {
      context.handle(
        _readingProgressMeta,
        readingProgress.isAcceptableOrUnknown(
          data['reading_progress']!,
          _readingProgressMeta,
        ),
      );
    }
    if (data.containsKey('last_position')) {
      context.handle(
        _lastPositionMeta,
        lastPosition.isAcceptableOrUnknown(
          data['last_position']!,
          _lastPositionMeta,
        ),
      );
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('total_duration')) {
      context.handle(
        _totalDurationMeta,
        totalDuration.isAcceptableOrUnknown(
          data['total_duration']!,
          _totalDurationMeta,
        ),
      );
    }
    if (data.containsKey('linked_book_id')) {
      context.handle(
        _linkedBookIdMeta,
        linkedBookId.isAcceptableOrUnknown(
          data['linked_book_id']!,
          _linkedBookIdMeta,
        ),
      );
    }
    if (data.containsKey('reading_status')) {
      context.handle(
        _readingStatusMeta,
        readingStatus.isAcceptableOrUnknown(
          data['reading_status']!,
          _readingStatusMeta,
        ),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('user_rating')) {
      context.handle(
        _userRatingMeta,
        userRating.isAcceptableOrUnknown(data['user_rating']!, _userRatingMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('rating_count')) {
      context.handle(
        _ratingCountMeta,
        ratingCount.isAcceptableOrUnknown(
          data['rating_count']!,
          _ratingCountMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('cover_image_path')) {
      context.handle(
        _coverImagePathMeta,
        coverImagePath.isAcceptableOrUnknown(
          data['cover_image_path']!,
          _coverImagePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      narrator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narrator'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      ),
      readingProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reading_progress'],
      )!,
      lastPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_position'],
      ),
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      ),
      totalDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration'],
      ),
      linkedBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_book_id'],
      ),
      readingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_status'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      userRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_rating'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      ratingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating_count'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      coverImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_path'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class BookRow extends DataClass implements Insertable<BookRow> {
  final String id;
  final String title;
  final String author;
  final String? narrator;
  final String filePath;
  final String? coverUrl;
  final String format;
  final int? fileSize;
  final DateTime addedAt;
  final DateTime? lastOpenedAt;
  final double readingProgress;
  final String? lastPosition;
  final int? totalPages;
  final int? totalDuration;
  final String? linkedBookId;
  final String readingStatus;
  final DateTime? finishedAt;
  final int? userRating;
  final double? rating;
  final int? ratingCount;
  final String? description;
  final String? language;
  final int? pageCount;
  final String? coverImagePath;
  const BookRow({
    required this.id,
    required this.title,
    required this.author,
    this.narrator,
    required this.filePath,
    this.coverUrl,
    required this.format,
    this.fileSize,
    required this.addedAt,
    this.lastOpenedAt,
    required this.readingProgress,
    this.lastPosition,
    this.totalPages,
    this.totalDuration,
    this.linkedBookId,
    required this.readingStatus,
    this.finishedAt,
    this.userRating,
    this.rating,
    this.ratingCount,
    this.description,
    this.language,
    this.pageCount,
    this.coverImagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || narrator != null) {
      map['narrator'] = Variable<String>(narrator);
    }
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    map['format'] = Variable<String>(format);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    map['reading_progress'] = Variable<double>(readingProgress);
    if (!nullToAbsent || lastPosition != null) {
      map['last_position'] = Variable<String>(lastPosition);
    }
    if (!nullToAbsent || totalPages != null) {
      map['total_pages'] = Variable<int>(totalPages);
    }
    if (!nullToAbsent || totalDuration != null) {
      map['total_duration'] = Variable<int>(totalDuration);
    }
    if (!nullToAbsent || linkedBookId != null) {
      map['linked_book_id'] = Variable<String>(linkedBookId);
    }
    map['reading_status'] = Variable<String>(readingStatus);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || userRating != null) {
      map['user_rating'] = Variable<int>(userRating);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || ratingCount != null) {
      map['rating_count'] = Variable<int>(ratingCount);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      narrator: narrator == null && nullToAbsent
          ? const Value.absent()
          : Value(narrator),
      filePath: Value(filePath),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      format: Value(format),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      addedAt: Value(addedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
      readingProgress: Value(readingProgress),
      lastPosition: lastPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPosition),
      totalPages: totalPages == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPages),
      totalDuration: totalDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDuration),
      linkedBookId: linkedBookId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedBookId),
      readingStatus: Value(readingStatus),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      userRating: userRating == null && nullToAbsent
          ? const Value.absent()
          : Value(userRating),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      ratingCount: ratingCount == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingCount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
    );
  }

  factory BookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      narrator: serializer.fromJson<String?>(json['narrator']),
      filePath: serializer.fromJson<String>(json['filePath']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      format: serializer.fromJson<String>(json['format']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
      readingProgress: serializer.fromJson<double>(json['readingProgress']),
      lastPosition: serializer.fromJson<String?>(json['lastPosition']),
      totalPages: serializer.fromJson<int?>(json['totalPages']),
      totalDuration: serializer.fromJson<int?>(json['totalDuration']),
      linkedBookId: serializer.fromJson<String?>(json['linkedBookId']),
      readingStatus: serializer.fromJson<String>(json['readingStatus']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      userRating: serializer.fromJson<int?>(json['userRating']),
      rating: serializer.fromJson<double?>(json['rating']),
      ratingCount: serializer.fromJson<int?>(json['ratingCount']),
      description: serializer.fromJson<String?>(json['description']),
      language: serializer.fromJson<String?>(json['language']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'narrator': serializer.toJson<String?>(narrator),
      'filePath': serializer.toJson<String>(filePath),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'format': serializer.toJson<String>(format),
      'fileSize': serializer.toJson<int?>(fileSize),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
      'readingProgress': serializer.toJson<double>(readingProgress),
      'lastPosition': serializer.toJson<String?>(lastPosition),
      'totalPages': serializer.toJson<int?>(totalPages),
      'totalDuration': serializer.toJson<int?>(totalDuration),
      'linkedBookId': serializer.toJson<String?>(linkedBookId),
      'readingStatus': serializer.toJson<String>(readingStatus),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'userRating': serializer.toJson<int?>(userRating),
      'rating': serializer.toJson<double?>(rating),
      'ratingCount': serializer.toJson<int?>(ratingCount),
      'description': serializer.toJson<String?>(description),
      'language': serializer.toJson<String?>(language),
      'pageCount': serializer.toJson<int?>(pageCount),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
    };
  }

  BookRow copyWith({
    String? id,
    String? title,
    String? author,
    Value<String?> narrator = const Value.absent(),
    String? filePath,
    Value<String?> coverUrl = const Value.absent(),
    String? format,
    Value<int?> fileSize = const Value.absent(),
    DateTime? addedAt,
    Value<DateTime?> lastOpenedAt = const Value.absent(),
    double? readingProgress,
    Value<String?> lastPosition = const Value.absent(),
    Value<int?> totalPages = const Value.absent(),
    Value<int?> totalDuration = const Value.absent(),
    Value<String?> linkedBookId = const Value.absent(),
    String? readingStatus,
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<int?> userRating = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<int?> ratingCount = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> language = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<String?> coverImagePath = const Value.absent(),
  }) => BookRow(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    narrator: narrator.present ? narrator.value : this.narrator,
    filePath: filePath ?? this.filePath,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    format: format ?? this.format,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    addedAt: addedAt ?? this.addedAt,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
    readingProgress: readingProgress ?? this.readingProgress,
    lastPosition: lastPosition.present ? lastPosition.value : this.lastPosition,
    totalPages: totalPages.present ? totalPages.value : this.totalPages,
    totalDuration: totalDuration.present
        ? totalDuration.value
        : this.totalDuration,
    linkedBookId: linkedBookId.present ? linkedBookId.value : this.linkedBookId,
    readingStatus: readingStatus ?? this.readingStatus,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    userRating: userRating.present ? userRating.value : this.userRating,
    rating: rating.present ? rating.value : this.rating,
    ratingCount: ratingCount.present ? ratingCount.value : this.ratingCount,
    description: description.present ? description.value : this.description,
    language: language.present ? language.value : this.language,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    coverImagePath: coverImagePath.present
        ? coverImagePath.value
        : this.coverImagePath,
  );
  BookRow copyWithCompanion(BooksCompanion data) {
    return BookRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      narrator: data.narrator.present ? data.narrator.value : this.narrator,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      format: data.format.present ? data.format.value : this.format,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      readingProgress: data.readingProgress.present
          ? data.readingProgress.value
          : this.readingProgress,
      lastPosition: data.lastPosition.present
          ? data.lastPosition.value
          : this.lastPosition,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      totalDuration: data.totalDuration.present
          ? data.totalDuration.value
          : this.totalDuration,
      linkedBookId: data.linkedBookId.present
          ? data.linkedBookId.value
          : this.linkedBookId,
      readingStatus: data.readingStatus.present
          ? data.readingStatus.value
          : this.readingStatus,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      userRating: data.userRating.present
          ? data.userRating.value
          : this.userRating,
      rating: data.rating.present ? data.rating.value : this.rating,
      ratingCount: data.ratingCount.present
          ? data.ratingCount.value
          : this.ratingCount,
      description: data.description.present
          ? data.description.value
          : this.description,
      language: data.language.present ? data.language.value : this.language,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('narrator: $narrator, ')
          ..write('filePath: $filePath, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('format: $format, ')
          ..write('fileSize: $fileSize, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('readingProgress: $readingProgress, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('totalPages: $totalPages, ')
          ..write('totalDuration: $totalDuration, ')
          ..write('linkedBookId: $linkedBookId, ')
          ..write('readingStatus: $readingStatus, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('userRating: $userRating, ')
          ..write('rating: $rating, ')
          ..write('ratingCount: $ratingCount, ')
          ..write('description: $description, ')
          ..write('language: $language, ')
          ..write('pageCount: $pageCount, ')
          ..write('coverImagePath: $coverImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    author,
    narrator,
    filePath,
    coverUrl,
    format,
    fileSize,
    addedAt,
    lastOpenedAt,
    readingProgress,
    lastPosition,
    totalPages,
    totalDuration,
    linkedBookId,
    readingStatus,
    finishedAt,
    userRating,
    rating,
    ratingCount,
    description,
    language,
    pageCount,
    coverImagePath,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.narrator == this.narrator &&
          other.filePath == this.filePath &&
          other.coverUrl == this.coverUrl &&
          other.format == this.format &&
          other.fileSize == this.fileSize &&
          other.addedAt == this.addedAt &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.readingProgress == this.readingProgress &&
          other.lastPosition == this.lastPosition &&
          other.totalPages == this.totalPages &&
          other.totalDuration == this.totalDuration &&
          other.linkedBookId == this.linkedBookId &&
          other.readingStatus == this.readingStatus &&
          other.finishedAt == this.finishedAt &&
          other.userRating == this.userRating &&
          other.rating == this.rating &&
          other.ratingCount == this.ratingCount &&
          other.description == this.description &&
          other.language == this.language &&
          other.pageCount == this.pageCount &&
          other.coverImagePath == this.coverImagePath);
}

class BooksCompanion extends UpdateCompanion<BookRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String?> narrator;
  final Value<String> filePath;
  final Value<String?> coverUrl;
  final Value<String> format;
  final Value<int?> fileSize;
  final Value<DateTime> addedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<double> readingProgress;
  final Value<String?> lastPosition;
  final Value<int?> totalPages;
  final Value<int?> totalDuration;
  final Value<String?> linkedBookId;
  final Value<String> readingStatus;
  final Value<DateTime?> finishedAt;
  final Value<int?> userRating;
  final Value<double?> rating;
  final Value<int?> ratingCount;
  final Value<String?> description;
  final Value<String?> language;
  final Value<int?> pageCount;
  final Value<String?> coverImagePath;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.narrator = const Value.absent(),
    this.filePath = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.format = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.readingProgress = const Value.absent(),
    this.lastPosition = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.totalDuration = const Value.absent(),
    this.linkedBookId = const Value.absent(),
    this.readingStatus = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.userRating = const Value.absent(),
    this.rating = const Value.absent(),
    this.ratingCount = const Value.absent(),
    this.description = const Value.absent(),
    this.language = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String title,
    required String author,
    this.narrator = const Value.absent(),
    required String filePath,
    this.coverUrl = const Value.absent(),
    required String format,
    this.fileSize = const Value.absent(),
    required DateTime addedAt,
    this.lastOpenedAt = const Value.absent(),
    this.readingProgress = const Value.absent(),
    this.lastPosition = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.totalDuration = const Value.absent(),
    this.linkedBookId = const Value.absent(),
    this.readingStatus = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.userRating = const Value.absent(),
    this.rating = const Value.absent(),
    this.ratingCount = const Value.absent(),
    this.description = const Value.absent(),
    this.language = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       author = Value(author),
       filePath = Value(filePath),
       format = Value(format),
       addedAt = Value(addedAt);
  static Insertable<BookRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? narrator,
    Expression<String>? filePath,
    Expression<String>? coverUrl,
    Expression<String>? format,
    Expression<int>? fileSize,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<double>? readingProgress,
    Expression<String>? lastPosition,
    Expression<int>? totalPages,
    Expression<int>? totalDuration,
    Expression<String>? linkedBookId,
    Expression<String>? readingStatus,
    Expression<DateTime>? finishedAt,
    Expression<int>? userRating,
    Expression<double>? rating,
    Expression<int>? ratingCount,
    Expression<String>? description,
    Expression<String>? language,
    Expression<int>? pageCount,
    Expression<String>? coverImagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (narrator != null) 'narrator': narrator,
      if (filePath != null) 'file_path': filePath,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (format != null) 'format': format,
      if (fileSize != null) 'file_size': fileSize,
      if (addedAt != null) 'added_at': addedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (readingProgress != null) 'reading_progress': readingProgress,
      if (lastPosition != null) 'last_position': lastPosition,
      if (totalPages != null) 'total_pages': totalPages,
      if (totalDuration != null) 'total_duration': totalDuration,
      if (linkedBookId != null) 'linked_book_id': linkedBookId,
      if (readingStatus != null) 'reading_status': readingStatus,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (userRating != null) 'user_rating': userRating,
      if (rating != null) 'rating': rating,
      if (ratingCount != null) 'rating_count': ratingCount,
      if (description != null) 'description': description,
      if (language != null) 'language': language,
      if (pageCount != null) 'page_count': pageCount,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? author,
    Value<String?>? narrator,
    Value<String>? filePath,
    Value<String?>? coverUrl,
    Value<String>? format,
    Value<int?>? fileSize,
    Value<DateTime>? addedAt,
    Value<DateTime?>? lastOpenedAt,
    Value<double>? readingProgress,
    Value<String?>? lastPosition,
    Value<int?>? totalPages,
    Value<int?>? totalDuration,
    Value<String?>? linkedBookId,
    Value<String>? readingStatus,
    Value<DateTime?>? finishedAt,
    Value<int?>? userRating,
    Value<double?>? rating,
    Value<int?>? ratingCount,
    Value<String?>? description,
    Value<String?>? language,
    Value<int?>? pageCount,
    Value<String?>? coverImagePath,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      narrator: narrator ?? this.narrator,
      filePath: filePath ?? this.filePath,
      coverUrl: coverUrl ?? this.coverUrl,
      format: format ?? this.format,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt ?? this.addedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      readingProgress: readingProgress ?? this.readingProgress,
      lastPosition: lastPosition ?? this.lastPosition,
      totalPages: totalPages ?? this.totalPages,
      totalDuration: totalDuration ?? this.totalDuration,
      linkedBookId: linkedBookId ?? this.linkedBookId,
      readingStatus: readingStatus ?? this.readingStatus,
      finishedAt: finishedAt ?? this.finishedAt,
      userRating: userRating ?? this.userRating,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      description: description ?? this.description,
      language: language ?? this.language,
      pageCount: pageCount ?? this.pageCount,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (narrator.present) {
      map['narrator'] = Variable<String>(narrator.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (readingProgress.present) {
      map['reading_progress'] = Variable<double>(readingProgress.value);
    }
    if (lastPosition.present) {
      map['last_position'] = Variable<String>(lastPosition.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (totalDuration.present) {
      map['total_duration'] = Variable<int>(totalDuration.value);
    }
    if (linkedBookId.present) {
      map['linked_book_id'] = Variable<String>(linkedBookId.value);
    }
    if (readingStatus.present) {
      map['reading_status'] = Variable<String>(readingStatus.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (userRating.present) {
      map['user_rating'] = Variable<int>(userRating.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (ratingCount.present) {
      map['rating_count'] = Variable<int>(ratingCount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('narrator: $narrator, ')
          ..write('filePath: $filePath, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('format: $format, ')
          ..write('fileSize: $fileSize, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('readingProgress: $readingProgress, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('totalPages: $totalPages, ')
          ..write('totalDuration: $totalDuration, ')
          ..write('linkedBookId: $linkedBookId, ')
          ..write('readingStatus: $readingStatus, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('userRating: $userRating, ')
          ..write('rating: $rating, ')
          ..write('ratingCount: $ratingCount, ')
          ..write('description: $description, ')
          ..write('language: $language, ')
          ..write('pageCount: $pageCount, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookChaptersTable extends BookChapters
    with TableInfo<$BookChaptersTable, BookChapterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startOffsetMsMeta = const VerificationMeta(
    'startOffsetMs',
  );
  @override
  late final GeneratedColumn<int> startOffsetMs = GeneratedColumn<int>(
    'start_offset_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    position,
    filePath,
    title,
    duration,
    startOffsetMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookChapterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('start_offset_ms')) {
      context.handle(
        _startOffsetMsMeta,
        startOffsetMs.isAcceptableOrUnknown(
          data['start_offset_ms']!,
          _startOffsetMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookChapterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookChapterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      startOffsetMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_offset_ms'],
      )!,
    );
  }

  @override
  $BookChaptersTable createAlias(String alias) {
    return $BookChaptersTable(attachedDatabase, alias);
  }
}

class BookChapterRow extends DataClass implements Insertable<BookChapterRow> {
  final String id;
  final String bookId;
  final int position;
  final String filePath;
  final String? title;
  final int? duration;
  final int startOffsetMs;
  const BookChapterRow({
    required this.id,
    required this.bookId,
    required this.position,
    required this.filePath,
    this.title,
    this.duration,
    required this.startOffsetMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['position'] = Variable<int>(position);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    map['start_offset_ms'] = Variable<int>(startOffsetMs);
    return map;
  }

  BookChaptersCompanion toCompanion(bool nullToAbsent) {
    return BookChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      position: Value(position),
      filePath: Value(filePath),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      startOffsetMs: Value(startOffsetMs),
    );
  }

  factory BookChapterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookChapterRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      position: serializer.fromJson<int>(json['position']),
      filePath: serializer.fromJson<String>(json['filePath']),
      title: serializer.fromJson<String?>(json['title']),
      duration: serializer.fromJson<int?>(json['duration']),
      startOffsetMs: serializer.fromJson<int>(json['startOffsetMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'position': serializer.toJson<int>(position),
      'filePath': serializer.toJson<String>(filePath),
      'title': serializer.toJson<String?>(title),
      'duration': serializer.toJson<int?>(duration),
      'startOffsetMs': serializer.toJson<int>(startOffsetMs),
    };
  }

  BookChapterRow copyWith({
    String? id,
    String? bookId,
    int? position,
    String? filePath,
    Value<String?> title = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    int? startOffsetMs,
  }) => BookChapterRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    position: position ?? this.position,
    filePath: filePath ?? this.filePath,
    title: title.present ? title.value : this.title,
    duration: duration.present ? duration.value : this.duration,
    startOffsetMs: startOffsetMs ?? this.startOffsetMs,
  );
  BookChapterRow copyWithCompanion(BookChaptersCompanion data) {
    return BookChapterRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      position: data.position.present ? data.position.value : this.position,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      title: data.title.present ? data.title.value : this.title,
      duration: data.duration.present ? data.duration.value : this.duration,
      startOffsetMs: data.startOffsetMs.present
          ? data.startOffsetMs.value
          : this.startOffsetMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookChapterRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('position: $position, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('duration: $duration, ')
          ..write('startOffsetMs: $startOffsetMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    position,
    filePath,
    title,
    duration,
    startOffsetMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookChapterRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.position == this.position &&
          other.filePath == this.filePath &&
          other.title == this.title &&
          other.duration == this.duration &&
          other.startOffsetMs == this.startOffsetMs);
}

class BookChaptersCompanion extends UpdateCompanion<BookChapterRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> position;
  final Value<String> filePath;
  final Value<String?> title;
  final Value<int?> duration;
  final Value<int> startOffsetMs;
  final Value<int> rowid;
  const BookChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.position = const Value.absent(),
    this.filePath = const Value.absent(),
    this.title = const Value.absent(),
    this.duration = const Value.absent(),
    this.startOffsetMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookChaptersCompanion.insert({
    required String id,
    required String bookId,
    required int position,
    required String filePath,
    this.title = const Value.absent(),
    this.duration = const Value.absent(),
    this.startOffsetMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       position = Value(position),
       filePath = Value(filePath);
  static Insertable<BookChapterRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? position,
    Expression<String>? filePath,
    Expression<String>? title,
    Expression<int>? duration,
    Expression<int>? startOffsetMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (position != null) 'position': position,
      if (filePath != null) 'file_path': filePath,
      if (title != null) 'title': title,
      if (duration != null) 'duration': duration,
      if (startOffsetMs != null) 'start_offset_ms': startOffsetMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookChaptersCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<int>? position,
    Value<String>? filePath,
    Value<String?>? title,
    Value<int?>? duration,
    Value<int>? startOffsetMs,
    Value<int>? rowid,
  }) {
    return BookChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      position: position ?? this.position,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      startOffsetMs: startOffsetMs ?? this.startOffsetMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (startOffsetMs.present) {
      map['start_offset_ms'] = Variable<int>(startOffsetMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('position: $position, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('duration: $duration, ')
          ..write('startOffsetMs: $startOffsetMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioProgressTable extends AudioProgress
    with TableInfo<$AudioProgressTable, AudioProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    chapterIndex,
    positionMs,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  AudioProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioProgressRow(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AudioProgressTable createAlias(String alias) {
    return $AudioProgressTable(attachedDatabase, alias);
  }
}

class AudioProgressRow extends DataClass
    implements Insertable<AudioProgressRow> {
  final String bookId;
  final int chapterIndex;
  final int positionMs;
  final DateTime updatedAt;
  const AudioProgressRow({
    required this.bookId,
    required this.chapterIndex,
    required this.positionMs,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AudioProgressCompanion toCompanion(bool nullToAbsent) {
    return AudioProgressCompanion(
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      positionMs: Value(positionMs),
      updatedAt: Value(updatedAt),
    );
  }

  factory AudioProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioProgressRow(
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AudioProgressRow copyWith({
    String? bookId,
    int? chapterIndex,
    int? positionMs,
    DateTime? updatedAt,
  }) => AudioProgressRow(
    bookId: bookId ?? this.bookId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    positionMs: positionMs ?? this.positionMs,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AudioProgressRow copyWithCompanion(AudioProgressCompanion data) {
    return AudioProgressRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioProgressRow(')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, chapterIndex, positionMs, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioProgressRow &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.positionMs == this.positionMs &&
          other.updatedAt == this.updatedAt);
}

class AudioProgressCompanion extends UpdateCompanion<AudioProgressRow> {
  final Value<String> bookId;
  final Value<int> chapterIndex;
  final Value<int> positionMs;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AudioProgressCompanion({
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioProgressCompanion.insert({
    required String bookId,
    required int chapterIndex,
    required int positionMs,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       chapterIndex = Value(chapterIndex),
       positionMs = Value(positionMs),
       updatedAt = Value(updatedAt);
  static Insertable<AudioProgressRow> custom({
    Expression<String>? bookId,
    Expression<int>? chapterIndex,
    Expression<int>? positionMs,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioProgressCompanion copyWith({
    Value<String>? bookId,
    Value<int>? chapterIndex,
    Value<int>? positionMs,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AudioProgressCompanion(
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      positionMs: positionMs ?? this.positionMs,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioProgressCompanion(')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioBookmarksTable extends AudioBookmarks
    with TableInfo<$AudioBookmarksTable, AudioBookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterTitleMeta = const VerificationMeta(
    'chapterTitle',
  );
  @override
  late final GeneratedColumn<String> chapterTitle = GeneratedColumn<String>(
    'chapter_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapterIndex,
    positionMs,
    title,
    chapterTitle,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioBookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('chapter_title')) {
      context.handle(
        _chapterTitleMeta,
        chapterTitle.isAcceptableOrUnknown(
          data['chapter_title']!,
          _chapterTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterTitleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioBookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioBookmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      chapterTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $AudioBookmarksTable createAlias(String alias) {
    return $AudioBookmarksTable(attachedDatabase, alias);
  }
}

class AudioBookmarkRow extends DataClass
    implements Insertable<AudioBookmarkRow> {
  final String id;
  final String bookId;
  final int chapterIndex;
  final int positionMs;
  final String title;
  final String chapterTitle;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const AudioBookmarkRow({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.positionMs,
    required this.title,
    required this.chapterTitle,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['title'] = Variable<String>(title);
    map['chapter_title'] = Variable<String>(chapterTitle);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AudioBookmarksCompanion toCompanion(bool nullToAbsent) {
    return AudioBookmarksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      positionMs: Value(positionMs),
      title: Value(title),
      chapterTitle: Value(chapterTitle),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory AudioBookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioBookmarkRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      title: serializer.fromJson<String>(json['title']),
      chapterTitle: serializer.fromJson<String>(json['chapterTitle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'title': serializer.toJson<String>(title),
      'chapterTitle': serializer.toJson<String>(chapterTitle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  AudioBookmarkRow copyWith({
    String? id,
    String? bookId,
    int? chapterIndex,
    int? positionMs,
    String? title,
    String? chapterTitle,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => AudioBookmarkRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    positionMs: positionMs ?? this.positionMs,
    title: title ?? this.title,
    chapterTitle: chapterTitle ?? this.chapterTitle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  AudioBookmarkRow copyWithCompanion(AudioBookmarksCompanion data) {
    return AudioBookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      title: data.title.present ? data.title.value : this.title,
      chapterTitle: data.chapterTitle.present
          ? data.chapterTitle.value
          : this.chapterTitle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioBookmarkRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('title: $title, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    chapterIndex,
    positionMs,
    title,
    chapterTitle,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioBookmarkRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.positionMs == this.positionMs &&
          other.title == this.title &&
          other.chapterTitle == this.chapterTitle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AudioBookmarksCompanion extends UpdateCompanion<AudioBookmarkRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> chapterIndex;
  final Value<int> positionMs;
  final Value<String> title;
  final Value<String> chapterTitle;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const AudioBookmarksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.title = const Value.absent(),
    this.chapterTitle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioBookmarksCompanion.insert({
    required String id,
    required String bookId,
    required int chapterIndex,
    required int positionMs,
    required String title,
    required String chapterTitle,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       chapterIndex = Value(chapterIndex),
       positionMs = Value(positionMs),
       title = Value(title),
       chapterTitle = Value(chapterTitle),
       createdAt = Value(createdAt);
  static Insertable<AudioBookmarkRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? chapterIndex,
    Expression<int>? positionMs,
    Expression<String>? title,
    Expression<String>? chapterTitle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (title != null) 'title': title,
      if (chapterTitle != null) 'chapter_title': chapterTitle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioBookmarksCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<int>? chapterIndex,
    Value<int>? positionMs,
    Value<String>? title,
    Value<String>? chapterTitle,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return AudioBookmarksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      positionMs: positionMs ?? this.positionMs,
      title: title ?? this.title,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (chapterTitle.present) {
      map['chapter_title'] = Variable<String>(chapterTitle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioBookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('title: $title, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReaderProgressTable extends ReaderProgress
    with TableInfo<$ReaderProgressTable, ReaderProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES books(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _charOffsetMeta = const VerificationMeta(
    'charOffset',
  );
  @override
  late final GeneratedColumn<int> charOffset = GeneratedColumn<int>(
    'char_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _percentMeta = const VerificationMeta(
    'percent',
  );
  @override
  late final GeneratedColumn<double> percent = GeneratedColumn<double>(
    'percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    charOffset,
    chapterIndex,
    percent,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('char_offset')) {
      context.handle(
        _charOffsetMeta,
        charOffset.isAcceptableOrUnknown(data['char_offset']!, _charOffsetMeta),
      );
    } else if (isInserting) {
      context.missing(_charOffsetMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    }
    if (data.containsKey('percent')) {
      context.handle(
        _percentMeta,
        percent.isAcceptableOrUnknown(data['percent']!, _percentMeta),
      );
    } else if (isInserting) {
      context.missing(_percentMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  ReaderProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderProgressRow(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      charOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}char_offset'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      ),
      percent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percent'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReaderProgressTable createAlias(String alias) {
    return $ReaderProgressTable(attachedDatabase, alias);
  }
}

class ReaderProgressRow extends DataClass
    implements Insertable<ReaderProgressRow> {
  final String bookId;
  final int charOffset;
  final int? chapterIndex;
  final double percent;
  final DateTime updatedAt;
  const ReaderProgressRow({
    required this.bookId,
    required this.charOffset,
    this.chapterIndex,
    required this.percent,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['char_offset'] = Variable<int>(charOffset);
    if (!nullToAbsent || chapterIndex != null) {
      map['chapter_index'] = Variable<int>(chapterIndex);
    }
    map['percent'] = Variable<double>(percent);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReaderProgressCompanion toCompanion(bool nullToAbsent) {
    return ReaderProgressCompanion(
      bookId: Value(bookId),
      charOffset: Value(charOffset),
      chapterIndex: chapterIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterIndex),
      percent: Value(percent),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReaderProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderProgressRow(
      bookId: serializer.fromJson<String>(json['bookId']),
      charOffset: serializer.fromJson<int>(json['charOffset']),
      chapterIndex: serializer.fromJson<int?>(json['chapterIndex']),
      percent: serializer.fromJson<double>(json['percent']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'charOffset': serializer.toJson<int>(charOffset),
      'chapterIndex': serializer.toJson<int?>(chapterIndex),
      'percent': serializer.toJson<double>(percent),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReaderProgressRow copyWith({
    String? bookId,
    int? charOffset,
    Value<int?> chapterIndex = const Value.absent(),
    double? percent,
    DateTime? updatedAt,
  }) => ReaderProgressRow(
    bookId: bookId ?? this.bookId,
    charOffset: charOffset ?? this.charOffset,
    chapterIndex: chapterIndex.present ? chapterIndex.value : this.chapterIndex,
    percent: percent ?? this.percent,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReaderProgressRow copyWithCompanion(ReaderProgressCompanion data) {
    return ReaderProgressRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      charOffset: data.charOffset.present
          ? data.charOffset.value
          : this.charOffset,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      percent: data.percent.present ? data.percent.value : this.percent,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderProgressRow(')
          ..write('bookId: $bookId, ')
          ..write('charOffset: $charOffset, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('percent: $percent, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(bookId, charOffset, chapterIndex, percent, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderProgressRow &&
          other.bookId == this.bookId &&
          other.charOffset == this.charOffset &&
          other.chapterIndex == this.chapterIndex &&
          other.percent == this.percent &&
          other.updatedAt == this.updatedAt);
}

class ReaderProgressCompanion extends UpdateCompanion<ReaderProgressRow> {
  final Value<String> bookId;
  final Value<int> charOffset;
  final Value<int?> chapterIndex;
  final Value<double> percent;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReaderProgressCompanion({
    this.bookId = const Value.absent(),
    this.charOffset = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.percent = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReaderProgressCompanion.insert({
    required String bookId,
    required int charOffset,
    this.chapterIndex = const Value.absent(),
    required double percent,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       charOffset = Value(charOffset),
       percent = Value(percent),
       updatedAt = Value(updatedAt);
  static Insertable<ReaderProgressRow> custom({
    Expression<String>? bookId,
    Expression<int>? charOffset,
    Expression<int>? chapterIndex,
    Expression<double>? percent,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (charOffset != null) 'char_offset': charOffset,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (percent != null) 'percent': percent,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReaderProgressCompanion copyWith({
    Value<String>? bookId,
    Value<int>? charOffset,
    Value<int?>? chapterIndex,
    Value<double>? percent,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReaderProgressCompanion(
      bookId: bookId ?? this.bookId,
      charOffset: charOffset ?? this.charOffset,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      percent: percent ?? this.percent,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (charOffset.present) {
      map['char_offset'] = Variable<int>(charOffset.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (percent.present) {
      map['percent'] = Variable<double>(percent.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderProgressCompanion(')
          ..write('bookId: $bookId, ')
          ..write('charOffset: $charOffset, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('percent: $percent, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReaderBookmarksTable extends ReaderBookmarks
    with TableInfo<$ReaderBookmarksTable, ReaderBookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES books(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _charOffsetMeta = const VerificationMeta(
    'charOffset',
  );
  @override
  late final GeneratedColumn<int> charOffset = GeneratedColumn<int>(
    'char_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previewTextMeta = const VerificationMeta(
    'previewText',
  );
  @override
  late final GeneratedColumn<String> previewText = GeneratedColumn<String>(
    'preview_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    charOffset,
    chapterIndex,
    previewText,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderBookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('char_offset')) {
      context.handle(
        _charOffsetMeta,
        charOffset.isAcceptableOrUnknown(data['char_offset']!, _charOffsetMeta),
      );
    } else if (isInserting) {
      context.missing(_charOffsetMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    }
    if (data.containsKey('preview_text')) {
      context.handle(
        _previewTextMeta,
        previewText.isAcceptableOrUnknown(
          data['preview_text']!,
          _previewTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previewTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReaderBookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderBookmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      charOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}char_offset'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      ),
      previewText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReaderBookmarksTable createAlias(String alias) {
    return $ReaderBookmarksTable(attachedDatabase, alias);
  }
}

class ReaderBookmarkRow extends DataClass
    implements Insertable<ReaderBookmarkRow> {
  final String id;
  final String bookId;
  final int charOffset;
  final int? chapterIndex;
  final String previewText;
  final DateTime createdAt;
  const ReaderBookmarkRow({
    required this.id,
    required this.bookId,
    required this.charOffset,
    this.chapterIndex,
    required this.previewText,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['char_offset'] = Variable<int>(charOffset);
    if (!nullToAbsent || chapterIndex != null) {
      map['chapter_index'] = Variable<int>(chapterIndex);
    }
    map['preview_text'] = Variable<String>(previewText);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReaderBookmarksCompanion toCompanion(bool nullToAbsent) {
    return ReaderBookmarksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      charOffset: Value(charOffset),
      chapterIndex: chapterIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterIndex),
      previewText: Value(previewText),
      createdAt: Value(createdAt),
    );
  }

  factory ReaderBookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderBookmarkRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      charOffset: serializer.fromJson<int>(json['charOffset']),
      chapterIndex: serializer.fromJson<int?>(json['chapterIndex']),
      previewText: serializer.fromJson<String>(json['previewText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'charOffset': serializer.toJson<int>(charOffset),
      'chapterIndex': serializer.toJson<int?>(chapterIndex),
      'previewText': serializer.toJson<String>(previewText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReaderBookmarkRow copyWith({
    String? id,
    String? bookId,
    int? charOffset,
    Value<int?> chapterIndex = const Value.absent(),
    String? previewText,
    DateTime? createdAt,
  }) => ReaderBookmarkRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    charOffset: charOffset ?? this.charOffset,
    chapterIndex: chapterIndex.present ? chapterIndex.value : this.chapterIndex,
    previewText: previewText ?? this.previewText,
    createdAt: createdAt ?? this.createdAt,
  );
  ReaderBookmarkRow copyWithCompanion(ReaderBookmarksCompanion data) {
    return ReaderBookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      charOffset: data.charOffset.present
          ? data.charOffset.value
          : this.charOffset,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      previewText: data.previewText.present
          ? data.previewText.value
          : this.previewText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderBookmarkRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('charOffset: $charOffset, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('previewText: $previewText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, charOffset, chapterIndex, previewText, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderBookmarkRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.charOffset == this.charOffset &&
          other.chapterIndex == this.chapterIndex &&
          other.previewText == this.previewText &&
          other.createdAt == this.createdAt);
}

class ReaderBookmarksCompanion extends UpdateCompanion<ReaderBookmarkRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> charOffset;
  final Value<int?> chapterIndex;
  final Value<String> previewText;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReaderBookmarksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.charOffset = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.previewText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReaderBookmarksCompanion.insert({
    required String id,
    required String bookId,
    required int charOffset,
    this.chapterIndex = const Value.absent(),
    required String previewText,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       charOffset = Value(charOffset),
       previewText = Value(previewText),
       createdAt = Value(createdAt);
  static Insertable<ReaderBookmarkRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? charOffset,
    Expression<int>? chapterIndex,
    Expression<String>? previewText,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (charOffset != null) 'char_offset': charOffset,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (previewText != null) 'preview_text': previewText,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReaderBookmarksCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<int>? charOffset,
    Value<int?>? chapterIndex,
    Value<String>? previewText,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReaderBookmarksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      charOffset: charOffset ?? this.charOffset,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      previewText: previewText ?? this.previewText,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (charOffset.present) {
      map['char_offset'] = Variable<int>(charOffset.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (previewText.present) {
      map['preview_text'] = Variable<String>(previewText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderBookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('charOffset: $charOffset, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('previewText: $previewText, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReaderAnnotationsTable extends ReaderAnnotations
    with TableInfo<$ReaderAnnotationsTable, ReaderAnnotationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderAnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES books(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charStartMeta = const VerificationMeta(
    'charStart',
  );
  @override
  late final GeneratedColumn<int> charStart = GeneratedColumn<int>(
    'char_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charEndMeta = const VerificationMeta(
    'charEnd',
  );
  @override
  late final GeneratedColumn<int> charEnd = GeneratedColumn<int>(
    'char_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteTextMeta = const VerificationMeta(
    'noteText',
  );
  @override
  late final GeneratedColumn<String> noteText = GeneratedColumn<String>(
    'note_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    type,
    charStart,
    charEnd,
    chapterIndex,
    body,
    noteText,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_annotations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderAnnotationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('char_start')) {
      context.handle(
        _charStartMeta,
        charStart.isAcceptableOrUnknown(data['char_start']!, _charStartMeta),
      );
    } else if (isInserting) {
      context.missing(_charStartMeta);
    }
    if (data.containsKey('char_end')) {
      context.handle(
        _charEndMeta,
        charEnd.isAcceptableOrUnknown(data['char_end']!, _charEndMeta),
      );
    } else if (isInserting) {
      context.missing(_charEndMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('note_text')) {
      context.handle(
        _noteTextMeta,
        noteText.isAcceptableOrUnknown(data['note_text']!, _noteTextMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReaderAnnotationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderAnnotationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      charStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}char_start'],
      )!,
      charEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}char_end'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      noteText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_text'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReaderAnnotationsTable createAlias(String alias) {
    return $ReaderAnnotationsTable(attachedDatabase, alias);
  }
}

class ReaderAnnotationRow extends DataClass
    implements Insertable<ReaderAnnotationRow> {
  final String id;
  final String bookId;
  final int type;
  final int charStart;
  final int charEnd;
  final int? chapterIndex;
  final String body;
  final String? noteText;
  final DateTime createdAt;
  const ReaderAnnotationRow({
    required this.id,
    required this.bookId,
    required this.type,
    required this.charStart,
    required this.charEnd,
    this.chapterIndex,
    required this.body,
    this.noteText,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['type'] = Variable<int>(type);
    map['char_start'] = Variable<int>(charStart);
    map['char_end'] = Variable<int>(charEnd);
    if (!nullToAbsent || chapterIndex != null) {
      map['chapter_index'] = Variable<int>(chapterIndex);
    }
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || noteText != null) {
      map['note_text'] = Variable<String>(noteText);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReaderAnnotationsCompanion toCompanion(bool nullToAbsent) {
    return ReaderAnnotationsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      type: Value(type),
      charStart: Value(charStart),
      charEnd: Value(charEnd),
      chapterIndex: chapterIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterIndex),
      body: Value(body),
      noteText: noteText == null && nullToAbsent
          ? const Value.absent()
          : Value(noteText),
      createdAt: Value(createdAt),
    );
  }

  factory ReaderAnnotationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderAnnotationRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      type: serializer.fromJson<int>(json['type']),
      charStart: serializer.fromJson<int>(json['charStart']),
      charEnd: serializer.fromJson<int>(json['charEnd']),
      chapterIndex: serializer.fromJson<int?>(json['chapterIndex']),
      body: serializer.fromJson<String>(json['body']),
      noteText: serializer.fromJson<String?>(json['noteText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'type': serializer.toJson<int>(type),
      'charStart': serializer.toJson<int>(charStart),
      'charEnd': serializer.toJson<int>(charEnd),
      'chapterIndex': serializer.toJson<int?>(chapterIndex),
      'body': serializer.toJson<String>(body),
      'noteText': serializer.toJson<String?>(noteText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReaderAnnotationRow copyWith({
    String? id,
    String? bookId,
    int? type,
    int? charStart,
    int? charEnd,
    Value<int?> chapterIndex = const Value.absent(),
    String? body,
    Value<String?> noteText = const Value.absent(),
    DateTime? createdAt,
  }) => ReaderAnnotationRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    type: type ?? this.type,
    charStart: charStart ?? this.charStart,
    charEnd: charEnd ?? this.charEnd,
    chapterIndex: chapterIndex.present ? chapterIndex.value : this.chapterIndex,
    body: body ?? this.body,
    noteText: noteText.present ? noteText.value : this.noteText,
    createdAt: createdAt ?? this.createdAt,
  );
  ReaderAnnotationRow copyWithCompanion(ReaderAnnotationsCompanion data) {
    return ReaderAnnotationRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      type: data.type.present ? data.type.value : this.type,
      charStart: data.charStart.present ? data.charStart.value : this.charStart,
      charEnd: data.charEnd.present ? data.charEnd.value : this.charEnd,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      body: data.body.present ? data.body.value : this.body,
      noteText: data.noteText.present ? data.noteText.value : this.noteText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderAnnotationRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('type: $type, ')
          ..write('charStart: $charStart, ')
          ..write('charEnd: $charEnd, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('body: $body, ')
          ..write('noteText: $noteText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    type,
    charStart,
    charEnd,
    chapterIndex,
    body,
    noteText,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderAnnotationRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.type == this.type &&
          other.charStart == this.charStart &&
          other.charEnd == this.charEnd &&
          other.chapterIndex == this.chapterIndex &&
          other.body == this.body &&
          other.noteText == this.noteText &&
          other.createdAt == this.createdAt);
}

class ReaderAnnotationsCompanion extends UpdateCompanion<ReaderAnnotationRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> type;
  final Value<int> charStart;
  final Value<int> charEnd;
  final Value<int?> chapterIndex;
  final Value<String> body;
  final Value<String?> noteText;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReaderAnnotationsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.type = const Value.absent(),
    this.charStart = const Value.absent(),
    this.charEnd = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.body = const Value.absent(),
    this.noteText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReaderAnnotationsCompanion.insert({
    required String id,
    required String bookId,
    required int type,
    required int charStart,
    required int charEnd,
    this.chapterIndex = const Value.absent(),
    required String body,
    this.noteText = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       type = Value(type),
       charStart = Value(charStart),
       charEnd = Value(charEnd),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<ReaderAnnotationRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? type,
    Expression<int>? charStart,
    Expression<int>? charEnd,
    Expression<int>? chapterIndex,
    Expression<String>? body,
    Expression<String>? noteText,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (type != null) 'type': type,
      if (charStart != null) 'char_start': charStart,
      if (charEnd != null) 'char_end': charEnd,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (body != null) 'body': body,
      if (noteText != null) 'note_text': noteText,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReaderAnnotationsCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<int>? type,
    Value<int>? charStart,
    Value<int>? charEnd,
    Value<int?>? chapterIndex,
    Value<String>? body,
    Value<String?>? noteText,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReaderAnnotationsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      type: type ?? this.type,
      charStart: charStart ?? this.charStart,
      charEnd: charEnd ?? this.charEnd,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      body: body ?? this.body,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (charStart.present) {
      map['char_start'] = Variable<int>(charStart.value);
    }
    if (charEnd.present) {
      map['char_end'] = Variable<int>(charEnd.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (noteText.present) {
      map['note_text'] = Variable<String>(noteText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderAnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('type: $type, ')
          ..write('charStart: $charStart, ')
          ..write('charEnd: $charEnd, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('body: $body, ')
          ..write('noteText: $noteText, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookChaptersTable bookChapters = $BookChaptersTable(this);
  late final $AudioProgressTable audioProgress = $AudioProgressTable(this);
  late final $AudioBookmarksTable audioBookmarks = $AudioBookmarksTable(this);
  late final $ReaderProgressTable readerProgress = $ReaderProgressTable(this);
  late final $ReaderBookmarksTable readerBookmarks = $ReaderBookmarksTable(
    this,
  );
  late final $ReaderAnnotationsTable readerAnnotations =
      $ReaderAnnotationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    bookChapters,
    audioProgress,
    audioBookmarks,
    readerProgress,
    readerBookmarks,
    readerAnnotations,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reader_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reader_bookmarks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reader_annotations', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      required String id,
      required String title,
      required String author,
      Value<String?> narrator,
      required String filePath,
      Value<String?> coverUrl,
      required String format,
      Value<int?> fileSize,
      required DateTime addedAt,
      Value<DateTime?> lastOpenedAt,
      Value<double> readingProgress,
      Value<String?> lastPosition,
      Value<int?> totalPages,
      Value<int?> totalDuration,
      Value<String?> linkedBookId,
      Value<String> readingStatus,
      Value<DateTime?> finishedAt,
      Value<int?> userRating,
      Value<double?> rating,
      Value<int?> ratingCount,
      Value<String?> description,
      Value<String?> language,
      Value<int?> pageCount,
      Value<String?> coverImagePath,
      Value<int> rowid,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> author,
      Value<String?> narrator,
      Value<String> filePath,
      Value<String?> coverUrl,
      Value<String> format,
      Value<int?> fileSize,
      Value<DateTime> addedAt,
      Value<DateTime?> lastOpenedAt,
      Value<double> readingProgress,
      Value<String?> lastPosition,
      Value<int?> totalPages,
      Value<int?> totalDuration,
      Value<String?> linkedBookId,
      Value<String> readingStatus,
      Value<DateTime?> finishedAt,
      Value<int?> userRating,
      Value<double?> rating,
      Value<int?> ratingCount,
      Value<String?> description,
      Value<String?> language,
      Value<int?> pageCount,
      Value<String?> coverImagePath,
      Value<int> rowid,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, BookRow> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReaderProgressTable, List<ReaderProgressRow>>
  _readerProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readerProgress,
    aliasName: $_aliasNameGenerator(db.books.id, db.readerProgress.bookId),
  );

  $$ReaderProgressTableProcessedTableManager get readerProgressRefs {
    final manager = $$ReaderProgressTableTableManager(
      $_db,
      $_db.readerProgress,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_readerProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReaderBookmarksTable, List<ReaderBookmarkRow>>
  _readerBookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readerBookmarks,
    aliasName: $_aliasNameGenerator(db.books.id, db.readerBookmarks.bookId),
  );

  $$ReaderBookmarksTableProcessedTableManager get readerBookmarksRefs {
    final manager = $$ReaderBookmarksTableTableManager(
      $_db,
      $_db.readerBookmarks,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readerBookmarksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReaderAnnotationsTable, List<ReaderAnnotationRow>>
  _readerAnnotationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.readerAnnotations,
        aliasName: $_aliasNameGenerator(
          db.books.id,
          db.readerAnnotations.bookId,
        ),
      );

  $$ReaderAnnotationsTableProcessedTableManager get readerAnnotationsRefs {
    final manager = $$ReaderAnnotationsTableTableManager(
      $_db,
      $_db.readerAnnotations,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readerAnnotationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get readingProgress => $composableBuilder(
    column: $table.readingProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDuration => $composableBuilder(
    column: $table.totalDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedBookId => $composableBuilder(
    column: $table.linkedBookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratingCount => $composableBuilder(
    column: $table.ratingCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> readerProgressRefs(
    Expression<bool> Function($$ReaderProgressTableFilterComposer f) f,
  ) {
    final $$ReaderProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerProgress,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderProgressTableFilterComposer(
            $db: $db,
            $table: $db.readerProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readerBookmarksRefs(
    Expression<bool> Function($$ReaderBookmarksTableFilterComposer f) f,
  ) {
    final $$ReaderBookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerBookmarks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderBookmarksTableFilterComposer(
            $db: $db,
            $table: $db.readerBookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readerAnnotationsRefs(
    Expression<bool> Function($$ReaderAnnotationsTableFilterComposer f) f,
  ) {
    final $$ReaderAnnotationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerAnnotations,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderAnnotationsTableFilterComposer(
            $db: $db,
            $table: $db.readerAnnotations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get readingProgress => $composableBuilder(
    column: $table.readingProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDuration => $composableBuilder(
    column: $table.totalDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedBookId => $composableBuilder(
    column: $table.linkedBookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratingCount => $composableBuilder(
    column: $table.ratingCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get narrator =>
      $composableBuilder(column: $table.narrator, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get readingProgress => $composableBuilder(
    column: $table.readingProgress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDuration => $composableBuilder(
    column: $table.totalDuration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedBookId => $composableBuilder(
    column: $table.linkedBookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get ratingCount => $composableBuilder(
    column: $table.ratingCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => column,
  );

  Expression<T> readerProgressRefs<T extends Object>(
    Expression<T> Function($$ReaderProgressTableAnnotationComposer a) f,
  ) {
    final $$ReaderProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerProgress,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.readerProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readerBookmarksRefs<T extends Object>(
    Expression<T> Function($$ReaderBookmarksTableAnnotationComposer a) f,
  ) {
    final $$ReaderBookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerBookmarks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderBookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.readerBookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readerAnnotationsRefs<T extends Object>(
    Expression<T> Function($$ReaderAnnotationsTableAnnotationComposer a) f,
  ) {
    final $$ReaderAnnotationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.readerAnnotations,
          getReferencedColumn: (t) => t.bookId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReaderAnnotationsTableAnnotationComposer(
                $db: $db,
                $table: $db.readerAnnotations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          BookRow,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (BookRow, $$BooksTableReferences),
          BookRow,
          PrefetchHooks Function({
            bool readerProgressRefs,
            bool readerBookmarksRefs,
            bool readerAnnotationsRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> narrator = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<double> readingProgress = const Value.absent(),
                Value<String?> lastPosition = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<int?> totalDuration = const Value.absent(),
                Value<String?> linkedBookId = const Value.absent(),
                Value<String> readingStatus = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> userRating = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int?> ratingCount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                author: author,
                narrator: narrator,
                filePath: filePath,
                coverUrl: coverUrl,
                format: format,
                fileSize: fileSize,
                addedAt: addedAt,
                lastOpenedAt: lastOpenedAt,
                readingProgress: readingProgress,
                lastPosition: lastPosition,
                totalPages: totalPages,
                totalDuration: totalDuration,
                linkedBookId: linkedBookId,
                readingStatus: readingStatus,
                finishedAt: finishedAt,
                userRating: userRating,
                rating: rating,
                ratingCount: ratingCount,
                description: description,
                language: language,
                pageCount: pageCount,
                coverImagePath: coverImagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String author,
                Value<String?> narrator = const Value.absent(),
                required String filePath,
                Value<String?> coverUrl = const Value.absent(),
                required String format,
                Value<int?> fileSize = const Value.absent(),
                required DateTime addedAt,
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<double> readingProgress = const Value.absent(),
                Value<String?> lastPosition = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<int?> totalDuration = const Value.absent(),
                Value<String?> linkedBookId = const Value.absent(),
                Value<String> readingStatus = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> userRating = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int?> ratingCount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                narrator: narrator,
                filePath: filePath,
                coverUrl: coverUrl,
                format: format,
                fileSize: fileSize,
                addedAt: addedAt,
                lastOpenedAt: lastOpenedAt,
                readingProgress: readingProgress,
                lastPosition: lastPosition,
                totalPages: totalPages,
                totalDuration: totalDuration,
                linkedBookId: linkedBookId,
                readingStatus: readingStatus,
                finishedAt: finishedAt,
                userRating: userRating,
                rating: rating,
                ratingCount: ratingCount,
                description: description,
                language: language,
                pageCount: pageCount,
                coverImagePath: coverImagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                readerProgressRefs = false,
                readerBookmarksRefs = false,
                readerAnnotationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (readerProgressRefs) db.readerProgress,
                    if (readerBookmarksRefs) db.readerBookmarks,
                    if (readerAnnotationsRefs) db.readerAnnotations,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (readerProgressRefs)
                        await $_getPrefetchedData<
                          BookRow,
                          $BooksTable,
                          ReaderProgressRow
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readerProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readerProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readerBookmarksRefs)
                        await $_getPrefetchedData<
                          BookRow,
                          $BooksTable,
                          ReaderBookmarkRow
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readerBookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readerBookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readerAnnotationsRefs)
                        await $_getPrefetchedData<
                          BookRow,
                          $BooksTable,
                          ReaderAnnotationRow
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readerAnnotationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readerAnnotationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      BookRow,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (BookRow, $$BooksTableReferences),
      BookRow,
      PrefetchHooks Function({
        bool readerProgressRefs,
        bool readerBookmarksRefs,
        bool readerAnnotationsRefs,
      })
    >;
typedef $$BookChaptersTableCreateCompanionBuilder =
    BookChaptersCompanion Function({
      required String id,
      required String bookId,
      required int position,
      required String filePath,
      Value<String?> title,
      Value<int?> duration,
      Value<int> startOffsetMs,
      Value<int> rowid,
    });
typedef $$BookChaptersTableUpdateCompanionBuilder =
    BookChaptersCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<int> position,
      Value<String> filePath,
      Value<String?> title,
      Value<int?> duration,
      Value<int> startOffsetMs,
      Value<int> rowid,
    });

class $$BookChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOffsetMs => $composableBuilder(
    column: $table.startOffsetMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOffsetMs => $composableBuilder(
    column: $table.startOffsetMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get startOffsetMs => $composableBuilder(
    column: $table.startOffsetMs,
    builder: (column) => column,
  );
}

class $$BookChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookChaptersTable,
          BookChapterRow,
          $$BookChaptersTableFilterComposer,
          $$BookChaptersTableOrderingComposer,
          $$BookChaptersTableAnnotationComposer,
          $$BookChaptersTableCreateCompanionBuilder,
          $$BookChaptersTableUpdateCompanionBuilder,
          (
            BookChapterRow,
            BaseReferences<_$AppDatabase, $BookChaptersTable, BookChapterRow>,
          ),
          BookChapterRow,
          PrefetchHooks Function()
        > {
  $$BookChaptersTableTableManager(_$AppDatabase db, $BookChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int> startOffsetMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookChaptersCompanion(
                id: id,
                bookId: bookId,
                position: position,
                filePath: filePath,
                title: title,
                duration: duration,
                startOffsetMs: startOffsetMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required int position,
                required String filePath,
                Value<String?> title = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int> startOffsetMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookChaptersCompanion.insert(
                id: id,
                bookId: bookId,
                position: position,
                filePath: filePath,
                title: title,
                duration: duration,
                startOffsetMs: startOffsetMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookChaptersTable,
      BookChapterRow,
      $$BookChaptersTableFilterComposer,
      $$BookChaptersTableOrderingComposer,
      $$BookChaptersTableAnnotationComposer,
      $$BookChaptersTableCreateCompanionBuilder,
      $$BookChaptersTableUpdateCompanionBuilder,
      (
        BookChapterRow,
        BaseReferences<_$AppDatabase, $BookChaptersTable, BookChapterRow>,
      ),
      BookChapterRow,
      PrefetchHooks Function()
    >;
typedef $$AudioProgressTableCreateCompanionBuilder =
    AudioProgressCompanion Function({
      required String bookId,
      required int chapterIndex,
      required int positionMs,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AudioProgressTableUpdateCompanionBuilder =
    AudioProgressCompanion Function({
      Value<String> bookId,
      Value<int> chapterIndex,
      Value<int> positionMs,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AudioProgressTableFilterComposer
    extends Composer<_$AppDatabase, $AudioProgressTable> {
  $$AudioProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioProgressTable> {
  $$AudioProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioProgressTable> {
  $$AudioProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AudioProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioProgressTable,
          AudioProgressRow,
          $$AudioProgressTableFilterComposer,
          $$AudioProgressTableOrderingComposer,
          $$AudioProgressTableAnnotationComposer,
          $$AudioProgressTableCreateCompanionBuilder,
          $$AudioProgressTableUpdateCompanionBuilder,
          (
            AudioProgressRow,
            BaseReferences<
              _$AppDatabase,
              $AudioProgressTable,
              AudioProgressRow
            >,
          ),
          AudioProgressRow,
          PrefetchHooks Function()
        > {
  $$AudioProgressTableTableManager(_$AppDatabase db, $AudioProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioProgressCompanion(
                bookId: bookId,
                chapterIndex: chapterIndex,
                positionMs: positionMs,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required int chapterIndex,
                required int positionMs,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AudioProgressCompanion.insert(
                bookId: bookId,
                chapterIndex: chapterIndex,
                positionMs: positionMs,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioProgressTable,
      AudioProgressRow,
      $$AudioProgressTableFilterComposer,
      $$AudioProgressTableOrderingComposer,
      $$AudioProgressTableAnnotationComposer,
      $$AudioProgressTableCreateCompanionBuilder,
      $$AudioProgressTableUpdateCompanionBuilder,
      (
        AudioProgressRow,
        BaseReferences<_$AppDatabase, $AudioProgressTable, AudioProgressRow>,
      ),
      AudioProgressRow,
      PrefetchHooks Function()
    >;
typedef $$AudioBookmarksTableCreateCompanionBuilder =
    AudioBookmarksCompanion Function({
      required String id,
      required String bookId,
      required int chapterIndex,
      required int positionMs,
      required String title,
      required String chapterTitle,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$AudioBookmarksTableUpdateCompanionBuilder =
    AudioBookmarksCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<int> chapterIndex,
      Value<int> positionMs,
      Value<String> title,
      Value<String> chapterTitle,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$AudioBookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $AudioBookmarksTable> {
  $$AudioBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioBookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioBookmarksTable> {
  $$AudioBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioBookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioBookmarksTable> {
  $$AudioBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AudioBookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioBookmarksTable,
          AudioBookmarkRow,
          $$AudioBookmarksTableFilterComposer,
          $$AudioBookmarksTableOrderingComposer,
          $$AudioBookmarksTableAnnotationComposer,
          $$AudioBookmarksTableCreateCompanionBuilder,
          $$AudioBookmarksTableUpdateCompanionBuilder,
          (
            AudioBookmarkRow,
            BaseReferences<
              _$AppDatabase,
              $AudioBookmarksTable,
              AudioBookmarkRow
            >,
          ),
          AudioBookmarkRow,
          PrefetchHooks Function()
        > {
  $$AudioBookmarksTableTableManager(
    _$AppDatabase db,
    $AudioBookmarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioBookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioBookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> chapterTitle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioBookmarksCompanion(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                positionMs: positionMs,
                title: title,
                chapterTitle: chapterTitle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required int chapterIndex,
                required int positionMs,
                required String title,
                required String chapterTitle,
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioBookmarksCompanion.insert(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                positionMs: positionMs,
                title: title,
                chapterTitle: chapterTitle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioBookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioBookmarksTable,
      AudioBookmarkRow,
      $$AudioBookmarksTableFilterComposer,
      $$AudioBookmarksTableOrderingComposer,
      $$AudioBookmarksTableAnnotationComposer,
      $$AudioBookmarksTableCreateCompanionBuilder,
      $$AudioBookmarksTableUpdateCompanionBuilder,
      (
        AudioBookmarkRow,
        BaseReferences<_$AppDatabase, $AudioBookmarksTable, AudioBookmarkRow>,
      ),
      AudioBookmarkRow,
      PrefetchHooks Function()
    >;
typedef $$ReaderProgressTableCreateCompanionBuilder =
    ReaderProgressCompanion Function({
      required String bookId,
      required int charOffset,
      Value<int?> chapterIndex,
      required double percent,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ReaderProgressTableUpdateCompanionBuilder =
    ReaderProgressCompanion Function({
      Value<String> bookId,
      Value<int> charOffset,
      Value<int?> chapterIndex,
      Value<double> percent,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ReaderProgressTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReaderProgressTable, ReaderProgressRow> {
  $$ReaderProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.readerProgress.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReaderProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderProgressTable> {
  $$ReaderProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get charOffset => $composableBuilder(
    column: $table.charOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderProgressTable> {
  $$ReaderProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get charOffset => $composableBuilder(
    column: $table.charOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderProgressTable> {
  $$ReaderProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get charOffset => $composableBuilder(
    column: $table.charOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get percent =>
      $composableBuilder(column: $table.percent, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderProgressTable,
          ReaderProgressRow,
          $$ReaderProgressTableFilterComposer,
          $$ReaderProgressTableOrderingComposer,
          $$ReaderProgressTableAnnotationComposer,
          $$ReaderProgressTableCreateCompanionBuilder,
          $$ReaderProgressTableUpdateCompanionBuilder,
          (ReaderProgressRow, $$ReaderProgressTableReferences),
          ReaderProgressRow,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReaderProgressTableTableManager(
    _$AppDatabase db,
    $ReaderProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<int> charOffset = const Value.absent(),
                Value<int?> chapterIndex = const Value.absent(),
                Value<double> percent = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReaderProgressCompanion(
                bookId: bookId,
                charOffset: charOffset,
                chapterIndex: chapterIndex,
                percent: percent,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required int charOffset,
                Value<int?> chapterIndex = const Value.absent(),
                required double percent,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReaderProgressCompanion.insert(
                bookId: bookId,
                charOffset: charOffset,
                chapterIndex: chapterIndex,
                percent: percent,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReaderProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$ReaderProgressTableReferences
                                    ._bookIdTable(db),
                                referencedColumn:
                                    $$ReaderProgressTableReferences
                                        ._bookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReaderProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderProgressTable,
      ReaderProgressRow,
      $$ReaderProgressTableFilterComposer,
      $$ReaderProgressTableOrderingComposer,
      $$ReaderProgressTableAnnotationComposer,
      $$ReaderProgressTableCreateCompanionBuilder,
      $$ReaderProgressTableUpdateCompanionBuilder,
      (ReaderProgressRow, $$ReaderProgressTableReferences),
      ReaderProgressRow,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ReaderBookmarksTableCreateCompanionBuilder =
    ReaderBookmarksCompanion Function({
      required String id,
      required String bookId,
      required int charOffset,
      Value<int?> chapterIndex,
      required String previewText,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ReaderBookmarksTableUpdateCompanionBuilder =
    ReaderBookmarksCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<int> charOffset,
      Value<int?> chapterIndex,
      Value<String> previewText,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ReaderBookmarksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReaderBookmarksTable,
          ReaderBookmarkRow
        > {
  $$ReaderBookmarksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.readerBookmarks.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReaderBookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderBookmarksTable> {
  $$ReaderBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charOffset => $composableBuilder(
    column: $table.charOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previewText => $composableBuilder(
    column: $table.previewText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderBookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderBookmarksTable> {
  $$ReaderBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charOffset => $composableBuilder(
    column: $table.charOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previewText => $composableBuilder(
    column: $table.previewText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderBookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderBookmarksTable> {
  $$ReaderBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get charOffset => $composableBuilder(
    column: $table.charOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previewText => $composableBuilder(
    column: $table.previewText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderBookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderBookmarksTable,
          ReaderBookmarkRow,
          $$ReaderBookmarksTableFilterComposer,
          $$ReaderBookmarksTableOrderingComposer,
          $$ReaderBookmarksTableAnnotationComposer,
          $$ReaderBookmarksTableCreateCompanionBuilder,
          $$ReaderBookmarksTableUpdateCompanionBuilder,
          (ReaderBookmarkRow, $$ReaderBookmarksTableReferences),
          ReaderBookmarkRow,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReaderBookmarksTableTableManager(
    _$AppDatabase db,
    $ReaderBookmarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderBookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderBookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> charOffset = const Value.absent(),
                Value<int?> chapterIndex = const Value.absent(),
                Value<String> previewText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReaderBookmarksCompanion(
                id: id,
                bookId: bookId,
                charOffset: charOffset,
                chapterIndex: chapterIndex,
                previewText: previewText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required int charOffset,
                Value<int?> chapterIndex = const Value.absent(),
                required String previewText,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReaderBookmarksCompanion.insert(
                id: id,
                bookId: bookId,
                charOffset: charOffset,
                chapterIndex: chapterIndex,
                previewText: previewText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReaderBookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable:
                                    $$ReaderBookmarksTableReferences
                                        ._bookIdTable(db),
                                referencedColumn:
                                    $$ReaderBookmarksTableReferences
                                        ._bookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReaderBookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderBookmarksTable,
      ReaderBookmarkRow,
      $$ReaderBookmarksTableFilterComposer,
      $$ReaderBookmarksTableOrderingComposer,
      $$ReaderBookmarksTableAnnotationComposer,
      $$ReaderBookmarksTableCreateCompanionBuilder,
      $$ReaderBookmarksTableUpdateCompanionBuilder,
      (ReaderBookmarkRow, $$ReaderBookmarksTableReferences),
      ReaderBookmarkRow,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ReaderAnnotationsTableCreateCompanionBuilder =
    ReaderAnnotationsCompanion Function({
      required String id,
      required String bookId,
      required int type,
      required int charStart,
      required int charEnd,
      Value<int?> chapterIndex,
      required String body,
      Value<String?> noteText,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ReaderAnnotationsTableUpdateCompanionBuilder =
    ReaderAnnotationsCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<int> type,
      Value<int> charStart,
      Value<int> charEnd,
      Value<int?> chapterIndex,
      Value<String> body,
      Value<String?> noteText,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ReaderAnnotationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReaderAnnotationsTable,
          ReaderAnnotationRow
        > {
  $$ReaderAnnotationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.readerAnnotations.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReaderAnnotationsTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderAnnotationsTable> {
  $$ReaderAnnotationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charStart => $composableBuilder(
    column: $table.charStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charEnd => $composableBuilder(
    column: $table.charEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderAnnotationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderAnnotationsTable> {
  $$ReaderAnnotationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charStart => $composableBuilder(
    column: $table.charStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charEnd => $composableBuilder(
    column: $table.charEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderAnnotationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderAnnotationsTable> {
  $$ReaderAnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get charStart =>
      $composableBuilder(column: $table.charStart, builder: (column) => column);

  GeneratedColumn<int> get charEnd =>
      $composableBuilder(column: $table.charEnd, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get noteText =>
      $composableBuilder(column: $table.noteText, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderAnnotationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderAnnotationsTable,
          ReaderAnnotationRow,
          $$ReaderAnnotationsTableFilterComposer,
          $$ReaderAnnotationsTableOrderingComposer,
          $$ReaderAnnotationsTableAnnotationComposer,
          $$ReaderAnnotationsTableCreateCompanionBuilder,
          $$ReaderAnnotationsTableUpdateCompanionBuilder,
          (ReaderAnnotationRow, $$ReaderAnnotationsTableReferences),
          ReaderAnnotationRow,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReaderAnnotationsTableTableManager(
    _$AppDatabase db,
    $ReaderAnnotationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderAnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderAnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderAnnotationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> charStart = const Value.absent(),
                Value<int> charEnd = const Value.absent(),
                Value<int?> chapterIndex = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> noteText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReaderAnnotationsCompanion(
                id: id,
                bookId: bookId,
                type: type,
                charStart: charStart,
                charEnd: charEnd,
                chapterIndex: chapterIndex,
                body: body,
                noteText: noteText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required int type,
                required int charStart,
                required int charEnd,
                Value<int?> chapterIndex = const Value.absent(),
                required String body,
                Value<String?> noteText = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReaderAnnotationsCompanion.insert(
                id: id,
                bookId: bookId,
                type: type,
                charStart: charStart,
                charEnd: charEnd,
                chapterIndex: chapterIndex,
                body: body,
                noteText: noteText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReaderAnnotationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable:
                                    $$ReaderAnnotationsTableReferences
                                        ._bookIdTable(db),
                                referencedColumn:
                                    $$ReaderAnnotationsTableReferences
                                        ._bookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReaderAnnotationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderAnnotationsTable,
      ReaderAnnotationRow,
      $$ReaderAnnotationsTableFilterComposer,
      $$ReaderAnnotationsTableOrderingComposer,
      $$ReaderAnnotationsTableAnnotationComposer,
      $$ReaderAnnotationsTableCreateCompanionBuilder,
      $$ReaderAnnotationsTableUpdateCompanionBuilder,
      (ReaderAnnotationRow, $$ReaderAnnotationsTableReferences),
      ReaderAnnotationRow,
      PrefetchHooks Function({bool bookId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookChaptersTableTableManager get bookChapters =>
      $$BookChaptersTableTableManager(_db, _db.bookChapters);
  $$AudioProgressTableTableManager get audioProgress =>
      $$AudioProgressTableTableManager(_db, _db.audioProgress);
  $$AudioBookmarksTableTableManager get audioBookmarks =>
      $$AudioBookmarksTableTableManager(_db, _db.audioBookmarks);
  $$ReaderProgressTableTableManager get readerProgress =>
      $$ReaderProgressTableTableManager(_db, _db.readerProgress);
  $$ReaderBookmarksTableTableManager get readerBookmarks =>
      $$ReaderBookmarksTableTableManager(_db, _db.readerBookmarks);
  $$ReaderAnnotationsTableTableManager get readerAnnotations =>
      $$ReaderAnnotationsTableTableManager(_db, _db.readerAnnotations);
}
