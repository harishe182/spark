import '../core/enums.dart';
import '../models/idea.dart';
import '../models/phase.dart';
import '../models/reflection.dart';
import '../models/session.dart';
import '../models/spark_event.dart';

/// Per-session analysis metrics, derived purely from stored records. This is
/// the heart of the CSV summary export and is kept dependency-free so it can
/// be unit-tested without a database. Field names map directly to the
/// analysis quantities the study needs (fluency, acceptance rate, reliance…).
class SessionSummary {
  const SessionSummary({
    required this.sessionId,
    required this.participantId,
    required this.condition,
    required this.mode,
    required this.weekNumber,
    required this.promptId,
    required this.completionStatus,
    required this.facilitatorOverrideCount,
    required this.ideaCount,
    required this.childIdeaCount,
    required this.acceptedSuggestionCount,
    required this.sparkShownCount,
    required this.sparkAcceptedCount,
    required this.sparkRejectedCount,
    required this.selectedIdeaSource,
    required this.phaseDurations,
    required this.ownershipRating,
    required this.creativityRating,
    required this.hintHelpfulnessRating,
  });

  final String sessionId;
  final String participantId;
  final StudyCondition condition;
  final SessionMode mode;
  final int? weekNumber;
  final String? promptId;
  final CompletionStatus completionStatus;
  final int facilitatorOverrideCount;

  /// Idea fluency: total ideas in the list.
  final int ideaCount;

  /// Ideas the child authored (excludes accepted suggestions).
  final int childIdeaCount;

  /// Accepted Spark suggestions present in the idea list.
  final int acceptedSuggestionCount;

  final int sparkShownCount;
  final int sparkAcceptedCount;
  final int sparkRejectedCount;

  /// Source of the idea chosen for the final drawing, or null if none chosen.
  final IdeaSource? selectedIdeaSource;

  /// Seconds spent per phase type.
  final Map<PhaseType, int> phaseDurations;

  final int? ownershipRating;
  final int? creativityRating;
  final int? hintHelpfulnessRating;

  /// Spark acceptance rate over shown suggestions (0..1), or null if none
  /// were shown (avoids a misleading 0).
  double? get sparkAcceptanceRate =>
      sparkShownCount == 0 ? null : sparkAcceptedCount / sparkShownCount;

  factory SessionSummary.fromData({
    required Session session,
    required List<Idea> ideas,
    required List<SparkEvent> sparkEvents,
    required List<Phase> phases,
    required Reflection? reflection,
    required StudyCondition condition,
  }) {
    final childIdeas =
        ideas.where((i) => i.source == IdeaSource.child).length;
    final acceptedSuggestions = ideas.length - childIdeas;

    final shown = sparkEvents.length;
    final accepted = sparkEvents
        .where((e) => e.response == SparkResponse.accepted)
        .length;
    final rejected = sparkEvents
        .where((e) => e.response == SparkResponse.rejected)
        .length;

    final selected = ideas.where((i) => i.selectedForFinal).firstOrNull;

    final durations = <PhaseType, int>{};
    for (final phase in phases) {
      durations[phase.phaseType] =
          (durations[phase.phaseType] ?? 0) + (phase.durationSeconds ?? 0);
    }

    return SessionSummary(
      sessionId: session.sessionId,
      participantId: session.participantId,
      condition: condition,
      mode: session.mode,
      weekNumber: session.weekNumber,
      promptId: session.promptId,
      completionStatus: session.completionStatus,
      facilitatorOverrideCount: session.facilitatorOverrideCount,
      ideaCount: ideas.length,
      childIdeaCount: childIdeas,
      acceptedSuggestionCount: acceptedSuggestions,
      sparkShownCount: shown,
      sparkAcceptedCount: accepted,
      sparkRejectedCount: rejected,
      selectedIdeaSource: selected?.source,
      phaseDurations: durations,
      ownershipRating: reflection?.ownershipRating,
      creativityRating: reflection?.creativityRating,
      hintHelpfulnessRating: reflection?.hintHelpfulnessRating,
    );
  }

  /// Ordered CSV column headers matching [toCsvRow].
  static const List<String> csvHeaders = [
    'session_id',
    'participant_id',
    'condition',
    'mode',
    'week_number',
    'prompt_id',
    'completion_status',
    'facilitator_override_count',
    'idea_count',
    'child_idea_count',
    'accepted_suggestion_count',
    'spark_shown_count',
    'spark_accepted_count',
    'spark_rejected_count',
    'spark_acceptance_rate',
    'selected_idea_source',
    'intro_seconds',
    'divergent_seconds',
    'selection_seconds',
    'convergent_seconds',
    'reflection_seconds',
    'ownership_rating',
    'creativity_rating',
    'hint_helpfulness_rating',
  ];

  List<Object?> toCsvRow() {
    return [
      sessionId,
      participantId,
      condition.value,
      mode.value,
      weekNumber,
      promptId,
      completionStatus.value,
      facilitatorOverrideCount,
      ideaCount,
      childIdeaCount,
      acceptedSuggestionCount,
      sparkShownCount,
      sparkAcceptedCount,
      sparkRejectedCount,
      sparkAcceptanceRate?.toStringAsFixed(3),
      selectedIdeaSource?.value,
      phaseDurations[PhaseType.intro] ?? 0,
      phaseDurations[PhaseType.divergent] ?? 0,
      phaseDurations[PhaseType.selection] ?? 0,
      phaseDurations[PhaseType.convergent] ?? 0,
      phaseDurations[PhaseType.reflection] ?? 0,
      ownershipRating,
      creativityRating,
      hintHelpfulnessRating,
    ];
  }
}
