import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums.dart';
import '../core/spark_config.dart';
import '../core/study_config.dart';
import '../models/participant.dart';
import '../services/ai_spark_session.dart';
import '../services/drawing_service.dart';
import '../services/export_service.dart';
import '../services/facilitator_note_service.dart';
import '../services/idea_list_service.dart';
import '../services/override_logger.dart';
import '../services/participant_service.dart';
import '../services/reflection_service.dart';
import '../services/session_service.dart';
import '../services/connectivity_service.dart';
import '../services/firebase_sync_service.dart';
import '../services/settings_service.dart';
import '../services/spark_event_logger.dart';
import '../services/spark_session.dart';
import '../services/static_spark_session.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

/// Riverpod wiring. The [storageServiceProvider] is overridden at app startup
/// (in main.dart) with the concrete, already-opened encrypted database, so
/// the rest of the tree can depend on it synchronously.
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
    'storageServiceProvider must be overridden in ProviderScope',
  );
});

final participantServiceProvider = Provider<ParticipantService>((ref) {
  return ParticipantService(ref.watch(storageServiceProvider));
});

final drawingServiceProvider = Provider<DrawingService>((ref) {
  return DrawingService(ref.watch(storageServiceProvider));
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(ref.watch(storageServiceProvider));
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(storageServiceProvider));
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(storageServiceProvider));
});

/// Whether Firebase initialized successfully. Overridden at startup in main.
/// Defaults to false so the app runs (offline) before `flutterfire configure`.
final firebaseAvailableProvider = Provider<bool>((ref) => false);

/// Picks the real Firebase sync when available, else a no-op that still keeps a
/// durable local queue (so sessions upload once Firebase is configured).
final syncServiceProvider = Provider<SyncService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  if (ref.watch(firebaseAvailableProvider)) {
    return FirebaseSyncService(
      storage: storage,
      connectivity: ref.watch(connectivityServiceProvider),
      settings: ref.watch(settingsServiceProvider),
    );
  }
  return NoopSyncService(storage);
});

/// The cloud-sync opt-out toggle, persisted via [SettingsService].
class SyncEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true; // opt-out model: default on
  }

  Future<void> _load() async {
    state = await ref.read(settingsServiceProvider).isSyncEnabled();
  }

  Future<void> set(bool value) async {
    state = value;
    await ref.read(settingsServiceProvider).setSyncEnabled(value);
    if (value) {
      // Re-enabling should flush anything queued while it was off.
      await ref.read(syncServiceProvider).syncPending();
    }
  }
}

final syncEnabledProvider =
    NotifierProvider<SyncEnabledNotifier, bool>(SyncEnabledNotifier.new);

final ideaListServiceProvider = Provider<IdeaListService>((ref) {
  return IdeaListService(ref.watch(storageServiceProvider));
});

final reflectionServiceProvider = Provider<ReflectionService>((ref) {
  return ReflectionService(ref.watch(storageServiceProvider));
});

final facilitatorNoteServiceProvider = Provider<FacilitatorNoteService>((ref) {
  return FacilitatorNoteService(ref.watch(storageServiceProvider));
});

final overrideLoggerProvider = Provider<OverrideLogger>((ref) {
  return OverrideLogger(ref.watch(storageServiceProvider));
});

final sparkConfigProvider = Provider<SparkConfig>((ref) {
  return SparkConfig.fromEnvironment();
});

/// The base (un-scaled) study timing config. Overridden at startup if a JSON
/// config asset is present; defaults to the study-brief values otherwise.
final baseStudyConfigProvider = Provider<StudyConfig>((ref) {
  return StudyConfig.defaults();
});

/// Pilot mode toggle. When on, sessions run compressed timings for quick
/// dry-runs. Modern (non-legacy) Riverpod Notifier.
class PilotModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final pilotModeProvider =
    NotifierProvider<PilotModeNotifier, bool>(PilotModeNotifier.new);

/// The effective study config: base, or pilot-scaled when pilot mode is on.
final studyConfigProvider = Provider<StudyConfig>((ref) {
  final base = ref.watch(baseStudyConfigProvider);
  return ref.watch(pilotModeProvider) ? base.pilotScaled() : base;
});

final sparkEventLoggerProvider = Provider<SparkEventLogger>((ref) {
  return SparkEventLogger(ref.watch(storageServiceProvider));
});

/// Builds the correct Spark session for a participant's assigned condition.
/// This is the ONLY place the experimental arms diverge — everything
/// downstream (cadence, UI, logging) is shared. Used by the weekly session
/// screen's `sparkBuilder`.
SparkSession buildSparkForCondition(WidgetRef ref, StudyCondition condition) {
  final logger = ref.read(sparkEventLoggerProvider);
  final config = ref.read(studyConfigProvider);
  switch (condition) {
    case StudyCondition.aiSpark:
      return AiSparkSession(
        logger: logger,
        config: config,
        apiConfig: ref.read(sparkConfigProvider),
      );
    case StudyCondition.staticSpark:
      return StaticSparkSession(logger: logger, config: config);
  }
}

/// The list of all participants, refreshable after a create.
final participantListProvider =
    FutureProvider<List<Participant>>((ref) async {
  return ref.watch(participantServiceProvider).listParticipants();
});
