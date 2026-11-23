import 'storage_service.dart';

/// Small persisted key/value settings. Currently holds the cloud-sync opt-out
/// so the choice survives app restarts.
class SettingsService {
  SettingsService(this._storage);

  final StorageService _storage;

  static const String _syncEnabledKey = 'cloud_sync_enabled';

  /// Cloud sync defaults to ON (opt-out model, per the approved plan).
  Future<bool> isSyncEnabled() async {
    final raw = await _storage.getSetting(_syncEnabledKey);
    return raw == null ? true : raw == 'true';
  }

  Future<void> setSyncEnabled(bool enabled) =>
      _storage.setSetting(_syncEnabledKey, enabled ? 'true' : 'false');
}
