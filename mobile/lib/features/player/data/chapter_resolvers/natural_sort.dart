int naturalCompare(String a, String b) {
  final ax = _tokenize(a);
  final bx = _tokenize(b);
  final n = ax.length < bx.length ? ax.length : bx.length;
  for (int i = 0; i < n; i++) {
    final ai = ax[i];
    final bi = bx[i];
    if (ai is int && bi is int) {
      final cmp = ai.compareTo(bi);
      if (cmp != 0) return cmp;
    } else {
      final cmp = ai.toString().toLowerCase().compareTo(
        bi.toString().toLowerCase(),
      );
      if (cmp != 0) return cmp;
    }
  }
  return ax.length.compareTo(bx.length);
}

List<Object> _tokenize(String s) {
  final out = <Object>[];
  final buf = StringBuffer();
  bool inDigits = false;
  for (int i = 0; i < s.length; i++) {
    final ch = s[i];
    final isDigit = ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39;
    if (isDigit != inDigits && buf.isNotEmpty) {
      out.add(inDigits ? int.parse(buf.toString()) : buf.toString());
      buf.clear();
    }
    inDigits = isDigit;
    buf.write(ch);
  }
  if (buf.isNotEmpty) {
    out.add(inDigits ? int.parse(buf.toString()) : buf.toString());
  }
  return out;
}
