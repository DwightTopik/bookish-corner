import 'package:bookish_corner/features/book_details/domain/book_details_metadata.dart';

class InfoTxtMetadataParser {
  const InfoTxtMetadataParser();

  BookDetailsMetadata parse(String content) {
    final fields = <String, String>{};
    final categories = <String>[];
    final tocItems = <String>{}.toList();
    String? activeKey;
    bool inToc = false;

    for (final rawLine in content.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();

      if (line.isEmpty) {
        if (activeKey == 'description') {
          fields['description'] = _append(fields['description'], '');
        }
        continue;
      }

      final headerKey = _mapKey(_stripTrailingSeparator(line));
      if (headerKey != null && !_hasInlineValue(line)) {
        inToc = headerKey == 'toc';
        activeKey = switch (headerKey) {
          'description' => 'description',
          'toc' || 'details' => null,
          _ => headerKey,
        };
        continue;
      }

      final pair = _splitPair(line);
      if (pair != null) {
        final key = _mapKey(pair.key);
        if (key != null) {
          final value = _cleanValueForKey(key, pair.value);
          inToc = key == 'toc';
          activeKey = switch (key) {
            'description' => 'description',
            _ when value.isEmpty && _singleValueKeys.contains(key) => key,
            _ => null,
          };
          if (value.isEmpty) continue;
          if (key == 'toc') {
            tocItems.add(value);
          } else if (key == 'categories') {
            categories.addAll(_splitValues(value));
          } else if (key != 'details') {
            fields[key] = _append(fields[key], value);
          }
          continue;
        }
      }

      if (inToc) {
        tocItems.add(_stripListMarker(line));
      } else if (activeKey == 'description') {
        fields['description'] = _append(fields['description'], line);
      } else if (activeKey != null && _singleValueKeys.contains(activeKey)) {
        fields[activeKey] = _append(
          fields[activeKey],
          _cleanValueForKey(activeKey, line),
        );
        activeKey = null;
      }
    }

    return BookDetailsMetadata(
      title: fields['title'],
      author: fields['author'],
      series: fields['series'],
      description: _normalizeMultiline(fields['description']),
      categories: _uniqueMeaningful(categories),
      ageRestriction: _emptyAsNull(fields['ageRestriction']),
      publishedDate: _emptyAsNull(fields['publishedDate']),
      writtenDate: _emptyAsNull(fields['writtenDate']),
      isbn: _emptyAsNull(fields['isbn']),
      translator: _emptyAsNull(fields['translator']),
      narrator: _emptyAsNull(fields['narrator']),
      duration: _emptyAsNull(fields['duration']),
      publisher: _emptyAsNull(fields['publisher']),
      rightHolder: _emptyAsNull(fields['rightHolder']),
      tableOfContents: tocItems
          .map(_stripListMarker)
          .where((value) => value.isNotEmpty)
          .toList(),
    );
  }

  _Pair? _splitPair(String line) {
    final match = RegExp(
      r'^([^:=：—-]{2,60})\s*[:=：—-]\s*(.*)$',
    ).firstMatch(line);
    if (match == null) return null;
    return _Pair(match.group(1) ?? '', match.group(2) ?? '');
  }

  bool _hasInlineValue(String line) {
    final pair = _splitPair(line);
    return pair != null && pair.value.trim().isNotEmpty;
  }

  String _stripTrailingSeparator(String value) {
    return value.replaceFirst(RegExp(r'\s*[:=：—-]\s*$'), '');
  }

  String? _mapKey(String raw) {
    final key = _normalizeKey(raw);
    if (_titleKeys.contains(key)) return 'title';
    if (_authorKeys.contains(key)) return 'author';
    if (_seriesKeys.contains(key)) return 'series';
    if (_descriptionKeys.contains(key)) return 'description';
    if (_detailsKeys.contains(key)) return 'details';
    if (_categoryKeys.contains(key)) return 'categories';
    if (_ageKeys.contains(key)) return 'ageRestriction';
    if (_publishedKeys.contains(key)) return 'publishedDate';
    if (_writtenKeys.contains(key)) return 'writtenDate';
    if (_isbnKeys.contains(key)) return 'isbn';
    if (_translatorKeys.contains(key)) return 'translator';
    if (_narratorKeys.contains(key)) return 'narrator';
    if (_durationKeys.contains(key)) return 'duration';
    if (_publisherKeys.contains(key)) return 'publisher';
    if (_rightHolderKeys.contains(key)) return 'rightHolder';
    if (_tocKeys.contains(key)) return 'toc';
    return null;
  }

  String _append(String? previous, String next) {
    final value = next.trimRight();
    if (previous == null || previous.trim().isEmpty) return value.trimLeft();
    if (value.trim().isEmpty) {
      return previous.endsWith('\n\n') ? previous : '$previous\n\n';
    }
    if (previous.endsWith('\n\n')) return '$previous$value';
    return '${previous.trimRight()}\n$value';
  }

