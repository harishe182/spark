import 'db_codec.dart';

/// The child's three 1–5 reflection answers at the end of a weekly session.
/// Identical questions across conditions so responses are comparable.
class Reflection {
  const Reflection({
    required this.reflectionId,
    required this.sessionId,
    required this.ownershipRating,
    required this.creativityRating,
    required this.hintHelpfulnessRating,
    required this.createdAt,
  });

  final String reflectionId;
  final String sessionId;
  final int ownershipRating;
  final int creativityRating;
  final int hintHelpfulnessRating;
  final DateTime createdAt;

  Reflection copyWith({
    String? reflectionId,
    String? sessionId,
    int? ownershipRating,
    int? creativityRating,
    int? hintHelpfulnessRating,
    DateTime? createdAt,
  }) {
    return Reflection(
      reflectionId: reflectionId ?? this.reflectionId,
      sessionId: sessionId ?? this.sessionId,
      ownershipRating: ownershipRating ?? this.ownershipRating,
      creativityRating: creativityRating ?? this.creativityRating,
      hintHelpfulnessRating:
          hintHelpfulnessRating ?? this.hintHelpfulnessRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'reflection_id': reflectionId,
      'session_id': sessionId,
      'ownership_rating': ownershipRating,
      'creativity_rating': creativityRating,
      'hint_helpfulness_rating': hintHelpfulnessRating,
      'created_at': DbCodec.dateToString(createdAt),
    };
  }

  factory Reflection.fromMap(Map<String, Object?> map) {
    return Reflection(
      reflectionId: map['reflection_id']! as String,
      sessionId: map['session_id']! as String,
      ownershipRating: map['ownership_rating']! as int,
      creativityRating: map['creativity_rating']! as int,
      hintHelpfulnessRating: map['hint_helpfulness_rating']! as int,
      createdAt: DbCodec.stringToDate(map['created_at'])!,
    );
  }

  static const String tableName = 'reflections';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      reflection_id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      ownership_rating INTEGER NOT NULL,
      creativity_rating INTEGER NOT NULL,
      hint_helpfulness_rating INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (session_id) REFERENCES sessions(session_id)
    )
  ''';
}
