import '../core/enums.dart';
import 'db_codec.dart';

/// A single sitting for a participant: a pre-test, one of 10 weekly sessions,
/// or a post-test. [weekNumber] is null for pre/post tests and 1–10 for
/// weekly sessions.
class Session {
  const Session({
    required this.sessionId,
    required this.participantId,
    required this.mode,
    required this.weekNumber,
    required this.promptId,
    required this.startTime,
    required this.endTime,
    required this.completionStatus,
    this.facilitatorOverrideCount = 0,
  });

  final String sessionId;
  final String participantId;
  final SessionMode mode;
  final int? weekNumber;
  final String? promptId;
  final DateTime startTime;
  final DateTime? endTime;
  final CompletionStatus completionStatus;
  final int facilitatorOverrideCount;

  Session copyWith({
    String? sessionId,
    String? participantId,
    SessionMode? mode,
    int? weekNumber,
    String? promptId,
    DateTime? startTime,
    DateTime? endTime,
    CompletionStatus? completionStatus,
    int? facilitatorOverrideCount,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      participantId: participantId ?? this.participantId,
      mode: mode ?? this.mode,
      weekNumber: weekNumber ?? this.weekNumber,
      promptId: promptId ?? this.promptId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completionStatus: completionStatus ?? this.completionStatus,
      facilitatorOverrideCount:
          facilitatorOverrideCount ?? this.facilitatorOverrideCount,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'session_id': sessionId,
      'participant_id': participantId,
      'mode': mode.value,
      'week_number': weekNumber,
      'prompt_id': promptId,
      'start_time': DbCodec.dateToString(startTime),
      'end_time': DbCodec.dateToString(endTime),
      'completion_status': completionStatus.value,
      'facilitator_override_count': facilitatorOverrideCount,
    };
  }

  factory Session.fromMap(Map<String, Object?> map) {
    return Session(
      sessionId: map['session_id']! as String,
      participantId: map['participant_id']! as String,
      mode: SessionMode.fromValue(map['mode']! as String),
      weekNumber: map['week_number'] as int?,
      promptId: map['prompt_id'] as String?,
      startTime: DbCodec.stringToDate(map['start_time'])!,
      endTime: DbCodec.stringToDate(map['end_time']),
      completionStatus:
          CompletionStatus.fromValue(map['completion_status']! as String),
      facilitatorOverrideCount:
          (map['facilitator_override_count'] as int?) ?? 0,
    );
  }

  static const String tableName = 'sessions';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      session_id TEXT PRIMARY KEY,
      participant_id TEXT NOT NULL,
      mode TEXT NOT NULL,
      week_number INTEGER,
      prompt_id TEXT,
      start_time TEXT NOT NULL,
      end_time TEXT,
      completion_status TEXT NOT NULL,
      facilitator_override_count INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (participant_id) REFERENCES participants(participant_id)
    )
  ''';
}
