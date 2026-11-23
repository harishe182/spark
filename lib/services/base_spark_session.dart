import 'package:uuid/uuid.dart';

import '../core/enums.dart';
import '../core/study_config.dart';
import '../models/spark_event.dart';
import 'spark_event_logger.dart';
import 'spark_session.dart';

/// The data a concrete provider returns for the next suggestion.
class SparkSuggestionData {
  const SparkSuggestionData({required this.text, required this.sourceId});

  final String text;

  /// Provenance id: a generation UUID (AI) or the static-bank entry id.
  final String sourceId;
}

/// Shared behavior for both Spark conditions: cadence timing, one-at-a-time
/// display, Accept/Reject handling, and full event logging. This is what makes
/// the two arms *matched* — only [nextSuggestion] (the hint source) and
/// [sparkType]/[aiGenerated] differ between subclasses.
abstract class BaseSparkSession extends SparkSession {
  BaseSparkSession({
    required this.condition,
    required SparkEventSink logger,
    required StudyConfig config,
    Uuid? uuid,
  })  : _logger = logger,
        _config = config,
        _uuid = uuid ?? const Uuid();

  final StudyCondition condition;
  final SparkEventSink _logger;
  final StudyConfig _config;
  final Uuid _uuid;

  /// Subclass identity.
  SparkType get sparkType;
  bool get aiGenerated;

  /// Produces the next suggestion for [context], or null if none is available
  /// (e.g. the static bank is exhausted, or an AI call failed). Returning null
  /// simply means no card appears this cycle — the session continues.
  Future<SparkSuggestionData?> nextSuggestion(SparkContext context);

  // --- Configuration ------------------------------------------------------

  String _sessionId = '';
  String? _phaseId;
  int _intervalSeconds = 0;
  SparkContextProvider? _contextProvider;
  SuggestionAcceptedCallback? _onAccepted;

  // --- Runtime state ------------------------------------------------------

  int _secondsSinceLast = 0;
  bool _requesting = false;
  SparkSuggestion? _current;
  SparkEvent? _currentEvent;

  /// Texts already shown this session, to avoid repeats (study rule #7).
  final Set<String> _shownTexts = <String>{};
  Set<String> get shownTexts => _shownTexts;

  @override
  SparkSuggestion? get currentSuggestion => _current;

  @override
  void configureForPhase({
    required String sessionId,
    required PhaseType phaseType,
    required String? phaseId,
    required SparkContextProvider contextProvider,
    required SuggestionAcceptedCallback onSuggestionAccepted,
  }) {
    _sessionId = sessionId;
    _phaseId = phaseId;
    _contextProvider = contextProvider;
    _onAccepted = onSuggestionAccepted;
    // Suggestions only appear in the divergent and convergent phases; the
    // cadence comes from the (possibly pilot-scaled) study config.
    _intervalSeconds = _config.sparkIntervalSeconds(phaseType);
    _secondsSinceLast = 0;
    _current = null;
    _currentEvent = null;
  }

  @override
  void onTick(int remainingSeconds) {
    if (_intervalSeconds <= 0) return;
    // Don't stack suggestions: wait for a response before the next one.
    if (_current != null || _requesting) return;
    _secondsSinceLast++;
    if (_secondsSinceLast >= _intervalSeconds) {
      _secondsSinceLast = 0;
      _requestNext();
    }
  }

  Future<void> _requestNext() async {
    final provider = _contextProvider;
    if (provider == null) return;
    _requesting = true;
    try {
      final data = await nextSuggestion(provider());
      if (data == null) return;
      if (_shownTexts.contains(data.text)) return; // skip a repeat
      _shownTexts.add(data.text);

      final now = DateTime.now();
      final event = SparkEvent(
        eventId: _uuid.v4(),
        sessionId: _sessionId,
        phaseId: _phaseId,
        condition: condition,
        sparkType: sparkType,
        suggestionText: data.text,
        suggestionSourceId: data.sourceId,
        shownAt: now,
      );
      await _logger.save(event);

      _currentEvent = event;
      _current = SparkSuggestion(text: data.text, aiGenerated: aiGenerated);
      notifyListeners();
    } finally {
      _requesting = false;
    }
  }

  @override
  Future<void> accept() async {
    final event = _currentEvent;
    final suggestion = _current;
    if (event == null || suggestion == null) return;

    await _logger.save(event.copyWith(
      response: SparkResponse.accepted,
      respondedAt: DateTime.now(),
      addedToIdeaList: true,
    ));
    await _onAccepted?.call(suggestion.text, aiGenerated);
    _clearCurrent();
  }

  @override
  Future<void> reject() async {
    final event = _currentEvent;
    if (event == null) return;

    await _logger.save(event.copyWith(
      response: SparkResponse.rejected,
      respondedAt: DateTime.now(),
      addedToIdeaList: false,
    ));
    _clearCurrent();
  }

  void _clearCurrent() {
    _current = null;
    _currentEvent = null;
    _secondsSinceLast = 0;
    notifyListeners();
  }
}
