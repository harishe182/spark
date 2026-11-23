import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:uuid/uuid.dart';

import '../core/enums.dart';
import '../core/phase_plan.dart';
import '../core/prompts.dart';
import '../core/study_config.dart';
import '../models/idea.dart';
import '../models/participant.dart';
import '../models/phase.dart';
import '../models/session.dart';
import '../services/drawing_service.dart';
import '../services/facilitator_note_service.dart';
import '../services/idea_list_service.dart';
import '../services/override_logger.dart';
import '../services/reflection_service.dart';
import '../services/session_service.dart';
import '../services/spark_session.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

/// Orchestrates one weekly session end-to-end: phase progression, the visible
/// countdown timer, the idea list, periodic drawing snapshots, reflection, and
/// facilitator overrides. UI listens via [ChangeNotifier].
///
/// Spark is integrated through the injected [SparkSession] (Phase 3). In
/// Phase 2 a [NoopSparkSession] is passed so the full flow works without
/// suggestions; swapping in the real providers requires no controller change.
class WeeklySessionController extends ChangeNotifier {
  WeeklySessionController({
    required this.participant,
    required this.weekNumber,
    required this.promptId,
    required SessionService sessionService,
    required StorageService storage,
    required IdeaListService ideaService,
    required DrawingService drawingService,
    required ReflectionService reflectionService,
    required FacilitatorNoteService noteService,
    required OverrideLogger overrideLogger,
    required SyncService syncService,
    required this.spark,
    required this.config,
    Uuid? uuid,
  })  : _sessionService = sessionService,
        _storage = storage,
        _ideaService = ideaService,
        _drawingService = drawingService,
        _reflectionService = reflectionService,
        _noteService = noteService,
        _overrideLogger = overrideLogger,
        _syncService = syncService,
        _uuid = uuid ?? const Uuid(),
        _steps = config.weeklySteps();

  final Participant participant;
  final int weekNumber;
  final String promptId;

  final SessionService _sessionService;
  final StorageService _storage;
  final IdeaListService _ideaService;
  final DrawingService _drawingService;
  final ReflectionService _reflectionService;
  final FacilitatorNoteService _noteService;
  final OverrideLogger _overrideLogger;
  final SyncService _syncService;
  final SparkSession spark;
  final StudyConfig config;
  final Uuid _uuid;

  /// The drawing surface for the convergent phase; owned here so snapshots and
  /// the final export can be taken without the screen being mounted.
  final DrawingController drawingController = DrawingController();

  final List<PhaseStep> _steps;

  Session? _session;
  Session? get session => _session;

  int _stepIndex = 0;
  Phase? _currentPhase;
  Phase? get currentPhase => _currentPhase;
  PhaseType get currentPhaseType => _steps[_stepIndex].type;
  int get stepIndex => _stepIndex;
  int get totalSteps => _steps.length;

  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;

  Timer? _ticker;
  Timer? _snapshotTimer;

  List<Idea> _ideas = const [];
  List<Idea> get ideas => List.unmodifiable(_ideas);

  /// Ids of ideas the child marked to develop in the drawing phase. Multiple
  /// selections are allowed.
  Set<String> _selectedIdeaIds = const {};
  Set<String> get selectedIdeaIds => _selectedIdeaIds;

  /// The selected ideas (in list order), for showing what will be drawn.
  List<Idea> get selectedIdeas =>
      _ideas.where((i) => _selectedIdeaIds.contains(i.ideaId)).toList();

  bool _finished = false;
  bool get finished => _finished;

  // --- Lifecycle ----------------------------------------------------------

  Future<void> start() async {
    _session = await _sessionService.startSession(
      participantId: participant.participantId,
      mode: SessionMode.weeklySession,
      weekNumber: weekNumber,
      promptId: promptId,
    );
    await _beginPhase(0);
  }

