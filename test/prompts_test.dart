import 'package:flutter_test/flutter_test.dart';
import 'package:spark/core/enums.dart';
import 'package:spark/core/prompts.dart';

/// Pre/post tests must use *parallel but different* prompts, and weekly weeks
/// must map to distinct prompts — both are study-design requirements.
void main() {
  test('pre-test and post-test prompts differ', () {
    expect(PromptBank.preTest.id, isNot(PromptBank.postTest.id));
  });

  test('forSession returns the right prompt per mode', () {
    expect(PromptBank.forSession(SessionMode.preTest).id, 'pre_test');
    expect(PromptBank.forSession(SessionMode.postTest).id, 'post_test');
    expect(
      PromptBank.forSession(SessionMode.weeklySession, weekNumber: 3).id,
      'week_03',
    );
  });

  test('there are exactly 10 unique weekly prompts', () {
    expect(PromptBank.weekly.length, 10);
    final ids = PromptBank.weekly.map((p) => p.id).toSet();
    expect(ids.length, 10);
  });

  test('weekly week numbers are clamped to valid range', () {
    expect(PromptBank.forSession(SessionMode.weeklySession, weekNumber: 0).id,
        'week_01');
    expect(PromptBank.forSession(SessionMode.weeklySession, weekNumber: 99).id,
        'week_10');
  });
}
