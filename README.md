# Spark — AI-Assisted Creativity Study App

A tablet-first Flutter app for a 10-week, between-subjects study of how adaptive
AI suggestions affect children's (ages 8–11) independent creative development,
compared with matched non-generative (static) hint support.

> **Research integrity is the core constraint.** The two study arms —
> **AI-Spark** and **Static-Spark** — are byte-identical in flow, timing, UI,
> and logging. The *only* difference is whether Spark's hints come from an LLM
> or a pre-written bank. The child never sees condition labels or any "AI"
> wording.

## Modes

| Mode | Spark? | Purpose |
|------|--------|---------|
| Pre-test | No | Baseline independent creativity (parallel prompt) |
| Weekly session ×10 | Yes (AI or static) | 15-min divergent→drawing session with Spark |
| Post-test | No | Independent creativity after the intervention |

## Architecture

```
lib/
  core/        enums, constants, prompts, theme, study_config, static_hint_bank, csv_writer
  models/      immutable records + SQLite mapping (participant, session, phase,
               idea, spark_event, drawing_artifact, reflection, facilitator_note, override_event)
  services/    storage (encrypted SQLite), participant/session/idea/reflection/
               note/export/drawing services, override logger,
               spark_session (abstraction) + base/static/ai Spark sessions
  controllers/ weekly_session_controller (phase + timer + spark orchestration)
  providers/   Riverpod wiring
  widgets/     spark_character, drawing_canvas, spark_suggestion_card,
               child_friendly_timer, reflection_rating_scale
  screens/     facilitator login, participant setup, session select, assent,
               independent (pre/post) test, weekly session + phase views, export
```

Key design seams:
- **`SparkSession`** abstraction → `BaseSparkSession` shares cadence + logging;
  only `AiSparkSession` / `StaticSparkSession` differ. This is what keeps the
  arms matched. The condition is chosen in exactly one place
  (`buildSparkForCondition` in `providers.dart`).
- **`StudyConfig`** holds all tunable timing; a pilot-scaled variant gives fast
  dry-runs. Loaded from `assets/config/study_config.json`.
- **`StorageService`** is offline-first encrypted SQLite (SQLCipher). All data
  lands locally first.

## Setup

```bash
flutter pub get
```

### Running (with AI-Spark enabled)

The OpenAI key is supplied at run time — never hardcoded:

```bash
flutter run --dart-define=OPENAI_API_KEY=sk-...   # optional: --dart-define=OPENAI_MODEL=gpt-4o-mini
```

Without a key, AI-Spark degrades gracefully (no suggestion shown); Static-Spark
is unaffected.

### Tests & analysis

```bash
flutter analyze
flutter test
```

### Building

```bash
flutter build apk   --dart-define=OPENAI_API_KEY=sk-...   # Android
flutter build ios   --dart-define=OPENAI_API_KEY=sk-...   # iOS
```

## Configuration

Edit `assets/config/study_config.json` to retune phase durations and Spark
cadence after pilot testing. Omitted fields fall back to study-brief defaults.
**Pilot mode** (compressed timings for testing) is toggled in-app on the
session-select screen.

## Documentation

- [Facilitator guide](docs/FACILITATOR_GUIDE.md) — running sessions.
- [Researcher guide](docs/RESEARCHER_GUIDE.md) — exports and analysis.
- [Security checklist](docs/SECURITY_CHECKLIST.md) — privacy/HIPAA-FERPA.

## Privacy

No child names are stored — participant IDs only (`P001`…). LLM requests carry
only non-identifying creative context (prompt, idea list, phase, time). All
artifacts stay local until a facilitator-approved export.

## Firebase setup for this public copy

The Firebase client API keys are placeholders. Run `flutterfire configure` with your own Firebase project before using cloud sync. Supply your Gemini key locally with `--dart-define-from-file=.env` when running AI-Spark.
