import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/weekly_session_controller.dart';
import '../core/enums.dart';
import '../core/prompts.dart';
import '../models/participant.dart';
import '../providers/providers.dart';
import '../widgets/child_friendly_timer.dart';
import '../widgets/glass/glass.dart';
import '../widgets/spark_suggestion_card.dart';
import 'phases/convergent_phase_view.dart';
import 'phases/divergent_phase_view.dart';
import 'phases/intro_phase_view.dart';
import 'phases/reflection_phase_view.dart';
import 'phases/selection_phase_view.dart';
import 'phases/session_complete_view.dart';

/// Hosts one weekly session. Owns the [WeeklySessionController] for its
/// lifetime, renders the facilitator timer bar plus the current phase view,
/// and overlays the Spark suggestion card whenever one is active.
class WeeklySessionScreen extends ConsumerStatefulWidget {
  const WeeklySessionScreen({
    super.key,
    required this.participant,
    required this.weekNumber,
  });

  final Participant participant;
  final int weekNumber;

  @override
  ConsumerState<WeeklySessionScreen> createState() =>
      _WeeklySessionScreenState();
}

class _WeeklySessionScreenState extends ConsumerState<WeeklySessionScreen> {
  late final WeeklySessionController _controller;

  @override
  void initState() {
    super.initState();
    final prompt = PromptBank.forSession(
      SessionMode.weeklySession,
      weekNumber: widget.weekNumber,
    );
    _controller = WeeklySessionController(
      participant: widget.participant,
      weekNumber: widget.weekNumber,
      promptId: prompt.id,
      sessionService: ref.read(sessionServiceProvider),
      storage: ref.read(storageServiceProvider),
      ideaService: ref.read(ideaListServiceProvider),
      drawingService: ref.read(drawingServiceProvider),
      reflectionService: ref.read(reflectionServiceProvider),
      noteService: ref.read(facilitatorNoteServiceProvider),
      overrideLogger: ref.read(overrideLoggerProvider),
      syncService: ref.read(syncServiceProvider),
      spark: buildSparkForCondition(ref, widget.participant.assignedCondition),
      config: ref.read(studyConfigProvider),
    );
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = PromptBank.forSession(
      SessionMode.weeklySession,
      weekNumber: widget.weekNumber,
    );

    return PopScope(
      canPop: false,
      child: GlassScaffold(
        safeArea: false,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([_controller, _controller.spark]),
            builder: (context, _) {
              if (_controller.session == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.finished) {
                return SessionCompleteView(controller: _controller);
              }
              return Column(
                children: [
                  FacilitatorTimerBar(
                    phaseLabel: _phaseLabel(_controller.currentPhaseType),
                    stepIndex: _controller.stepIndex,
                    totalSteps: _controller.totalSteps,
                    remainingSeconds: _controller.remainingSeconds,
                    onAdvance: () =>
                        _controller.advancePhase(manual: true),
                    onEndEarly: _confirmEndEarly,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        _phaseView(prompt.title, prompt.body),
                        _sparkOverlay(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _phaseView(String promptTitle, String promptBody) {
    switch (_controller.currentPhaseType) {
      case PhaseType.intro:
        return IntroPhaseView(
          title: promptTitle,
          body: promptBody,
          remainingSeconds: _controller.remainingSeconds,
          totalSeconds: _controller.config.introSeconds,
          onReady: () => _controller.advancePhase(manual: true),
        );
      case PhaseType.divergent:
        return DivergentPhaseView(controller: _controller, prompt: promptTitle);
      case PhaseType.selection:
        return SelectionPhaseView(controller: _controller);
      case PhaseType.convergent:
        return ConvergentPhaseView(controller: _controller, prompt: promptTitle);
      case PhaseType.reflection:
        return ReflectionPhaseView(controller: _controller);
    }
  }

  Widget _sparkOverlay() {
    final suggestion = _controller.spark.currentSuggestion;
    if (suggestion == null) return const SizedBox.shrink();
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: SparkSuggestionCard(
        suggestion: suggestion,
        onAccept: _controller.spark.accept,
        onReject: _controller.spark.reject,
      ),
    );
  }

  Future<void> _confirmEndEarly() async {
    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => GlassActionDialog(
        title: 'End session early?',
        message:
            'Progress so far will be saved and the session marked as ended '
            'early. This action is logged.',
        actions: [
          GlassDialogAction(
            label: 'Keep going',
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          GlassDialogAction(
            label: 'End early',
            destructive: true,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _controller.abandon();
    }
  }

  String _phaseLabel(PhaseType type) {
    switch (type) {
      case PhaseType.intro:
        return 'Intro';
      case PhaseType.divergent:
        return 'Ideas';
      case PhaseType.selection:
        return 'Pick Favorite';
      case PhaseType.convergent:
        return 'Drawing';
      case PhaseType.reflection:
        return 'Reflection';
    }
  }
}