  List<String> _splitValues(String value) {
    return value
        .split(RegExp(r'[,;/|]'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  List<String> _uniqueMeaningful(List<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final cleaned = _cleanupPlainValue(value);
      if (cleaned == null) continue;
      final key = cleaned.toLowerCase();
      if (seen.add(key)) result.add(cleaned);
    }
    return result;
  }

  String _stripListMarker(String value) {
    return value.replaceFirst(RegExp(r'^\s*(?:[-*•]|\d+[.)])\s*'), '').trim();
  }

  String? _normalizeMultiline(String? value) {
    final normalized = value
        ?.replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String _cleanValueForKey(String key, String rawValue) {
    final truncated = _truncateAtEmbeddedLabel(rawValue).trim();
    if (truncated.isEmpty) return '';
    return switch (key) {
      'ageRestriction' => _normalizeAge(truncated),
      'publishedDate' || 'writtenDate' => _normalizeDate(truncated),
      'isbn' => _normalizeIsbn(truncated),
      'duration' => _dedupeLines(truncated),
      _ => _cleanupPlainValue(truncated) ?? '',
    };
  }

  String _truncateAtEmbeddedLabel(String value) {
    final matches = _embeddedLabelPattern
        .allMatches(value)
        .where((match) => match.start > 0);
    final first = matches.isEmpty
        ? null
        : matches.reduce((a, b) => a.start < b.start ? a : b);
    if (first == null) return value;
    return value.substring(0, first.start).trimRight();
  }

  String _normalizeAge(String value) {
    final match = RegExp(r'\b(\d{1,2})\s*\+').firstMatch(value);
    if (match != null) return '${match.group(1)}+';
    return _cleanupPlainValue(value) ?? '';
  }

  String _normalizeDate(String value) {
    final match = RegExp(r'\b\d{4}(?:\s*[-–—]\s*\d{4})?\b').firstMatch(value);
    if (match != null) {
      return match.group(0)!.replaceAll(RegExp(r'\s*[-–—]\s*'), '-');
    }
    return _cleanupPlainValue(value) ?? '';
  }

  String _normalizeIsbn(String value) {
    final candidate = value.replaceAll(RegExp(r'[^0-9Xx-]'), '');
    final digits = candidate.replaceAll('-', '');
    if (digits.length == 10 || digits.length == 13) return digits;
    return _cleanupPlainValue(value) ?? '';
  }

  String _dedupeLines(String value) {
    final seen = <String>{};
    final parts = value
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);
    final unique = <String>[];
    for (final part in parts) {
      final key = part.toLowerCase();
      if (seen.add(key)) unique.add(part);
    }
    return unique.join('\n');
  }

  String? _cleanupPlainValue(String? value) {
    final cleaned = _dedupeLines(value ?? '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\s:;,\-–—]+|[\s:;,]+$'), '')
        .trim();
    if (cleaned.isEmpty || _placeholderValues.contains(cleaned.toLowerCase())) {
      return null;
    }
    return cleaned;
  }

  String? _emptyAsNull(String? value) => _cleanupPlainValue(value);

  String _normalizeKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ё', 'е')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static const _singleValueKeys = {
    'title',
    'author',
    'series',
    'ageRestriction',
    'publishedDate',
    'writtenDate',
    'isbn',
    'translator',
    'narrator',
    'duration',
    'publisher',
    'rightHolder',
  };

  static const _titleKeys = {'title', 'название', 'книга', 'название книги'};
  static const _authorKeys = {'author', 'authors', 'автор', 'авторы'};
  static const _seriesKeys = {
    'series',
    'серия',
    'из серии',
    'цикл',
    'из цикла',
  };
  static const _descriptionKeys = {
    'description',
    'annotation',
    'описание',
    'описание книги',
    'аннотация',
    'аннотация к книге',
  };
  static const _detailsKeys = {
    'details',
    'detailed information',
    'подробная информация',
    'информация',
    'информация о книге',
  };
  static const _categoryKeys = {
    'genre',
    'genres',
    'category',
    'categories',
    'жанр',
    'жанры',
    'категория',
    'категории',
  };
  static const _ageKeys = {
    'age',
    'age restriction',
    'возраст',
    'возрастное ограничение',
    'ограничение',
  };
  static const _publishedKeys = {
    'release date',
    'published date',
    'publication date',
    'дата выхода',
    'дата публикации',
    'дата издания',
    'год издания',
    'издано',
  };
  static const _writtenKeys = {
    'written date',
    'дата написания',
    'год написания',
    'написано',
  };
  static const _isbnKeys = {'isbn', 'исбн'};
  static const _translatorKeys = {'translator', 'переводчик', 'перевод'};
  static const _narratorKeys = {
    'narrator',
    'reader',
    'read by',
    'исполнитель',
    'исполнитель аудиокниги',
    'чтец',
    'читает',
    'диктор',
  };
  static const _durationKeys = {
    'duration',
    'длительность',
    'продолжительность',
    'время звучания',
  };
  static const _publisherKeys = {'publisher', 'издатель', 'издательство'};
  static const _rightHolderKeys = {
    'right holder',
    'rights holder',
    'copyright',
    'правообладатель',
    'правообладатели',
  };
  static const _tocKeys = {
    'toc',
    'contents',
    'table of contents',
    'содержание',
    'оглавление',
  };

  static final _embeddedLabelPattern = RegExp(
    r'\s(?:'
    r'Дата выхода на ЛитРес|Дата выхода|Дата публикации|Дата издания|'
    r'Дата написания|Год написания|ISBN|ИСБН|Переводчик|Перевод|'
    r'Чтец|Исполнитель|Читает|Диктор|Правообладатель|Правообладатели|'
    r'Издательство|Издатель|Жанр|Жанры|Описание|Описание книги|'
    r'Аннотация|Подробная информация|Оглавление|Содержание|Длительность|'
    r'Продолжительность|Возрастное ограничение|Возраст'
    r')\s*[:=：—-]',
    caseSensitive: false,
    unicode: true,
  );

  static const _placeholderValues = {
    'unknown',
    'null',
    'absent',
    'not specified',
    'неизвестно',
    'не указано',
    'нет',
    '-',
  };
}

class _Pair {
  const _Pair(this.key, this.value);

  final String key;
  final String value;
}
