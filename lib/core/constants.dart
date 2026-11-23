/// App-wide constants and configurable defaults.
///
/// Timing values here are *defaults*. Phase 5 will move Spark timing into a
/// JSON-driven config so researchers can tune them after pilot testing
/// (see plan §Phase 5). Keep all magic numbers in one place.
library;

class AppInfo {
  AppInfo._();
  static const String appName = 'Spark';
  static const String dbFileName = 'spark_research.db';
  static const int dbVersion = 1;
}

/// Default phase durations (seconds) for a 15-minute weekly session.
class SessionTiming {
  SessionTiming._();
  static const int introSeconds = 60; // 1 min
  static const int divergentSeconds = 360; // 6 min
  static const int selectionSeconds = 60; // 1 min
  static const int convergentSeconds = 360; // 6 min
  static const int reflectionSeconds = 60; // 1 min

  /// Independent pre/post-test drawing time.
  static const int testDrawingSeconds = 600; // 10 min
}

/// Default Spark suggestion cadence. Configurable in Phase 5.
class SparkTiming {
  SparkTiming._();
  static const int divergentIntervalSeconds = 90;
  static const int convergentIntervalSeconds = 120;

  /// Snapshot cadence during drawing phases.
  static const int snapshotIntervalSeconds = 150; // 2.5 min
}

/// Child-facing copy. NEVER reference AI, LLM, model, condition, or experiment.
class ChildCopy {
  ChildCopy._();
  static const String sparkHasIdea = 'Spark has an idea!';
  static const String wantToAdd = 'Want to add this to your idea list?';
  static const String tryThisIdea = 'Try this idea?';
  static const String accept = 'Accept';
  static const String reject = 'Reject';
  static const String yourIdeas = 'Your Ideas';
  static const String addIdea = 'Add an idea';
}

/// The three child reflection questions (identical wording for both conditions).
class ReflectionQuestions {
  ReflectionQuestions._();
  static const String ownership = 'How much does this feel like YOUR idea?';
  static const String creativity = 'How creative do you think your idea is?';
  static const String helpfulness = 'How much did the hints help you?';
  static const String lowLabel = 'not really';
  static const String highLabel = 'very much';
  static const int minRating = 1;
  static const int maxRating = 5;
}
