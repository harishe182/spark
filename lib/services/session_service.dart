import 'package:uuid/uuid.dart';

import '../core/enums.dart';
import '../models/session.dart';
import 'storage_service.dart';

/// Creates and updates [Session] records. In Phase 1 this covers the minimal
/// lifecycle needed for pre/post tests (start → complete). Phase 2 extends it
/// with phase orchestration for weekly sessions.
class SessionService {
  SessionService(this._storage, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final StorageService _storage;
  final Uuid _uuid;

  /// Starts a new session for [participantId] in [mode], persisting an
  /// in-progress record immediately so an interrupted session is recoverable.
  Future<Session> startSession({
    required String participantId,
    required SessionMode mode,
    int? weekNumber,
    String? promptId,
  }) async {
    final session = Session(
      sessionId: _uuid.v4(),
      participantId: participantId,
      mode: mode,
      weekNumber: mode == SessionMode.weeklySession ? weekNumber : null,
      promptId: promptId,
      startTime: DateTime.now(),
      endTime: null,
      completionStatus: CompletionStatus.inProgress,
    );
    await _storage.upsertSession(session);
    return session;
  }

  /// Marks [session] completed with an end time.
  Future<Session> completeSession(Session session) async {
    final updated = session.copyWith(
      endTime: DateTime.now(),
      completionStatus: CompletionStatus.completed,
    );
    await _storage.upsertSession(updated);
    return updated;
  }

  /// Marks [session] abandoned (ended early) with an end time.
  Future<Session> abandonSession(Session session) async {
    final updated = session.copyWith(
      endTime: DateTime.now(),
      completionStatus: CompletionStatus.abandoned,
    );
    await _storage.upsertSession(updated);
    return updated;
  }

  Future<List<Session>> sessionsFor(String participantId) =>
      _storage.getSessionsForParticipant(participantId);
}
