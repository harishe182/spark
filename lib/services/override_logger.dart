import 'package:uuid/uuid.dart';

import '../models/override_event.dart';
import 'storage_service.dart';

/// Records facilitator overrides of session flow for the audit trail. Every
/// manual phase advance or extension must pass through here (study
/// requirement: overrides must be visible and logged).
class OverrideLogger {
  OverrideLogger(this._storage, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final StorageService _storage;
  final Uuid _uuid;

  Future<OverrideEvent> log({
    required String sessionId,
    String? phaseId,
    required String action,
    String? detail,
  }) async {
    final event = OverrideEvent(
      overrideId: _uuid.v4(),
      sessionId: sessionId,
      phaseId: phaseId,
      action: action,
      detail: detail,
      createdAt: DateTime.now(),
    );
    await _storage.insertOverrideEvent(event);
    return event;
  }
}
