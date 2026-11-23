import '../core/enums.dart';
import 'db_codec.dart';

/// A single Spark suggestion shown to the child and its outcome. Logged for
/// both conditions identically so acceptance rate, reliance, and timing can
/// be compared. [condition] is stored redundantly alongside [sparkType] to
/// make the export self-auditing.
class SparkEvent {
  const SparkEvent({
    required this.eventId,
    required this.sessionId,
    required this.phaseId,
    required this.condition,
    required this.sparkType,
    required this.suggestionText,
    required this.suggestionSourceId,
    required this.shownAt,
    this.response = SparkResponse.noResponse,
    this.respondedAt,
    this.addedToIdeaList = false,
  });

  final String eventId;
  final String sessionId;
  final String? phaseId;
  final StudyCondition condition;
  final SparkType sparkType;
  final String suggestionText;

  /// UUID of the AI generation, or the static-bank entry id/index.
  final String suggestionSourceId;
  final DateTime shownAt;
  final SparkResponse response;
  final DateTime? respondedAt;
  final bool addedToIdeaList;

  SparkEvent copyWith({
    String? eventId,
    String? sessionId,
    String? phaseId,
    StudyCondition? condition,
    SparkType? sparkType,
    String? suggestionText,
    String? suggestionSourceId,
    DateTime? shownAt,
    SparkResponse? response,
    DateTime? respondedAt,
    bool? addedToIdeaList,
  }) {
    return SparkEvent(
      eventId: eventId ?? this.eventId,
      sessionId: sessionId ?? this.sessionId,
      phaseId: phaseId ?? this.phaseId,
      condition: condition ?? this.condition,
      sparkType: sparkType ?? this.sparkType,
      suggestionText: suggestionText ?? this.suggestionText,
      suggestionSourceId: suggestionSourceId ?? this.suggestionSourceId,
      shownAt: shownAt ?? this.shownAt,
      response: response ?? this.response,
      respondedAt: respondedAt ?? this.respondedAt,
      addedToIdeaList: addedToIdeaList ?? this.addedToIdeaList,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'event_id': eventId,
      'session_id': sessionId,
      'phase_id': phaseId,
      'condition': condition.value,
      'spark_type': sparkType.value,
      'suggestion_text': suggestionText,
      'suggestion_source_id': suggestionSourceId,
      'shown_at': DbCodec.dateToString(shownAt),
      'response': response.value,
      'responded_at': DbCodec.dateToString(respondedAt),
      'added_to_idea_list': DbCodec.boolToInt(addedToIdeaList),
    };
  }

  factory SparkEvent.fromMap(Map<String, Object?> map) {
    return SparkEvent(
      eventId: map['event_id']! as String,
      sessionId: map['session_id']! as String,
      phaseId: map['phase_id'] as String?,
      condition: StudyCondition.fromValue(map['condition']! as String),
      sparkType: SparkType.fromValue(map['spark_type']! as String),
      suggestionText: map['suggestion_text']! as String,
      suggestionSourceId: map['suggestion_source_id']! as String,
      shownAt: DbCodec.stringToDate(map['shown_at'])!,
      response: SparkResponse.fromValue(map['response']! as String),
      respondedAt: DbCodec.stringToDate(map['responded_at']),
      addedToIdeaList: DbCodec.intToBool(map['added_to_idea_list']),
    );
  }

  static const String tableName = 'spark_events';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      event_id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      phase_id TEXT,
      condition TEXT NOT NULL,
      spark_type TEXT NOT NULL,
      suggestion_text TEXT NOT NULL,
      suggestion_source_id TEXT NOT NULL,
      shown_at TEXT NOT NULL,
      response TEXT NOT NULL,
      responded_at TEXT,
      added_to_idea_list INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (session_id) REFERENCES sessions(session_id),
      FOREIGN KEY (phase_id) REFERENCES phases(phase_id)
    )
  ''';
}