  Future<void> _beginPhase(int index) async {
    _stepIndex = index;
    final step = _steps[index];
    final phase = Phase(
      phaseId: _uuid.v4(),
      sessionId: _session!.sessionId,
      phaseType: step.type,
      startTime: DateTime.now(),
    );
    _currentPhase = phase;
    await _storage.upsertPhase(phase);

    _remainingSeconds = step.defaultSeconds;
    _startTicker();
    _configureSparkForPhase(step.type);
    _configureSnapshotsForPhase(step.type);

    await _refreshIdeas();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        advancePhase();
        return;
      }
      _remainingSeconds--;
      spark.onTick(_remainingSeconds);
      notifyListeners();
    });
  }

  void _configureSparkForPhase(PhaseType type) {
    spark.configureForPhase(
      sessionId: _session!.sessionId,
      phaseType: type,
      phaseId: _currentPhase?.phaseId,
      contextProvider: _buildSparkContext,
      onSuggestionAccepted: _onSparkAccepted,
    );
  }

  /// Snapshot of non-identifying session state for the Spark provider. Contains
  /// no child identity (privacy requirement).
  SparkContext _buildSparkContext() {
    final prompt = PromptBank.forSession(
      SessionMode.weeklySession,
      weekNumber: weekNumber,
    );
    final accepted = _ideas
        .where((i) => i.source != IdeaSource.child)
        .map((i) => i.ideaText)
        .toList();
    // One or more ideas may be selected; join them for the Spark context.
    final selectedTexts =
        selectedIdeas.map((i) => i.ideaText).toList();
    final selected =
        selectedTexts.isEmpty ? null : selectedTexts.join(', ');
    return SparkContext(
      promptId: prompt.id,
      promptText: prompt.body,
      phaseType: currentPhaseType,
      ideaList: _ideas.map((i) => i.ideaText).toList(),
      acceptedSuggestions: accepted,
      rejectedSuggestions: const [],
      remainingSeconds: _remainingSeconds,
      selectedIdea: selected,
    );
  }

  void _configureSnapshotsForPhase(PhaseType type) {
    _snapshotTimer?.cancel();
    if (type == PhaseType.convergent) {
      _snapshotTimer = Timer.periodic(
        Duration(seconds: config.snapshotIntervalSeconds),
        (_) => captureSnapshot(),
      );
    }
  }

  /// Advances to the next phase. [manual] true means the facilitator forced
  /// it; that is logged to the audit trail and counted on the session.
  Future<void> advancePhase({bool manual = false}) async {
    if (_finished) return;
    final completing = _currentPhase;
    if (completing != null) {
      final done = completing.complete(DateTime.now());
      _currentPhase = done;
      await _storage.upsertPhase(done);
    }
    if (manual && _session != null) {
      await _overrideLogger.log(
        sessionId: _session!.sessionId,
        phaseId: completing?.phaseId,
        action: 'advance_phase',
        detail: 'from ${completing?.phaseType.value}',
      );
      _session = _session!.copyWith(
        facilitatorOverrideCount: _session!.facilitatorOverrideCount + 1,
      );
      await _storage.upsertSession(_session!);
    }

    final next = _stepIndex + 1;
    if (next >= _steps.length) {
      await _finish();
    } else {
      await _beginPhase(next);
    }
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    _snapshotTimer?.cancel();
    // Persist the final drawing if the child reached the drawing phase.
    await saveFinalDrawing();
    if (_session != null) {
      _session = await _sessionService.completeSession(_session!);
      await _syncService.enqueue(_session!.sessionId);
    }
    _finished = true;
    notifyListeners();
  }

  /// Facilitator ends the session early. The partial work is saved, the
  /// session is marked abandoned, and the action is logged to the audit trail.
  Future<void> abandon() async {
    if (_finished) return;
    _ticker?.cancel();
    _snapshotTimer?.cancel();
    if (_session != null) {
      await _overrideLogger.log(
        sessionId: _session!.sessionId,
        phaseId: _currentPhase?.phaseId,
        action: 'abandon_session',
        detail: 'ended during ${currentPhaseType.value}',
      );
      await saveFinalDrawing();
      _session = await _sessionService.abandonSession(_session!);
      await _syncService.enqueue(_session!.sessionId);
    }
    _finished = true;
    notifyListeners();
  }

  // --- Idea list ----------------------------------------------------------

  Future<void> _refreshIdeas() async {
    if (_session == null) return;
    _ideas = await _ideaService.ideasFor(_session!.sessionId);
    _selectedIdeaIds = _ideas
        .where((i) => i.selectedForFinal)
        .map((i) => i.ideaId)
        .toSet();
  }

  Future<void> addChildIdea(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _session == null) return;
    await _ideaService.addChildIdea(
      sessionId: _session!.sessionId,
      phaseId: _currentPhase?.phaseId,
      text: trimmed,
    );
    await _refreshIdeas();
    notifyListeners();
  }

  /// Toggles whether [ideaId] is one of the ideas the child will draw. The
  /// child may select one or more.
  Future<void> toggleSelected(String ideaId) async {
    if (_session == null) return;
    await _ideaService.toggleSelectedForFinal(
      sessionId: _session!.sessionId,
      ideaId: ideaId,
    );
    await _refreshIdeas();
    notifyListeners();
  }

  Future<void> _onSparkAccepted(String text, bool aiGenerated) async {
    if (_session == null) return;
    await _ideaService.addAcceptedSuggestion(
      sessionId: _session!.sessionId,
      phaseId: _currentPhase?.phaseId,
      text: text,
      aiGenerated: aiGenerated,
    );
    await _refreshIdeas();
    notifyListeners();
  }

  // --- Drawing snapshots / final -----------------------------------------

  Future<void> captureSnapshot() async {
    if (_session == null) return;
    final bytes = await _exportPng();
    if (bytes == null) return;
    await _drawingService.saveArtifact(
      sessionId: _session!.sessionId,
      phaseId: _currentPhase?.phaseId,
      type: ArtifactType.snapshot,
      pngBytes: bytes,
    );
  }

  Future<void> saveFinalDrawing() async {
    if (_session == null) return;
    final bytes = await _exportPng();
    if (bytes == null) return;
    await _drawingService.saveArtifact(
      sessionId: _session!.sessionId,
      phaseId: _currentPhase?.phaseId,
      type: ArtifactType.finalDrawing,
      pngBytes: bytes,
    );
  }

  Future<Uint8List?> _exportPng() async {
    final data = await drawingController.getImageData();
    if (data == null) return null;
    return data.buffer.asUint8List();
  }

  // --- Reflection / notes -------------------------------------------------

  Future<void> saveReflection({
    required int ownership,
    required int creativity,
    required int helpfulness,
  }) async {
    if (_session == null) return;
    await _reflectionService.save(
      sessionId: _session!.sessionId,
      ownershipRating: ownership,
      creativityRating: creativity,
      hintHelpfulnessRating: helpfulness,
    );
  }

  Future<void> saveFacilitatorNote({
    int? engagement,
    String? notes,
  }) async {
    if (_session == null) return;
    if (engagement == null && (notes == null || notes.trim().isEmpty)) return;
    await _noteService.save(
      sessionId: _session!.sessionId,
      engagementRating: engagement,
      qualitativeNotes: notes?.trim(),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _snapshotTimer?.cancel();
    spark.dispose();
    drawingController.dispose();
    super.dispose();
  }
}
