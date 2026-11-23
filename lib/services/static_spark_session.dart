import '../core/enums.dart';
import '../core/static_hint_bank.dart';
import 'base_spark_session.dart';
import 'spark_session.dart';

/// Static-Spark control: draws non-repeating hints from a pre-written,
/// prompt-specific bank. It inherits ALL timing, display, accept/reject, and
/// logging behavior from [BaseSparkSession] — the only difference from
/// AI-Spark is where the text comes from.
class StaticSparkSession extends BaseSparkSession {
  StaticSparkSession({required super.logger, required super.config})
      : super(condition: StudyCondition.staticSpark);

  @override
  SparkType get sparkType => SparkType.staticBank;

  @override
  bool get aiGenerated => false;

  @override
  Future<SparkSuggestionData?> nextSuggestion(SparkContext context) async {
    final hints = StaticHintBank.forPrompt(context.promptId);
    for (var i = 0; i < hints.length; i++) {
      final hint = hints[i];
      if (!shownTexts.contains(hint)) {
        return SparkSuggestionData(
          text: hint,
          sourceId: '${context.promptId}#$i',
        );
      }
    }
    return null; // bank exhausted — no card this cycle
  }
}
