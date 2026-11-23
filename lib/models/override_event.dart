import 'db_codec.dart';

/// Audit record of a facilitator manually overriding session flow — e.g.
/// advancing a phase early or extending it. Research integrity requires every
/// such override to be logged with a timestamp (study requirement).
class OverrideEvent {
  const OverrideEvent({
    required this.overrideId,
    required this.sessionId,
    required this.phaseId,
    required this.action,
    required this.createdAt,
    this.detail,
  });

  final String overrideId;
  final String sessionId;
  final String? phaseId;

  /// Short machine-readable action, e.g. "advance_phase", "extend_phase".
  final String action;
  final String? detail;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'override_id': overrideId,
      'session_id': sessionId,
      'phase_id': phaseId,
      'action': action,
      'detail': detail,
      'created_at': DbCodec.dateToString(createdAt),
    };
  }

  factory OverrideEvent.fromMap(Map<String, Object?> map) {
    return OverrideEvent(
      overrideId: map['override_id']! as String,
      sessionId: map['session_id']! as String,
      phaseId: map['phase_id'] as String?,
      action: map['action']! as String,
      detail: map['detail'] as String?,
      createdAt: DbCodec.stringToDate(map['created_at'])!,
    );
  }

  static const String tableName = 'override_events';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      override_id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      phase_id TEXT,
      action TEXT NOT NULL,
      detail TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (session_id) REFERENCES sessions(session_id)
    )
  ''';
}
