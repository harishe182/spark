import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:spark/core/enums.dart';
import 'package:spark/core/spark_config.dart';
import 'package:spark/core/study_config.dart';
import 'package:spark/models/spark_event.dart';
import 'package:spark/services/ai_spark_session.dart';
import 'package:spark/services/spark_event_logger.dart';
import 'package:spark/services/spark_session.dart';

class _CaptureSink implements SparkEventSink {
  final List<SparkEvent> events = [];
  @override
  Future<void> save(SparkEvent event) async => events.add(event);
}

SparkContext _ctx() => const SparkContext(
      promptId: 'week_01',
      promptText: 'Imagine a friendly helper.',
      phaseType: PhaseType.divergent,
      ideaList: ['a robot dog'],
      acceptedSuggestions: [],
      rejectedSuggestions: [],
      remainingSeconds: 200,
      selectedIdea: null,
    );

AiSparkSession _session(http.Client client, {String key = 'test-key'}) {
  return AiSparkSession(
    logger: _CaptureSink(),
    config: StudyConfig.defaults(),
    apiConfig: SparkConfig(geminiApiKey: key),
    client: client,
  );
}

/// Builds a minimal Gemini generateContent response body.
String _geminiResponse(String text) => jsonEncode({
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': text}
            ]
          }
        }
      ]
    });

void main() {
  test('sends prompt + ideas but NO participant identity', () async {
    String? capturedBody;
    final client = MockClient((req) async {
      capturedBody = req.body;
      return http.Response(_geminiResponse('What if it could glow?'), 200);
    });

    final session = _session(client);
    final result = await session.nextSuggestion(_ctx());

    expect(result, isNotNull);
    expect(result!.text, 'What if it could glow?');
    // Privacy: the request must not carry any participant identifier.
    expect(capturedBody, isNotNull);
    expect(capturedBody, isNot(contains('P001')));
    expect(capturedBody!.toLowerCase(), isNot(contains('participant')));
    // But it SHOULD carry the creative context.
    expect(capturedBody, contains('a robot dog'));
  });

  test('strips wrapping quotes from the model output', () async {
    final client = MockClient((req) async =>
        http.Response(_geminiResponse('"Add a hidden power."'), 200));
    final result = await _session(client).nextSuggestion(_ctx());
    expect(result!.text, 'Add a hidden power.');
  });

  test('sends the API key as a header, not in the URL', () async {
    String? capturedKeyHeader;
    Uri? capturedUrl;
    final client = MockClient((req) async {
      capturedKeyHeader = req.headers['x-goog-api-key'];
      capturedUrl = req.url;
      return http.Response(_geminiResponse('idea'), 200);
    });
    await _session(client, key: 'secret-key').nextSuggestion(_ctx());
    expect(capturedKeyHeader, 'secret-key');
    // Key must not leak into the request URL.
    expect(capturedUrl.toString(), isNot(contains('secret-key')));
  });

  test('returns null (no card) on HTTP error — graceful offline behavior',
      () async {
    final client = MockClient((req) async => http.Response('nope', 500));
    expect(await _session(client).nextSuggestion(_ctx()), isNull);
  });

  test('returns null when no API key is configured', () async {
    final client = MockClient((req) async => http.Response('{}', 200));
    final result = await _session(client, key: '').nextSuggestion(_ctx());
    expect(result, isNull);
  });

  test('is labeled as AI-generated for the correct condition', () {
    final session = _session(MockClient((req) async => http.Response('{}', 200)));
    expect(session.aiGenerated, isTrue);
    expect(session.sparkType, SparkType.aiGenerated);
    expect(session.condition, StudyCondition.aiSpark);
  });
}
