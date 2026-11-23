import 'enums.dart';

/// A creativity prompt shown to the child. [id] is stored on the session so
/// exports can group artifacts by prompt.
class Prompt {
  const Prompt({required this.id, required this.title, required this.body});

  final String id;
  final String title;
  final String body;
}

/// Static prompt bank. Pre-test and post-test use *parallel* (different but
/// matched) tasks so independent creativity can be measured before and after
/// without practice effects from an identical prompt. Weekly prompts are
/// indexed 1–10. Wording is child-friendly and franchise-free.
class PromptBank {
  PromptBank._();

  static const Prompt preTest = Prompt(
    id: 'pre_test',
    title: 'Invent a Creature',
    body: 'Draw a brand-new creature that nobody has ever seen before. '
        'It can look any way you like!',
  );

  static const Prompt postTest = Prompt(
    id: 'post_test',
    title: 'Invent a Vehicle',
    body: 'Draw a brand-new vehicle that nobody has ever seen before. '
        'It can travel any way you like!',
  );

  static const List<Prompt> weekly = <Prompt>[
    Prompt(id: 'week_01', title: 'A Helpful Robot Friend', body: 'Imagine a friendly helper. What can it do?'),
    Prompt(id: 'week_02', title: 'A Magical Plant', body: 'Invent a plant with a special power.'),
    Prompt(id: 'week_03', title: 'A New Kind of Home', body: 'Design a home unlike any other.'),
    Prompt(id: 'week_04', title: 'An Underwater City', body: 'Imagine a city beneath the waves.'),
    Prompt(id: 'week_05', title: 'A Brand-New Game', body: 'Invent a game and how to play it.'),
    Prompt(id: 'week_06', title: 'A Floating Island', body: 'Picture an island in the sky.'),
    Prompt(id: 'week_07', title: 'A Wild New Food', body: 'Invent a food no one has tasted.'),
    Prompt(id: 'week_08', title: 'A Tiny World', body: 'Imagine a whole world that fits in your hand.'),
    Prompt(id: 'week_09', title: 'A Helpful Invention', body: 'Invent something that solves a problem.'),
    Prompt(id: 'week_10', title: 'A Surprising Machine', body: 'Design a machine that does something unexpected.'),
  ];

  /// Returns the prompt for a given mode and (for weekly) week number 1–10.
  static Prompt forSession(SessionMode mode, {int? weekNumber}) {
    switch (mode) {
      case SessionMode.preTest:
        return preTest;
      case SessionMode.postTest:
        return postTest;
      case SessionMode.weeklySession:
        final idx = (weekNumber ?? 1).clamp(1, weekly.length) - 1;
        return weekly[idx];
    }
  }
}
