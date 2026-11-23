import 'db_codec.dart';

/// Optional observation a facilitator records about a session (engagement
/// rating and free-text notes). Kept separate from child-facing data.
class FacilitatorNote {
  const FacilitatorNote({
    required this.noteId,
    required this.sessionId,
    required this.createdAt,
    this.engagementRating,
    this.qualitativeNotes,
    this.createdBy,
  });

  final String noteId;
  final String sessionId;
  final int? engagementRating;
  final String? qualitativeNotes;
  final DateTime createdAt;
  final String? createdBy;

  FacilitatorNote copyWith({
    String? noteId,
    String? sessionId,
    int? engagementRating,
    String? qualitativeNotes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return FacilitatorNote(
      noteId: noteId ?? this.noteId,
      sessionId: sessionId ?? this.sessionId,
      engagementRating: engagementRating ?? this.engagementRating,
      qualitativeNotes: qualitativeNotes ?? this.qualitativeNotes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'note_id': noteId,
      'session_id': sessionId,
      'engagement_rating': engagementRating,
      'qualitative_notes': qualitativeNotes,
      'created_at': DbCodec.dateToString(createdAt),
      'created_by': createdBy,
    };
  }

  factory FacilitatorNote.fromMap(Map<String, Object?> map) {
    return FacilitatorNote(
      noteId: map['note_id']! as String,
      sessionId: map['session_id']! as String,
      engagementRating: map['engagement_rating'] as int?,
      qualitativeNotes: map['qualitative_notes'] as String?,
      createdAt: DbCodec.stringToDate(map['created_at'])!,
      createdBy: map['created_by'] as String?,
    );
  }

  static const String tableName = 'facilitator_notes';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      note_id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      engagement_rating INTEGER,
      qualitative_notes TEXT,
      created_at TEXT NOT NULL,
      created_by TEXT,
      FOREIGN KEY (session_id) REFERENCES sessions(session_id)
    )
  ''';
}
