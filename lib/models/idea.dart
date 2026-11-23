import '../core/enums.dart';
import 'db_codec.dart';

/// One entry in a child's idea list. [source] records whether the child
/// authored it or it came from an accepted Spark suggestion — central to
/// analyzing Spark reliance and whether accepted hints reach the final idea.
class Idea {
  const Idea({
    required this.ideaId,
    required this.sessionId,
    required this.phaseId,
    required this.ideaText,
    required this.source,
    required this.createdAt,
    this.selectedForFinal = false,
  });

  final String ideaId;
  final String sessionId;
  final String? phaseId;
  final String ideaText;
  final IdeaSource source;
  final DateTime createdAt;
  final bool selectedForFinal;

  Idea copyWith({
    String? ideaId,
    String? sessionId,
    String? phaseId,
    String? ideaText,
    IdeaSource? source,
    DateTime? createdAt,
    bool? selectedForFinal,
  }) {
    return Idea(
      ideaId: ideaId ?? this.ideaId,
      sessionId: sessionId ?? this.sessionId,
      phaseId: phaseId ?? this.phaseId,
      ideaText: ideaText ?? this.ideaText,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      selectedForFinal: selectedForFinal ?? this.selectedForFinal,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'idea_id': ideaId,
      'session_id': sessionId,
      'phase_id': phaseId,
      'idea_text': ideaText,
      'source': source.value,
      'created_at': DbCodec.dateToString(createdAt),
      'selected_for_final': DbCodec.boolToInt(selectedForFinal),
    };
  }

  factory Idea.fromMap(Map<String, Object?> map) {
    return Idea(
      ideaId: map['idea_id']! as String,
      sessionId: map['session_id']! as String,
      phaseId: map['phase_id'] as String?,
      ideaText: map['idea_text']! as String,
      source: IdeaSource.fromValue(map['source']! as String),
      createdAt: DbCodec.stringToDate(map['created_at'])!,
      selectedForFinal: DbCodec.intToBool(map['selected_for_final']),
    );
  }

  static const String tableName = 'ideas';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      idea_id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      phase_id TEXT,
      idea_text TEXT NOT NULL,
      source TEXT NOT NULL,
      created_at TEXT NOT NULL,
      selected_for_final INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (session_id) REFERENCES sessions(session_id),
      FOREIGN KEY (phase_id) REFERENCES phases(phase_id)
    )
  ''';
}
