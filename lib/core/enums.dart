/// Core enumerations for the Spark research study.
///
/// These types encode the experimental design directly so that study
/// integrity is enforced at the type level — e.g. a session always knows
/// whether it is a pre-test, weekly session, or post-test.
library;

/// The experimental condition a participant is assigned to.
///
/// This is a between-subjects factor: each participant belongs to exactly
/// one condition for the entire study. The label is NEVER shown to the child.
enum StudyCondition {
  aiSpark('ai_spark'),
  staticSpark('static_spark');

  const StudyCondition(this.value);

  /// Stable string used in storage and exports.
  final String value;

  static StudyCondition fromValue(String value) {
    return StudyCondition.values.firstWhere(
      (c) => c.value == value,
      orElse: () => throw ArgumentError('Unknown StudyCondition: $value'),
    );
  }
}

/// The mode in which a session runs.
///
/// Pre-test and post-test are Spark-free independent creativity tasks.
/// Weekly sessions include Spark (AI or static depending on condition).
enum SessionMode {
  preTest('pre_test'),
  weeklySession('weekly_session'),
  postTest('post_test');

  const SessionMode(this.value);

  final String value;

  /// Whether Spark suggestions are allowed in this mode.
  bool get sparkEnabled => this == SessionMode.weeklySession;

  static SessionMode fromValue(String value) {
    return SessionMode.values.firstWhere(
      (m) => m.value == value,
      orElse: () => throw ArgumentError('Unknown SessionMode: $value'),
    );
  }
}

/// A phase within a session. Weekly sessions run all five in order; pre/post
/// tests use only [intro] and [convergent] (independent drawing).
enum PhaseType {
  intro('intro'),
  divergent('divergent'),
  selection('selection'),
  convergent('convergent'),
  reflection('reflection');

  const PhaseType(this.value);

  final String value;

  static PhaseType fromValue(String value) {
    return PhaseType.values.firstWhere(
      (p) => p.value == value,
      orElse: () => throw ArgumentError('Unknown PhaseType: $value'),
    );
  }
}

/// Completion status of a session.
enum CompletionStatus {
  inProgress('in_progress'),
  completed('completed'),
  abandoned('abandoned');

  const CompletionStatus(this.value);

  final String value;

  static CompletionStatus fromValue(String value) {
    return CompletionStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => throw ArgumentError('Unknown CompletionStatus: $value'),
    );
  }
}

/// Where an idea in the idea list originated.
enum IdeaSource {
  child('child'),
  aiSparkAccepted('ai_spark_accepted'),
  staticSparkAccepted('static_spark_accepted');

  const IdeaSource(this.value);

  final String value;

  static IdeaSource fromValue(String value) {
    return IdeaSource.values.firstWhere(
      (s) => s.value == value,
      orElse: () => throw ArgumentError('Unknown IdeaSource: $value'),
    );
  }
}

/// How a Spark suggestion was produced.
enum SparkType {
  aiGenerated('ai_generated'),
  staticBank('static_bank');

  const SparkType(this.value);

  final String value;

  static SparkType fromValue(String value) {
    return SparkType.values.firstWhere(
      (s) => s.value == value,
      orElse: () => throw ArgumentError('Unknown SparkType: $value'),
    );
  }
}

/// The child's response to a Spark suggestion.
enum SparkResponse {
  accepted('accepted'),
  rejected('rejected'),
  noResponse('no_response');

  const SparkResponse(this.value);

  final String value;

  static SparkResponse fromValue(String value) {
    return SparkResponse.values.firstWhere(
      (r) => r.value == value,
      orElse: () => throw ArgumentError('Unknown SparkResponse: $value'),
    );
  }
}

/// Type of saved drawing artifact.
enum ArtifactType {
  sketch('sketch'),
  finalDrawing('final_drawing'),
  snapshot('snapshot'),
  preTest('pre_test'),
  postTest('post_test');

  const ArtifactType(this.value);

  final String value;

  static ArtifactType fromValue(String value) {
    return ArtifactType.values.firstWhere(
      (a) => a.value == value,
      orElse: () => throw ArgumentError('Unknown ArtifactType: $value'),
    );
  }
}

/// Age group of a participant (used for stratification, not sent to LLM).
enum AgeGroup {
  youngerEightToNine('8-9'),
  olderTenToEleven('10-11');

  const AgeGroup(this.value);

  final String value;

  static AgeGroup fromValue(String value) {
    return AgeGroup.values.firstWhere(
      (a) => a.value == value,
      orElse: () => throw ArgumentError('Unknown AgeGroup: $value'),
    );
  }
}
