/// Facilitator-facing research overview drawn from the Spark study plan.
/// Shown on the login screen info button — not visible to children.
class ResearchGuideSection {
  const ResearchGuideSection({
    required this.title,
    this.body,
    this.bullets = const [],
  });

  final String title;
  final String? body;
  final List<String> bullets;
}

class ResearchGuide {
  ResearchGuide._();

  static const String title = 'Spark Research Guide';
  static const String subtitle =
      'A tablet-based study of AI-assisted creativity in children (ages 8–11)';

  static const List<ResearchGuideSection> sections = [
    ResearchGuideSection(
      title: 'Core research question',
      body:
          'How does adaptive AI suggestion support affect children\'s independent '
          'creative development compared with matched non-generative hint support '
          'over a 10-week drawing intervention?',
    ),
    ResearchGuideSection(
      title: 'Plain-language purpose',
      body:
          'The study asks whether AI help makes children more creative over time, '
          'or whether it makes their work more polished but less original and more '
          'similar to each other.',
    ),
    ResearchGuideSection(
      title: 'Study design',
      bullets: [
        'Population: children ages 8–11',
        'Duration: 10 weeks, one 15-minute session per week',
        'Design: between-subjects — AI-Spark vs Static-Spark control',
        'Pre/post testing: inside the app, no Spark hints for either group',
        'Primary concern: does AI improve creativity, or make ideas more similar?',
        'Scoring: TTCT-trained raters for pre/post; blind artifact ratings recommended',
      ],
    ),
    ResearchGuideSection(
      title: 'The two conditions',
      bullets: [
        'AI-Spark: Spark gives one timed text hint at a time. Hints are generated '
            'adaptively by a language model from the prompt, idea list, and session context.',
        'Static-Spark: Spark uses the same timer, bubble, and Accept/Reject interface, '
            'but hints come from a pre-written bank — no live generation.',
        'Both groups use the same app, prompts, timing, drawing tools, and data capture. '
            'Only the hint source differs.',
      ],
    ),
    ResearchGuideSection(
      title: 'Research questions',
      bullets: [
        'RQ1: Does AI-Spark improve independent creative development from pre-test to post-test?',
        'RQ2: Does AI-Spark increase weekly idea generation, originality, and elaboration?',
        'RQ3: Does AI-Spark make children\'s ideas and drawings more similar over time?',
        'RQ4: Does accepting more Spark suggestions predict creativity, ownership, or similarity?',
        'RQ5: Do AI-Spark children report different ownership, creativity, and perceived support?',
      ],
    ),
    ResearchGuideSection(
      title: 'Study flow (facilitator)',
      bullets: [
        'Facilitator login → create or select participant → assign condition',
        'Child assent and game intro',
        'In-app pre-test (no Spark support)',
        'Weekly sessions: Weeks 1–10',
        'In-app post-test (no Spark support)',
        'Export package for scoring and analysis',
      ],
    ),
    ResearchGuideSection(
      title: 'Weekly 15-minute session',
      bullets: [
        'Prompt intro (1 min) — child sees the weekly challenge',
        'Divergent phase (6 min) — brainstorm ideas; Spark hints on a timer',
        'Selection (1 min) — child picks one favorite idea to develop',
        'Convergent phase (6 min) — develop final drawing; Spark refinement hints',
        'Reflection (1 min) — three 1–5 ratings (ownership, creativity, helpfulness)',
      ],
    ),
    ResearchGuideSection(
      title: 'Spark design rules',
      bullets: [
        'Spark is a friendly game helper — never labeled as AI to the child',
        'One suggestion at a time with Accept or Reject',
        'Accepted hints are added to the idea list and logged',
        'Spark never changes the child\'s drawing directly',
        'Facilitator and backend know the assigned condition; the child does not',
      ],
    ),
    ResearchGuideSection(
      title: 'Pre-test and post-test',
      bullets: [
        'Completed inside the app with no Spark, AI, or static hints for either group',
        'Measures whether creativity improves without the helper present (transfer)',
        'Use parallel TTCT-style drawing tasks with similar difficulty',
        'Scored by TTCT-trained raters, blind to condition when possible',
      ],
    ),
    ResearchGuideSection(
      title: 'Data captured',
      bullets: [
        'Participant ID, age group, condition (no child names stored)',
        'Idea lists, hint events (shown / accepted / rejected), timestamps',
        'Drawing snapshots and final artifacts',
        'Reflection ratings and facilitator notes',
        'Export: CSV logs, images, manifest, and checksums',
      ],
    ),
    ResearchGuideSection(
      title: 'Child reflection questions',
      bullets: [
        'How much does this feel like YOUR idea? (ownership)',
        'How creative do you think your idea is? (self-perception)',
        'How much did the hints help you? (perceived support)',
        'Same wording in both conditions so children cannot guess their group',
      ],
    ),
    ResearchGuideSection(
      title: 'Ethics and privacy',
      bullets: [
        'Participant IDs only — no child names in stored or exported data',
        'Child-facing language is simple, positive, and non-evaluative',
        'Spark never criticizes a drawing or tells a child an idea is bad',
        'Sessions save locally first; export securely after the session',
        'Any images sent to an AI service are low-resolution and de-identified',
      ],
    ),
    ResearchGuideSection(
      title: 'Using this app',
      body:
          'Tap Enter to open the facilitator console. Create participants (condition '
          'can auto-balance between arms), run pre-test, weekly sessions, and post-test '
          'from the session menu, then export data from the download icon. Use Pilot '
          'mode only for testing — it compresses session timings.',
    ),
  ];
}
