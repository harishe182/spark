/// Pre-written static hint bank for the Static-Spark control condition.
///
/// Hints are prompt-specific (3–5 per prompt) plus a shared generic pool used
/// as a fallback once prompt-specific hints are exhausted. They follow the
/// same authoring rules as AI-Spark suggestions: one short, non-judgmental,
/// open-ended nudge that encourages originality, detail, combination,
/// setting, function, or surprise — never a complete drawing plan, never a
/// franchise reference.
class StaticHintBank {
  StaticHintBank._();

  /// Generic hints, applicable to any prompt. Mirrors the example bank in the
  /// study brief.
  static const List<String> generic = <String>[
    'Try adding a surprising detail.',
    'Think about where your idea lives.',
    'Can you combine two things?',
    'What makes your idea different?',
    'Add a special ability.',
    'Add a problem your idea solves.',
    'Add a detail someone might not expect.',
    'Think about how your idea moves.',
    'Add something tiny.',
    'Add something huge.',
    'Give your idea a special job.',
    'Add a secret feature.',
  ];

  /// Prompt-specific hints keyed by prompt id (see `PromptBank`).
  static const Map<String, List<String>> byPrompt = <String, List<String>>{
    'week_01': [
      'What is one kind thing your helper could do?',
      'Where does your helper go when it rests?',
      'Give your helper a surprising way to move.',
    ],
    'week_02': [
      'What happens when someone touches your plant?',
      'Where would this plant grow best?',
      'Give your plant a power no real plant has.',
    ],
    'week_03': [
      'What is the most unusual room in this home?',
      'How do you get inside?',
      'What keeps the home safe?',
    ],
    'week_04': [
      'How do people travel around your underwater city?',
      'What lights up the city down there?',
      'What is the city famous for?',
    ],
    'week_05': [
      'How does a player win your game?',
      'What is one surprising rule?',
      'What do you need to play it?',
    ],
    'week_06': [
      'What holds your island up in the sky?',
      'Who or what lives on it?',
      'How would you reach it?',
    ],
    'week_07': [
      'What does your new food taste like?',
      'What color is it inside?',
      'When would someone eat it?',
    ],
    'week_08': [
      'What lives in your tiny world?',
      'What is the weather like there?',
      'How would you visit it?',
    ],
    'week_09': [
      'What problem does your invention solve?',
      'Who would use it the most?',
      'What is its most surprising part?',
    ],
    'week_10': [
      'What unexpected thing does your machine do?',
      'What sound does it make?',
      'What powers it?',
    ],
    // Pre/post tests have NO Spark, so no entries are needed for them.
  };

  /// Returns hints for [promptId] followed by the generic pool, in a stable
  /// order. The session picks the first not-yet-shown entry.
  static List<String> forPrompt(String promptId) {
    return [...(byPrompt[promptId] ?? const []), ...generic];
  }
}
