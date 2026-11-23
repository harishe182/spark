import 'package:uuid/uuid.dart';

import '../core/enums.dart';
import '../models/idea.dart';
import 'storage_service.dart';

/// Manages the child's idea list for a session: adding child-authored ideas,
/// adding accepted Spark suggestions, marking the chosen favorite, and
/// persisting each change immediately.
class IdeaListService {
  IdeaListService(this._storage, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final StorageService _storage;
  final Uuid _uuid;

  Future<List<Idea>> ideasFor(String sessionId) =>
      _storage.getIdeasForSession(sessionId);

  /// Adds a child-authored idea and returns it.
  Future<Idea> addChildIdea({
    required String sessionId,
    String? phaseId,
    required String text,
  }) {
    return _add(
      sessionId: sessionId,
      phaseId: phaseId,
      text: text,
      source: IdeaSource.child,
    );
  }

  /// Adds an accepted Spark suggestion to the idea list. [aiGenerated]
  /// selects the correct source label so reliance can be analyzed per arm.
  Future<Idea> addAcceptedSuggestion({
    required String sessionId,
    String? phaseId,
    required String text,
    required bool aiGenerated,
  }) {
    return _add(
      sessionId: sessionId,
      phaseId: phaseId,
      text: text,
      source: aiGenerated
          ? IdeaSource.aiSparkAccepted
          : IdeaSource.staticSparkAccepted,
    );
  }

  Future<Idea> _add({
    required String sessionId,
    String? phaseId,
    required String text,
    required IdeaSource source,
  }) async {
    final idea = Idea(
      ideaId: _uuid.v4(),
      sessionId: sessionId,
      phaseId: phaseId,
      ideaText: text,
      source: source,
      createdAt: DateTime.now(),
    );
    await _storage.upsertIdea(idea);
    return idea;
  }

  /// Marks exactly one idea as the favorite for the final drawing, clearing
  /// the flag on all others in the session.
  Future<void> selectFavorite({
    required String sessionId,
    required String ideaId,
  }) async {
    final ideas = await _storage.getIdeasForSession(sessionId);
    for (final idea in ideas) {
      final shouldSelect = idea.ideaId == ideaId;
      if (idea.selectedForFinal != shouldSelect) {
        await _storage.upsertIdea(
          idea.copyWith(selectedForFinal: shouldSelect),
        );
      }
    }
  }

  /// Toggles the [selectedForFinal] flag on a single idea, leaving the others
  /// untouched. Used for multi-select — the child can mark one or more ideas
  /// to develop in the drawing phase.
  Future<void> toggleSelectedForFinal({
    required String sessionId,
    required String ideaId,
  }) async {
    final ideas = await _storage.getIdeasForSession(sessionId);
    for (final idea in ideas) {
      if (idea.ideaId == ideaId) {
        await _storage.upsertIdea(
          idea.copyWith(selectedForFinal: !idea.selectedForFinal),
        );
        return;
      }
    }
  }
}
