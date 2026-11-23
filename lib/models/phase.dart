import '../core/enums.dart';
import 'db_codec.dart';

/// A timed phase within a [Session]. Durations are derived on completion so
/// researchers can analyze time-on-task per phase.
class Phase {
  const Phase({
    required this.phaseId,
    required this.sessionId,
    required this.phaseType,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
  });

  final String phaseId;
  final String sessionId;
  final PhaseType phaseType;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationSeconds;

  Phase copyWith({
    String? phaseId,
    String? sessionId,
    PhaseType? phaseType,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
  }) {
    return Phase(
      phaseId: phaseId ?? this.phaseId,
      sessionId: sessionId ?? this.sessionId,
      phaseType: phaseType ?? this.phaseType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  /// Returns a completed copy with [endTime] set and duration computed.
  Phase complete(DateTime when) {
    return copyWith(
      endTime: when,
      durationSeconds: when.difference(startTime).inSeconds,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'phase_id': phaseId,
      'session_id': sessionId,
      'phase_type': phaseType.value,
      'start_time': DbCodec.dateToString(startTime),
      'end_time': DbCodec.dateToString(endTime),
      'duration_seconds': durationSeconds,
    };
  }

  factory Phase.fromMap(Map<String, Object?> map) {
    return Phase(
      phaseId: map['phase_id']! as String,
      sessionId: map['session_id']! as String,
      phaseType: PhaseType.fromValue(map['phase_type']! as String),
      startTime: DbCodec.stringToDate(map['start_time'])!,
      endTime: DbCodec.stringToDate(map['end_time']),
      durationSeconds: map['duration_seconds'] as int?,
    );
  }

  static const String tableName = 'phases';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      phase_id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      phase_type TEXT NOT NULL,
      start_time TEXT NOT NULL,
      end_time TEXT,
      duration_seconds INTEGER,
      FOREIGN KEY (session_id) REFERENCES sessions(session_id)
    )
  ''';
}
