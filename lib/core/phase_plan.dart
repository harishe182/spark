import 'constants.dart';
import 'enums.dart';

/// One step in a session's ordered phase sequence, with its default duration.
class PhaseStep {
  const PhaseStep(this.type, this.defaultSeconds);

  final PhaseType type;
  final int defaultSeconds;
}

/// Defines the ordered phases for each session mode and their default
/// durations. Weekly sessions run the full five-phase 15-minute structure;
/// pre/post tests are a single independent drawing block (handled by their own
/// screen, included here for completeness).
class PhasePlan {
  PhasePlan._();

  static const List<PhaseStep> weekly = <PhaseStep>[
    PhaseStep(PhaseType.intro, SessionTiming.introSeconds),
    PhaseStep(PhaseType.divergent, SessionTiming.divergentSeconds),
    PhaseStep(PhaseType.selection, SessionTiming.selectionSeconds),
    PhaseStep(PhaseType.convergent, SessionTiming.convergentSeconds),
    PhaseStep(PhaseType.reflection, SessionTiming.reflectionSeconds),
  ];

  static List<PhaseStep> forMode(SessionMode mode) {
    switch (mode) {
      case SessionMode.weeklySession:
        return weekly;
      case SessionMode.preTest:
      case SessionMode.postTest:
        return const [
          PhaseStep(PhaseType.convergent, SessionTiming.testDrawingSeconds),
        ];
    }
  }

  /// Total planned duration (seconds) for a mode.
  static int totalSeconds(SessionMode mode) =>
      forMode(mode).fold(0, (sum, step) => sum + step.defaultSeconds);
}
