import 'package:flutter_test/flutter_test.dart';
import 'package:spark/core/constants.dart';
import 'package:spark/core/enums.dart';
import 'package:spark/core/static_hint_bank.dart';
import 'package:spark/core/study_config.dart';
import 'package:spark/models/spark_event.dart';
import 'package:spark/services/spark_event_logger.dart';
import 'package:spark/services/spark_session.dart';
import 'package:spark/services/static_spark_session.dart';

/// Captures logged events in memory so Spark behavior can be tested without a
/// database.
class _CaptureSink implements SparkEventSink {
  final List<SparkEvent> events = [];

  @override
  Future<void> save(SparkEvent event) async {
    // Mirror upsert semantics: replace by id, else append.
    final i = events.indexWhere((e) => e.eventId == event.eventId);
    if (i >= 0) {
      events[i] = event;
    } else {
      events.add(event);
    }
  }
}

SparkContext _ctx() => const SparkContext(
      promptId: 'week_01',
      promptText: 'Imagine a friendly helper.',
      phaseType: PhaseType.divergent,
      ideaList: [],
      acceptedSuggestions: [],
      rejectedSuggestions: [],
      remainingSeconds: 300,
    );

/// Advances the session clock until a suggestion appears (or gives up).
Future<void> _tickUntilSuggestion(StaticSparkSession s) async {
  for (var i = 0; i < SparkTiming.divergentIntervalSeconds + 2; i++) {
    s.onTick(0);
    await Future<void>.delayed(Duration.zero);
    if (s.currentSuggestion != null) return;
  }
}

void main() {
  test('static bank is prompt-specific then falls back to generic', () {
    final hints = StaticHintBank.forPrompt('week_01');
    // First entries are the week_01-specific hints.
    expect(hints.first, StaticHintBank.byPrompt['week_01']!.first);
    // Generic pool is appended.
    expect(hints, containsAll(StaticHintBank.generic));
  });

  test('shows a suggestion on cadence and logs it as static', () async {
    final sink = _CaptureSink();
    final session = StaticSparkSession(logger: sink, config: StudyConfig.defaults());
    session.configureForPhase(
      sessionId: 's1',
      phaseType: PhaseType.divergent,
      phaseId: 'ph1',
      contextProvider: _ctx,
      onSuggestionAccepted: (_, __) async {},
    );

    await _tickUntilSuggestion(session);

    expect(session.currentSuggestion, isNotNull);
    expect(session.currentSuggestion!.aiGenerated, isFalse);
    expect(sink.events.length, 1);
    expect(sink.events.first.sparkType, SparkType.staticBank);
    expect(sink.events.first.condition, StudyCondition.staticSpark);
    expect(sink.events.first.response, SparkResponse.noResponse);
  });

  test('accept routes text to idea list and logs acceptance', () async {
    final sink = _CaptureSink();
    final accepted = <String>[];
    bool? acceptedAiFlag;
    final session = StaticSparkSession(logger: sink, config: StudyConfig.defaults());
    session.configureForPhase(
      sessionId: 's1',
      phaseType: PhaseType.divergent,
      phaseId: 'ph1',
      contextProvider: _ctx,
      onSuggestionAccepted: (text, ai) async {
        accepted.add(text);
        acceptedAiFlag = ai;
      },
    );

    await _tickUntilSuggestion(session);
    final shownText = session.currentSuggestion!.text;
    await session.accept();

    expect(accepted, [shownText]);
    expect(acceptedAiFlag, isFalse);
    expect(session.currentSuggestion, isNull);
    expect(sink.events.single.response, SparkResponse.accepted);
    expect(sink.events.single.addedToIdeaList, isTrue);
  });

  test('never repeats a suggestion across cycles', () async {
    final sink = _CaptureSink();
    final session = StaticSparkSession(logger: sink, config: StudyConfig.defaults());
    session.configureForPhase(
      sessionId: 's1',
      phaseType: PhaseType.divergent,
      phaseId: 'ph1',
      contextProvider: _ctx,
      onSuggestionAccepted: (_, __) async {},
    );

    final seen = <String>{};
    for (var cycle = 0; cycle < 5; cycle++) {
      await _tickUntilSuggestion(session);
      final text = session.currentSuggestion?.text;
      expect(text, isNotNull, reason: 'cycle $cycle produced no suggestion');
      expect(seen.contains(text), isFalse, reason: 'repeated: $text');
      seen.add(text!);
      await session.reject();
    }
    expect(seen.length, 5);
  });

  test('reject logs rejection and does not add to idea list', () async {
    final sink = _CaptureSink();
    final session = StaticSparkSession(logger: sink, config: StudyConfig.defaults());
    session.configureForPhase(
      sessionId: 's1',
      phaseType: PhaseType.divergent,
      phaseId: 'ph1',
      contextProvider: _ctx,
      onSuggestionAccepted: (_, __) async {},
    );

    await _tickUntilSuggestion(session);
    await session.reject();

    expect(session.currentSuggestion, isNull);
    expect(sink.events.single.response, SparkResponse.rejected);
    expect(sink.events.single.addedToIdeaList, isFalse);
  });

  test('no suggestions in non-spark phases (intro/selection/reflection)',
      () async {
    final sink = _CaptureSink();
    final session = StaticSparkSession(logger: sink, config: StudyConfig.defaults());
    session.configureForPhase(
      sessionId: 's1',
      phaseType: PhaseType.selection,
      phaseId: 'ph1',
      contextProvider: _ctx,
      onSuggestionAccepted: (_, __) async {},
    );

    for (var i = 0; i < 300; i++) {
      session.onTick(0);
      await Future<void>.delayed(Duration.zero);
    }
    expect(session.currentSuggestion, isNull);
    expect(sink.events, isEmpty);
  });
}
