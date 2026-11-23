import 'package:flutter_test/flutter_test.dart';
import 'package:spark/core/enums.dart';
import 'package:spark/core/phase_plan.dart';
import 'package:spark/models/override_event.dart';

/// The weekly session must be the five-phase, ~15-minute structure from the
/// study design; pre/post are a single drawing block.
void main() {
  test('weekly session has 5 phases in the prescribed order', () {
    final types = PhasePlan.weekly.map((s) => s.type).toList();
    expect(types, [
      PhaseType.intro,
      PhaseType.divergent,
      PhaseType.selection,
      PhaseType.convergent,
      PhaseType.reflection,
    ]);
  });

  test('weekly session totals 15 minutes', () {
    expect(PhasePlan.totalSeconds(SessionMode.weeklySession), 15 * 60);
  });

  test('pre/post tests are a single drawing phase', () {
    expect(PhasePlan.forMode(SessionMode.preTest).length, 1);
    expect(PhasePlan.forMode(SessionMode.postTest).single.type,
        PhaseType.convergent);
  });

  test('OverrideEvent round-trips through map', () {
    final original = OverrideEvent(
      overrideId: 'o1',
      sessionId: 's1',
      phaseId: 'ph1',
      action: 'advance_phase',
      detail: 'from divergent',
      createdAt: DateTime.parse('2026-06-25T10:00:00Z'),
    );
    final restored = OverrideEvent.fromMap(original.toMap());
    expect(restored.action, 'advance_phase');
    expect(restored.detail, 'from divergent');
    expect(restored.sessionId, 's1');
  });
}
