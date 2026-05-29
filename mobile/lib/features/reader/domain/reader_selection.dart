/// Выделение текста пользователем.
///
/// Геометрия для позиционирования контекстного меню в domain НЕ хранится —
/// это решается в presentation (задача D1), по-разному на каждый движок.
class ReaderSelection {
  const ReaderSelection({required this.text, required this.anchor});

  final String text;

  /// Непрозрачный якорь диапазона выделения.
  final String anchor;
}
