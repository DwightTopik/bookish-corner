enum BookFormat {
  epub,
  fb2,
  pdf,
  txt,
  mp3,
  m4b,
  audioFolder;

  bool get isAudio => this == .mp3 || this == .m4b || this == .audioFolder;

  String get label => switch (this) {
    .audioFolder => 'АУДИО',
    _ => name.toUpperCase(),
  };

  static const List<String> pickerExtensions = [
    'epub',
    'fb2',
    'pdf',
    'txt',
    'mp3',
    'm4b',
  ];

  static BookFormat? fromExtension(String extension) {
    final normalized = extension.toLowerCase().replaceFirst('.', '').trim();
    for (final format in BookFormat.values) {
      if (format.name == normalized) return format;
    }
    return null;
  }
}
