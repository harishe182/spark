import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/sync_record.dart';
import 'connectivity_service.dart';
import 'settings_service.dart';
import 'storage_service.dart';
import 'sync_service.dart';

/// Uploads completed sessions' structured records to Firestore. Best-effort
/// and resumable via the local [SyncRecord] queue.
///
/// Firestore-only (free plan): drawing images are NOT uploaded to Cloud
/// Storage (that requires the Blaze plan). Artifact *metadata* is still synced
/// so the record is complete; the actual PNGs stay local and reach the
/// researcher via the local export. Image upload can be enabled later by
/// upgrading to Blaze and restoring Storage upload here.
///
/// Gates (all must pass to upload): Firebase initialized, a signed-in user
/// (anonymous auth), the sync opt-out is OFF, and an unmetered (Wi-Fi)
/// connection is present. Relies on Firebase at-rest encryption + security
/// rules (firestore.rules); client-side encryption is a planned hardening step.
///
/// Privacy: only participant IDs (never names) are stored, consistent with the
/// rest of the app.
class FirebaseSyncService implements SyncService {
  FirebaseSyncService({
    required StorageService storage,
    required ConnectivityService connectivity,
    required SettingsService settings,
  })  : _storage = storage,
        _connectivity = connectivity,
        _settings = settings;

  final StorageService _storage;
  final ConnectivityService _connectivity;
  final SettingsService _settings;

  @override
  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Ensures an (anonymous) signed-in user, since the security rules require
  /// authentication. Returns false if sign-in is unavailable (e.g. the
  /// Anonymous provider isn't enabled yet).
  Future<bool> _ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return true;
    try {
      await auth.signInAnonymously();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> enqueue(String sessionId) async {
    await _storage.upsertSyncRecord(SyncRecord(
      sessionId: sessionId,
      status: SyncStatus.pending,
      updatedAt: DateTime.now(),
    ));
    // Best-effort immediate attempt; failures stay queued for later.
    try {
      await syncPending();
    } catch (_) {
      // Swallowed: the durable queue will retry on the next trigger.
    }
  }

  @override
  Future<SyncOutcome> syncPending() async {
    if (!isAvailable) {
      return const SyncOutcome(reason: 'Cloud sync not configured');
    }
    if (!await _settings.isSyncEnabled()) {
      return const SyncOutcome(reason: 'Cloud sync turned off');
    }
    if (!await _connectivity.isOnWifi()) {
      return const SyncOutcome(reason: 'Waiting for Wi-Fi');
    }
    if (!await _ensureSignedIn()) {
      return const SyncOutcome(reason: 'Not signed in');
    }

    // Retry failed sessions alongside pending ones.
    final due = [
      ...await _storage.getSyncRecordsByStatus(SyncStatus.pending),
      ...await _storage.getSyncRecordsByStatus(SyncStatus.failed),
    ];

    var synced = 0;
    var failed = 0;
    for (final record in due) {
      try {
        await _uploadSession(record.sessionId);
        await _storage.upsertSyncRecord(record.copyWith(
          status: SyncStatus.synced,
          updatedAt: DateTime.now(),
        ));
        synced++;
      } catch (e) {
        await _storage.upsertSyncRecord(record.copyWith(
          status: SyncStatus.failed,
          updatedAt: DateTime.now(),
          error: '$e',
        ));
        failed++;
      }
    }
    return SyncOutcome(synced: synced, failed: failed);
  }

  @override
  Future<Map<SyncStatus, int>> statusCounts() => _storage.syncStatusCounts();

  Future<void> _uploadSession(String sessionId) async {
    final sessions = await _storage.getAllSessions();
    final session = sessions.firstWhere((s) => s.sessionId == sessionId);
    final participant = await _storage.getParticipant(session.participantId);
    if (participant == null) {
      throw StateError('Participant ${session.participantId} not found');
    }

    final phases = await _storage.getPhasesForSession(sessionId);
    final ideas = await _storage.getIdeasForSession(sessionId);
    final sparkEvents = await _storage.getSparkEventsForSession(sessionId);
    final artifacts = await _storage.getArtifactsForSession(sessionId);
    final reflection = await _storage.getReflectionForSession(sessionId);
    final notes = await _storage.getNotesForSession(sessionId);
    final overrides = await _storage.getOverrideEventsForSession(sessionId);

    // Participant doc (no names — IDs only).
    await _db
        .collection('participants')
        .doc(participant.participantId)
        .set(participant.toMap(), SetOptions(merge: true));

    // Firestore-only: sync artifact metadata (checksum, type, local path) but
    // NOT the image bytes — Cloud Storage requires the Blaze plan. The PNGs
    // reach the researcher via the local export.
    final artifactMaps = [for (final a in artifacts) a.toMap()];

    await _db.collection('sessions').doc(sessionId).set({
      'participant_id': session.participantId,
      'condition': participant.assignedCondition.value,
      'session': session.toMap(),
      'phases': [for (final x in phases) x.toMap()],
      'ideas': [for (final x in ideas) x.toMap()],
      'spark_events': [for (final x in sparkEvents) x.toMap()],
      'reflection': reflection?.toMap(),
      'facilitator_notes': [for (final x in notes) x.toMap()],
      'override_events': [for (final x in overrides) x.toMap()],
      'artifacts': artifactMaps,
      'synced_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
