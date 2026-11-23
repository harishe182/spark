import '../models/sync_record.dart';
import 'storage_service.dart';

/// Outcome of a sync attempt, surfaced to the UI.
class SyncOutcome {
  const SyncOutcome({
    this.synced = 0,
    this.failed = 0,
    this.skipped = 0,
    this.reason,
  });

  final int synced;
  final int failed;
  final int skipped;

  /// Why nothing happened (e.g. "waiting for Wi-Fi", "sync disabled").
  final String? reason;
}

/// Contract for cloud sync. Implementations: [NoopSyncService] (Firebase not
/// configured) and `FirebaseSyncService`. Callers always enqueue a completed
/// session; whether/when it actually uploads is the implementation's concern.
abstract interface class SyncService {
  /// Whether a cloud backend is configured and initialized.
  bool get isAvailable;

  /// Records that [sessionId] needs uploading and best-effort attempts it.
  Future<void> enqueue(String sessionId);

  /// Attempts to upload all pending/failed sessions, subject to the opt-out
  /// toggle and the Wi-Fi gate.
  Future<SyncOutcome> syncPending();

  /// Current counts by status, for the export-screen badge.
  Future<Map<SyncStatus, int>> statusCounts();
}

/// Used when Firebase is not configured. Still maintains a durable pending
/// queue locally, so once Firebase is wired up those sessions can be uploaded.
class NoopSyncService implements SyncService {
  NoopSyncService(this._storage);

  final StorageService _storage;

  @override
  bool get isAvailable => false;

  @override
  Future<void> enqueue(String sessionId) async {
    await _storage.upsertSyncRecord(SyncRecord(
      sessionId: sessionId,
      status: SyncStatus.pending,
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<SyncOutcome> syncPending() async {
    final pending = await _storage.getSyncRecordsByStatus(SyncStatus.pending);
    return SyncOutcome(
      skipped: pending.length,
      reason: 'Cloud sync not configured',
    );
  }

  @override
  Future<Map<SyncStatus, int>> statusCounts() => _storage.syncStatusCounts();
}
