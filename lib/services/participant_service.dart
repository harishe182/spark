import '../core/enums.dart';
import '../models/participant.dart';
import 'participant_allocation.dart';
import 'storage_service.dart';

/// Creates and lists participants. Owns the two policy decisions that matter
/// for research integrity: how participant IDs are generated and how
/// conditions are assigned (balanced between the two arms).
class ParticipantService {
  ParticipantService(this._storage);

  final StorageService _storage;

  Future<List<Participant>> listParticipants() =>
      _storage.getAllParticipants();

  /// Creates a participant with the next sequential ID ("P001", "P002", …).
  ///
  /// If [condition] is omitted, it is assigned to keep the two arms balanced
  /// (the arm with fewer participants so far; ties break to AI-Spark). This
  /// approximates random-but-balanced allocation; a stricter randomization
  /// scheme can replace this without touching callers.
  Future<Participant> createParticipant({
    required AgeGroup ageGroup,
    StudyCondition? condition,
    String? createdBy,
  }) async {
    final existing = await _storage.getAllParticipants();
    final id = ParticipantAllocation.nextParticipantId(
      existing.map((p) => p.participantId),
    );
    final assigned = condition ??
        ParticipantAllocation.balancedCondition(
          existing.map((p) => p.assignedCondition),
        );

    final participant = Participant(
      participantId: id,
      assignedCondition: assigned,
      ageGroup: ageGroup,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
    await _storage.insertParticipant(participant);
    return participant;
  }
}
