import 'package:uuid/uuid.dart';

import '../models/facilitator_note.dart';
import 'storage_service.dart';

/// Saves optional facilitator observations (engagement rating + free text).
class FacilitatorNoteService {
  FacilitatorNoteService(this._storage, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final StorageService _storage;
  final Uuid _uuid;

  Future<FacilitatorNote> save({
    required String sessionId,
    int? engagementRating,
    String? qualitativeNotes,
    String? createdBy,
  }) async {
    final note = FacilitatorNote(
      noteId: _uuid.v4(),
      sessionId: sessionId,
      engagementRating: engagementRating,
      qualitativeNotes: qualitativeNotes,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
    await _storage.insertFacilitatorNote(note);
    return note;
  }
}
