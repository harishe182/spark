import 'package:flutter_test/flutter_test.dart';
import 'package:spark/core/enums.dart';
import 'package:spark/core/study_config.dart';

void main() {
  test('defaults match the study brief (15-minute weekly session)', () {
    final c = StudyConfig.defaults();
    final total = c.introSeconds +
        c.divergentSeconds +
        c.selectionSeconds +
        c.convergentSeconds +
        c.reflectionSeconds;
    expect(total, 15 * 60);
    expect(c.divergentSparkIntervalSeconds, 90);
    expect(c.convergentSparkIntervalSeconds, 120);
    expect(c.pilotMode, isFalse);
  });

  test('weeklySteps preserves phase order', () {
    final steps = StudyConfig.defaults().weeklySteps();
    expect(steps.map((s) => s.type).toList(), [
      PhaseType.intro,
      PhaseType.divergent,
      PhaseType.selection,
      PhaseType.convergent,
      PhaseType.reflection,
    ]);
  });

  test('spark interval is zero in non-spark phases', () {
    final c = StudyConfig.defaults();
    expect(c.sparkIntervalSeconds(PhaseType.intro), 0);
    expect(c.sparkIntervalSeconds(PhaseType.selection), 0);
    expect(c.sparkIntervalSeconds(PhaseType.reflection), 0);
    expect(c.sparkIntervalSeconds(PhaseType.divergent), greaterThan(0));
  });

  test('pilotScaled compresses durations but keeps a floor and flag', () {
    final c = StudyConfig.defaults().pilotScaled();
    expect(c.pilotMode, isTrue);
    expect(c.divergentSeconds, lessThan(360));
    expect(c.divergentSeconds, greaterThanOrEqualTo(5));
    expect(c.divergentSparkIntervalSeconds, greaterThanOrEqualTo(5));
    // Ordering and spark-phase semantics are unchanged.
    expect(c.sparkIntervalSeconds(PhaseType.selection), 0);
  });

  test('fromJson falls back to defaults for missing fields', () {
    final c = StudyConfig.fromJson({'divergent_seconds': 120});
    expect(c.divergentSeconds, 120);
    // Untouched fields keep defaults.
    expect(c.introSeconds, StudyConfig.defaults().introSeconds);
  });
}
