/// Minimal RFC-4180-ish CSV serialization. Kept tiny and dependency-free.
class CsvWriter {
  CsvWriter._();

  /// Renders [rows] (the first should be headers) as a CSV string.
  static String toCsv(List<List<Object?>> rows) {
    return rows.map(_row).join('\r\n');
  }

  static String _row(List<Object?> cells) => cells.map(_cell).join(',');

  static String _cell(Object? value) {
    if (value == null) return '';
    final s = value.toString();
    final needsQuote =
        s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r');
    if (!needsQuote) return s;
    final escaped = s.replaceAll('"', '""');
    return '"$escaped"';
  }
}
