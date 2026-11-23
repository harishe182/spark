/// Helpers for converting between Dart types and SQLite column values.
///
/// SQLite has no native bool or DateTime, so we standardize encoding here:
/// bools as 0/1 integers, DateTimes as ISO-8601 UTC strings. Centralizing
/// this avoids subtle per-model inconsistencies in stored/exported data.
library;

class DbCodec {
  DbCodec._();

  static int boolToInt(bool value) => value ? 1 : 0;

  static bool intToBool(Object? value) => value == 1 || value == true;

  /// Encodes a [DateTime] as an ISO-8601 UTC string, or null.
  static String? dateToString(DateTime? value) =>
      value?.toUtc().toIso8601String();

  /// Parses an ISO-8601 string back to a local-zone [DateTime], or null.
  static DateTime? stringToDate(Object? value) {
    if (value == null || value is! String || value.isEmpty) return null;
    return DateTime.parse(value).toLocal();
  }
}
