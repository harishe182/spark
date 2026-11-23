import 'package:flutter_test/flutter_test.dart';
import 'package:spark/core/enums.dart';
import 'package:spark/services/participant_allocation.dart';

void main() {
  group('nextParticipantId', () {
    test('starts at P001 when none exist', () {
      expect(ParticipantAllocation.nextParticipantId([]), 'P001');
    });

    test('continues from the max numeric suffix', () {
      expect(
        ParticipantAllocation.nextParticipantId(['P001', 'P002', 'P003']),
        'P004',
      );
    });

    test('ignores non-conforming ids and handles gaps', () {
      expect(
        ParticipantAllocation.nextParticipantId(['P001', 'junk', 'P010']),
        'P011',
      );
    });
  });

  group('balancedCondition', () {
    test('first assignment goes to AI (tie-break)', () {
      expect(ParticipantAllocation.balancedCondition([]),
          StudyCondition.aiSpark);
    });

    test('assigns to the smaller arm', () {
      expect(
        ParticipantAllocation.balancedCondition([StudyCondition.aiSpark]),
        StudyCondition.staticSpark,
      );
      expect(
        ParticipantAllocation.balancedCondition(
            [StudyCondition.aiSpark, StudyCondition.staticSpark]),
        StudyCondition.aiSpark,
      );
    });

    test('keeps arms balanced over a sequence', () {
      final assignments = <StudyCondition>[];
      for (var i = 0; i < 10; i++) {
        assignments.add(
            ParticipantAllocation.balancedCondition(List.of(assignments)));
      }
      final ai =
          assignments.where((c) => c == StudyCondition.aiSpark).length;
      final stat = assignments.length - ai;
      expect((ai - stat).abs(), lessThanOrEqualTo(1));
    });
  });
}
