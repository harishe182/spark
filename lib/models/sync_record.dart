import 'db_codec.dart';

/// Cloud-sync status for one session. Tracked locally so the app is the source
/// of truth for what still needs uploading — uploads are best-effort and
/// Wi-Fi-gated, so a durable queue is required.
enum SyncStatus {
  pending('pending'),
  synced('synced'),
  failed('failed');

  const SyncStatus(this.value);
  final String value;

  static SyncStatus fromValue(String value) => SyncStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => throw ArgumentError('Unknown SyncStatus: $value'),
      );
}

class SyncRecord {
  const SyncRecord({
    required this.sessionId,
    required this.status,
    required this.updatedAt,
    this.error,
  });

  final String sessionId;
  final SyncStatus status;
  final DateTime updatedAt;
  final String? error;

  SyncRecord copyWith({
    SyncStatus? status,
    DateTime? updatedAt,
    String? error,
  }) {
    return SyncRecord(
      sessionId: sessionId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      error: error,
    );
  }

  Map<String, Object?> toMap() => {
        'session_id': sessionId,
        'status': status.value,
        'updated_at': DbCodec.dateToString(updatedAt),
        'error': error,
      };

  factory SyncRecord.fromMap(Map<String, Object?> map) => SyncRecord(
        sessionId: map['session_id']! as String,
        status: SyncStatus.fromValue(map['status']! as String),
        updatedAt: DbCodec.stringToDate(map['updated_at'])!,
        error: map['error'] as String?,
      );

  static const String tableName = 'sync_records';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      session_id TEXT PRIMARY KEY,
      status TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      error TEXT,
      FOREIGN KEY (session_id) REFERENCES sessions(session_id)
    )
  ''';
}
