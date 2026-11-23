import 'package:flutter_test/flutter_test.dart';
import 'package:spark/core/enums.dart';
import 'package:spark/models/idea.dart';
import 'package:spark/models/participant.dart';
import 'package:spark/models/session.dart';
import 'package:spark/models/spark_event.dart';

/// Models must survive a toMap → fromMap round-trip unchanged, because that
/// path is exactly what storage and export rely on. A regression here would
/// silently corrupt research data.
void main() {
  test('Participant round-trips through map', () {
    final original = Participant(
      participantId: 'P001',
      assignedCondition: StudyCondition.aiSpark,
      ageGroup: AgeGroup.olderTenToEleven,
      createdAt: DateTime.parse('2026-06-25T10:00:00Z'),
      createdBy: 'fac-1',
    );
    final restored = Participant.fromMap(original.toMap());

    expect(restored.participantId, original.participantId);
    expect(restored.assignedCondition, original.assignedCondition);
    expect(restored.ageGroup, original.ageGroup);
    expect(restored.createdAt.toUtc(), original.createdAt.toUtc());
    expect(restored.createdBy, original.createdBy);
  });

  test('Session preserves null week for pre-test', () {
    final original = Session(
      sessionId: 's1',
      participantId: 'P001',
      mode: SessionMode.preTest,
      weekNumber: null,
      promptId: 'pre_test',
      startTime: DateTime.parse('2026-06-25T10:00:00Z'),
      endTime: null,
      completionStatus: CompletionStatus.inProgress,
    );
    final restored = Session.fromMap(original.toMap());

    expect(restored.weekNumber, isNull);
    expect(restored.mode, SessionMode.preTest);
    expect(restored.endTime, isNull);
    expect(restored.completionStatus, CompletionStatus.inProgress);
  });

  test('Idea preserves source and selected flag', () {
    final original = Idea(
      ideaId: 'i1',
      sessionId: 's1',
      phaseId: 'ph1',
      ideaText: 'a glowing fish',
      source: IdeaSource.aiSparkAccepted,
      createdAt: DateTime.parse('2026-06-25T10:05:00Z'),
      selectedForFinal: true,
    );
    final restored = Idea.fromMap(original.toMap());

    expect(restored.source, IdeaSource.aiSparkAccepted);
    expect(restored.selectedForFinal, isTrue);
    expect(restored.ideaText, 'a glowing fish');
  });

  test('SparkEvent preserves response and bool encoding', () {
    final original = SparkEvent(
      eventId: 'e1',
      sessionId: 's1',
      phaseId: 'ph1',
      condition: StudyCondition.staticSpark,
      sparkType: SparkType.staticBank,
      suggestionText: 'Try adding a surprising detail.',
      suggestionSourceId: '3',
      shownAt: DateTime.parse('2026-06-25T10:06:00Z'),
      response: SparkResponse.accepted,
      respondedAt: DateTime.parse('2026-06-25T10:06:05Z'),
      addedToIdeaList: true,
    );
    final restored = SparkEvent.fromMap(original.toMap());

    expect(restored.response, SparkResponse.accepted);
    expect(restored.addedToIdeaList, isTrue);
    expect(restored.sparkType, SparkType.staticBank);
    expect(restored.condition, StudyCondition.staticSpark);
  });

  test('enum fromValue rejects unknown values', () {
    expect(() => StudyCondition.fromValue('nope'), throwsArgumentError);
    expect(() => SessionMode.fromValue('nope'), throwsArgumentError);
  });

  test('SessionMode.sparkEnabled only for weekly sessions', () {
    expect(SessionMode.preTest.sparkEnabled, isFalse);
    expect(SessionMode.postTest.sparkEnabled, isFalse);
    expect(SessionMode.weeklySession.sparkEnabled, isTrue);
  });
}
