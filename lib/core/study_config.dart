import 'enums.dart';
import 'phase_plan.dart';

/// Researcher-tunable timing configuration. Defaults match the study brief
/// (15-minute weekly session; Spark every 90s / 2m). Values can be overridden
/// from a JSON config so timing can be adjusted after pilot testing without a
/// code change, and [pilotScaled] produces compressed sessions for quick
/// dry-runs.
class StudyConfig {
  const StudyConfig({
    required this.introSeconds,
    required this.divergentSeconds,
    required this.selectionSeconds,
    required this.convergentSeconds,
    required this.reflectionSeconds,
    required this.testDrawingSeconds,
    required this.divergentSparkIntervalSeconds,
    required this.convergentSparkIntervalSeconds,
    required this.snapshotIntervalSeconds,
    this.pilotMode = false,
  });

  final int introSeconds;
  final int divergentSeconds;
  final int selectionSeconds;
  final int convergentSeconds;
  final int reflectionSeconds;
  final int testDrawingSeconds;
  final int divergentSparkIntervalSeconds;
  final int convergentSparkIntervalSeconds;
  final int snapshotIntervalSeconds;
  final bool pilotMode;

  /// Default configuration from the study brief.
  factory StudyConfig.defaults() => const StudyConfig(
        introSeconds: 60,
        divergentSeconds: 360,
        selectionSeconds: 60,
        convergentSeconds: 360,
        reflectionSeconds: 60,
        testDrawingSeconds: 600,
        divergentSparkIntervalSeconds: 90,
        convergentSparkIntervalSeconds: 120,
        snapshotIntervalSeconds: 150,
      );

  /// Parses a config map (e.g. from a bundled/asset JSON), falling back to the
  /// default for any missing field so partial configs are valid.
  factory StudyConfig.fromJson(Map<String, Object?> json) {
    final d = StudyConfig.defaults();
    int read(String key, int fallback) {
      final v = json[key];
      return v is num ? v.toInt() : fallback;
    }

    return StudyConfig(
      introSeconds: read('intro_seconds', d.introSeconds),
      divergentSeconds: read('divergent_seconds', d.divergentSeconds),
      selectionSeconds: read('selection_seconds', d.selectionSeconds),
      convergentSeconds: read('convergent_seconds', d.convergentSeconds),
      reflectionSeconds: read('reflection_seconds', d.reflectionSeconds),
      testDrawingSeconds: read('test_drawing_seconds', d.testDrawingSeconds),
      divergentSparkIntervalSeconds: read(
          'divergent_spark_interval_seconds', d.divergentSparkIntervalSeconds),
      convergentSparkIntervalSeconds: read(
          'convergent_spark_interval_seconds',
          d.convergentSparkIntervalSeconds),
      snapshotIntervalSeconds:
          read('snapshot_interval_seconds', d.snapshotIntervalSeconds),
    );
  }

  /// A compressed copy for pilot dry-runs: durations divided by 6 (min 5s),
  /// Spark cadence divided by 3 (min 5s). Preserves phase ordering and the
  /// AI/static distinction — only the clock is faster.
  StudyConfig pilotScaled() {
    int fast(int s, int by, {int min = 5}) =>
        (s ~/ by).clamp(min, s).toInt();
    return StudyConfig(
      introSeconds: fast(introSeconds, 6),
      divergentSeconds: fast(divergentSeconds, 6),
      selectionSeconds: fast(selectionSeconds, 6),
      convergentSeconds: fast(convergentSeconds, 6),
      reflectionSeconds: fast(reflectionSeconds, 6),
      testDrawingSeconds: fast(testDrawingSeconds, 6),
      // Pilot dry-runs: fire Spark quickly so the flow is easy to observe.
      divergentSparkIntervalSeconds: 8,
      convergentSparkIntervalSeconds: 10,
      snapshotIntervalSeconds: fast(snapshotIntervalSeconds, 3),
      pilotMode: true,
    );
  }

  /// Default seconds for a phase type in a weekly session.
  int weeklyPhaseSeconds(PhaseType type) {
    switch (type) {
      case PhaseType.intro:
        return introSeconds;
      case PhaseType.divergent:
        return divergentSeconds;
      case PhaseType.selection:
        return selectionSeconds;
      case PhaseType.convergent:
        return convergentSeconds;
      case PhaseType.reflection:
        return reflectionSeconds;
    }
  }

  /// Spark interval for a phase (0 = no Spark in this phase).
  int sparkIntervalSeconds(PhaseType type) {
    switch (type) {
      case PhaseType.divergent:
        return divergentSparkIntervalSeconds;
      case PhaseType.convergent:
        return convergentSparkIntervalSeconds;
      case PhaseType.intro:
      case PhaseType.selection:
      case PhaseType.reflection:
        return 0;
    }
  }

  /// Ordered weekly phase steps built from this config.
  List<PhaseStep> weeklySteps() => [
        for (final type in PhaseType.values)
          PhaseStep(type, weeklyPhaseSeconds(type)),
      ];
}
