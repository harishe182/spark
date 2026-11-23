import 'package:flutter/foundation.dart';

import '../core/enums.dart';

/// Callback the controller supplies so an accepted suggestion is added to the
/// child's idea list with the correct source (AI vs static).
typedef SuggestionAcceptedCallback = Future<void> Function(
    String text, bool aiGenerated);

/// Supplies the live session state needed to produce a suggestion. The
/// controller builds one of these on demand; the AI provider serializes it
/// (minus any identity) into its request, and the static provider uses only
/// the prompt id. Deliberately contains NO child-identifying information.
class SparkContext {
  const SparkContext({
    required this.promptId,
    required this.promptText,
    required this.phaseType,
    required this.ideaList,
    required this.acceptedSuggestions,
    required this.rejectedSuggestions,
    required this.remainingSeconds,
    this.selectedIdea,
  });

  final String promptId;
  final String promptText;
  final PhaseType phaseType;
  final List<String> ideaList;
  final List<String> acceptedSuggestions;
  final List<String> rejectedSuggestions;
  final int remainingSeconds;
  final String? selectedIdea;
}

typedef SparkContextProvider = SparkContext Function();

/// A single suggestion currently offered to the child.
class SparkSuggestion {
  const SparkSuggestion({required this.text, required this.aiGenerated});

  final String text;
  final bool aiGenerated;
}

/// Contract between the session controller and the Spark subsystem. A
/// [SparkSession] decides *when* to surface a suggestion (driven by
/// [onTick]) and *what* it is; the UI listens to it to render the Accept/
/// Reject card. The concrete AI and static implementations share an identical
/// cadence and logging path (see [BaseSparkSession]) so the two study
/// conditions are behaviorally matched.
abstract class SparkSession extends ChangeNotifier {
  SparkSuggestion? get currentSuggestion;

  /// Called at the start of each phase. Implementations use this to reset
  /// cadence, learn where to route accepted suggestions, and capture the
  /// context provider for building suggestions.
  void configureForPhase({
    required String sessionId,
    required PhaseType phaseType,
    required String? phaseId,
    required SparkContextProvider contextProvider,
    required SuggestionAcceptedCallback onSuggestionAccepted,
  });

  /// Called once per second with the phase's remaining time.
  void onTick(int remainingSeconds);

  Future<void> accept();

  Future<void> reject();
}

/// A Spark session that never shows anything. Used for pre/post tests and as a
/// safe default. (The weekly flow uses the real providers from Phase 3.)
class NoopSparkSession extends SparkSession {
  @override
  SparkSuggestion? get currentSuggestion => null;

  @override
  void configureForPhase({
    required String sessionId,
    required PhaseType phaseType,
    required String? phaseId,
    required SparkContextProvider contextProvider,
    required SuggestionAcceptedCallback onSuggestionAccepted,
  }) {}

  @override
  void onTick(int remainingSeconds) {}

  @override
  Future<void> accept() async {}

  @override
  Future<void> reject() async {}
}
