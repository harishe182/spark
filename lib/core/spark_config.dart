/// Runtime configuration for the AI-Spark provider (Google Gemini).
///
/// The API key is NEVER hardcoded. It is supplied at build/run time via a
/// dart-define file:
///
///   flutter run --dart-define-from-file=.env
///
/// where `.env` contains `GEMINI_API_KEY=...` (and optionally `GEMINI_MODEL`).
///
/// If the key is absent, [hasApiKey] is false and the AI provider degrades
/// gracefully (it simply shows no suggestion) rather than crashing or leaking.
class SparkConfig {
  const SparkConfig({
    required this.geminiApiKey,
    this.model = 'gemini-2.5-flash',
    this.baseUrl =
        'https://generativelanguage.googleapis.com/v1beta/models',
    this.requestTimeout = const Duration(seconds: 8),
  });

  final String geminiApiKey;
  final String model;
  final String baseUrl;
  final Duration requestTimeout;

  bool get hasApiKey => geminiApiKey.isNotEmpty;

  /// Full endpoint for a non-streaming generate call on the configured model.
  Uri get generateUri => Uri.parse('$baseUrl/$model:generateContent');

  /// Builds config from compile-time environment defines.
  factory SparkConfig.fromEnvironment() {
    return const SparkConfig(
      geminiApiKey: String.fromEnvironment('GEMINI_API_KEY'),
      model: String.fromEnvironment(
        'GEMINI_MODEL',
        defaultValue: 'gemini-2.5-flash',
      ),
    );
  }
}
