import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../core/enums.dart';
import '../core/spark_config.dart';
import 'base_spark_session.dart';
import 'spark_session.dart';

/// AI-Spark: generates one adaptive suggestion via the Google Gemini API,
/// using only non-identifying session state. Inherits identical timing,
/// display, accept/reject, and logging from [BaseSparkSession]; only the hint
/// *source* differs from the static arm.
///
/// Privacy: the request contains the prompt, the current idea list, accepted/
/// rejected suggestions, phase, and time remaining — and NEVER the child's
/// name, age, participant id, or any identifier (study requirement).
///
/// Resilience: any network/parse failure (including a missing API key or an
/// offline tablet) returns null, so the session simply shows no card that
/// cycle instead of erroring.
class AiSparkSession extends BaseSparkSession {
  AiSparkSession({
    required super.logger,
    required super.config,
    required SparkConfig apiConfig,
    http.Client? client,
    Uuid? uuid,
  })  : _apiConfig = apiConfig,
        _client = client ?? http.Client(),
        _uuid = uuid ?? const Uuid(),
        super(condition: StudyCondition.aiSpark);

  final SparkConfig _apiConfig;
  final http.Client _client;
  final Uuid _uuid;

  @override
  SparkType get sparkType => SparkType.aiGenerated;

  @override
  bool get aiGenerated => true;

  @override
  Future<SparkSuggestionData?> nextSuggestion(SparkContext context) async {
    if (!_apiConfig.hasApiKey) {
      debugPrint('AiSparkSession: no Gemini API key configured; skipping.');
      return null;
    }
    try {
      final body = jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': _systemPrompt}
          ]
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': _userPrompt(context)}
            ]
          }
        ],
        'generationConfig': {
          'maxOutputTokens': 64,
          'temperature': 0.9,
          // gemini-2.5 models "think" before answering, and that reasoning
          // consumes the output-token budget. With a small cap the thinking
          // ate it all, truncating the hint to one word (finishReason
          // MAX_TOKENS). Disable thinking so the short hint comes through.
          'thinkingConfig': {'thinkingBudget': 0},
        },
      });

      final response = await _client
          .post(
            _apiConfig.generateUri,
            headers: {
              'Content-Type': 'application/json',
              // Key sent as a header (not in the URL) to avoid leaking it in
              // request logs.
              'x-goog-api-key': _apiConfig.geminiApiKey,
            },
            body: body,
          )
          .timeout(_apiConfig.requestTimeout);

      if (response.statusCode != 200) {
        debugPrint('AiSparkSession: HTTP ${response.statusCode}: ${response.body}');
        return null;
      }

      final text = _extractText(response.body);
      if (text == null || text.isEmpty) return null;

      return SparkSuggestionData(text: _sanitize(text), sourceId: _uuid.v4());
    } catch (e) {
      debugPrint('AiSparkSession: suggestion failed: $e');
      return null;
    }
  }

  /// Pulls the first candidate's text out of a Gemini generateContent response.
  static String? _extractText(String responseBody) {
    final decoded = jsonDecode(responseBody) as Map<String, Object?>;
    final candidates = decoded['candidates'] as List<Object?>?;
    if (candidates == null || candidates.isEmpty) return null;
    final content =
        (candidates.first as Map<String, Object?>)['content'] as Map<String, Object?>?;
    final parts = content?['parts'] as List<Object?>?;
    if (parts == null || parts.isEmpty) return null;
    return (parts.first as Map<String, Object?>)['text'] as String?;
  }

  /// Strips surrounding quotes/markdown the model sometimes adds.
  String _sanitize(String text) {
    var t = text.trim();
    if (t.startsWith('"') && t.endsWith('"') && t.length > 1) {
      t = t.substring(1, t.length - 1).trim();
    }
    return t;
  }

  /// Encodes the suggestion rules from the study brief.
  static const String _systemPrompt = '''
You are "Spark", a playful idea helper for a children's drawing game (ages 8-11).
Give ONE tiny, simple hint that nudges the child's own creativity.
Rules:
- Keep it VERY short: 4 to 8 words, one sentence.
- Use easy words a 7-year-old knows. No big or fancy words.
- A short question ("What if...?") or a gentle "Try..." works well.
- Nudge originality, detail, combining things, setting, or a surprise — but
  never give a full drawing plan or say exactly what to draw.
- Never use copyrighted characters or franchise names.
- Never judge or say their idea is bad. Do not mention AI.
- Output only the hint text. No quotes, no preamble.

Good examples:
- "What if it could fly?"
- "Add a tiny secret door."
- "Give it a funny hat!"
- "What sound does it make?"''';

  String _userPrompt(SparkContext context) {
    final ideas = context.ideaList.isEmpty
        ? '(none yet)'
        : context.ideaList.join('; ');
    final phase = context.phaseType == PhaseType.convergent
        ? 'drawing their chosen idea'
        : 'brainstorming ideas';
    final already = (context.acceptedSuggestions + context.rejectedSuggestions)
        .toSet()
        .join('; ');

    return [
      'Drawing prompt: ${context.promptText}',
      'The child is currently $phase.',
      if (context.selectedIdea != null)
        'Chosen idea: ${context.selectedIdea}',
      'Their idea list: $ideas',
      if (already.isNotEmpty) 'Already suggested (do NOT repeat): $already',
      'Give one fresh suggestion.',
    ].join('\n');
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
