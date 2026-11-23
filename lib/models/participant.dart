import '../core/enums.dart';
import 'db_codec.dart';

/// A study participant, identified only by a non-identifying [participantId]
/// (e.g. "P001"). No child names are ever stored (privacy requirement).
///
/// Immutable: use [copyWith] to derive modified copies.
class Participant {
  const Participant({
    required this.participantId,
    required this.assignedCondition,
    required this.ageGroup,
    required this.createdAt,
    this.createdBy,
  });

  final String participantId;
  final StudyCondition assignedCondition;
  final AgeGroup ageGroup;
  final DateTime createdAt;

  /// Optional facilitator identifier (not a child identifier).
  final String? createdBy;

  Participant copyWith({
    String? participantId,
    StudyCondition? assignedCondition,
    AgeGroup? ageGroup,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Participant(
      participantId: participantId ?? this.participantId,
      assignedCondition: assignedCondition ?? this.assignedCondition,
      ageGroup: ageGroup ?? this.ageGroup,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'participant_id': participantId,
      'assigned_condition': assignedCondition.value,
      'age_group': ageGroup.value,
      'created_at': DbCodec.dateToString(createdAt),
      'created_by': createdBy,
    };
  }

  factory Participant.fromMap(Map<String, Object?> map) {
    return Participant(
      participantId: map['participant_id']! as String,
      assignedCondition:
          StudyCondition.fromValue(map['assigned_condition']! as String),
      ageGroup: AgeGroup.fromValue(map['age_group']! as String),
      createdAt: DbCodec.stringToDate(map['created_at'])!,
      createdBy: map['created_by'] as String?,
    );
  }

  static const String tableName = 'participants';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      participant_id TEXT PRIMARY KEY,
      assigned_condition TEXT NOT NULL,
      age_group TEXT NOT NULL,
      created_at TEXT NOT NULL,
      created_by TEXT
    )
  ''';
}
