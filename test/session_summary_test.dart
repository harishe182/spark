import 'package:flutter_test/flutter_test.dart';
import 'package:spark/core/csv_writer.dart';
import 'package:spark/core/enums.dart';
import 'package:spark/models/idea.dart';
import 'package:spark/models/phase.dart';
import 'package:spark/models/reflection.dart';
import 'package:spark/models/session.dart';
import 'package:spark/models/spark_event.dart';
import 'package:spark/services/session_summary.dart';

Session _session() => Session(
      sessionId: 's1',
      participantId: 'P001',
      mode: SessionMode.weeklySession,
      weekNumber: 3,
      promptId: 'week_03',
      startTime: DateTime.parse('2026-06-25T10:00:00Z'),
      endTime: DateTime.parse('2026-06-25T10:15:00Z'),
      completionStatus: CompletionStatus.completed,
    );

Idea _idea(String id, IdeaSource source, {bool selected = false}) => Idea(
      ideaId: id,
      sessionId: 's1',
      phaseId: 'ph',
      ideaText: 'idea $id',
      source: source,
      createdAt: DateTime.parse('2026-06-25T10:05:00Z'),
      selectedForFinal: selected,
    );

SparkEvent _event(String id, SparkResponse response) => SparkEvent(
      eventId: id,
      sessionId: 's1',
      phaseId: 'ph',
      condition: StudyCondition.aiSpark,
      sparkType: SparkType.aiGenerated,
      suggestionText: 'try x',
      suggestionSourceId: 'src',
      shownAt: DateTime.parse('2026-06-25T10:06:00Z'),
      response: response,
    );

void main() {
  test('computes fluency, reliance, and acceptance rate', () {
    final summary = SessionSummary.fromData(
      session: _session(),
      ideas: [
        _idea('1', IdeaSource.child),
        _idea('2', IdeaSource.child),
        _idea('3', IdeaSource.aiSparkAccepted, selected: true),
      ],
      sparkEvents: [
        _event('e1', SparkResponse.accepted),
        _event('e2', SparkResponse.rejected),
        _event('e3', SparkResponse.rejected),
        _event('e4', SparkResponse.noResponse),
      ],
      phases: [
        Phase(
          phaseId: 'p1',
          sessionId: 's1',
          phaseType: PhaseType.divergent,
          startTime: DateTime.parse('2026-06-25T10:00:00Z'),
          durationSeconds: 360,
        ),
      ],
      reflection: Reflection(
        reflectionId: 'r1',
        sessionId: 's1',
        ownershipRating: 4,
        creativityRating: 5,
        hintHelpfulnessRating: 3,
        createdAt: DateTime.parse('2026-06-25T10:14:00Z'),
      ),
      condition: StudyCondition.aiSpark,
    );

    expect(summary.ideaCount, 3);
    expect(summary.childIdeaCount, 2);
    expect(summary.acceptedSuggestionCount, 1);
    expect(summary.sparkShownCount, 4);
    expect(summary.sparkAcceptedCount, 1);
    expect(summary.sparkRejectedCount, 2);
    expect(summary.sparkAcceptanceRate, closeTo(0.25, 1e-9));
    expect(summary.selectedIdeaSource, IdeaSource.aiSparkAccepted);
    expect(summary.phaseDurations[PhaseType.divergent], 360);
    expect(summary.ownershipRating, 4);
  });

  test('acceptance rate is null when no suggestions shown', () {
    final summary = SessionSummary.fromData(
      session: _session(),
      ideas: const [],
      sparkEvents: const [],
      phases: const [],
      reflection: null,
      condition: StudyCondition.staticSpark,
    );
    expect(summary.sparkAcceptanceRate, isNull);
    expect(summary.ideaCount, 0);
  });

  test('CSV row aligns with headers in length', () {
    final summary = SessionSummary.fromData(
      session: _session(),
      ideas: const [],
      sparkEvents: const [],
      phases: const [],
      reflection: null,
      condition: StudyCondition.aiSpark,
    );
    expect(summary.toCsvRow().length, SessionSummary.csvHeaders.length);
  });

  test('CsvWriter quotes cells containing commas and quotes', () {
    final csv = CsvWriter.toCsv([
      ['a', 'b,c', 'd"e'],
      [1, null, 3],
    ]);
    expect(csv, contains('"b,c"'));
    expect(csv, contains('"d""e"'));
    // null renders as empty field.
    expect(csv.split('\r\n')[1], '1,,3');
  });
}
