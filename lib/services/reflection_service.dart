import 'package:uuid/uuid.dart';

import '../models/reflection.dart';
import 'storage_service.dart';

/// Records the child's three end-of-session reflection ratings (1–5).
class ReflectionService {
  ReflectionService(this._storage, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final StorageService _storage;
  final Uuid _uuid;

  Future<Reflection> save({
    required String sessionId,
    required int ownershipRating,
    required int creativityRating,
    required int hintHelpfulnessRating,
  }) async {
    final reflection = Reflection(
      reflectionId: _uuid.v4(),
      sessionId: sessionId,
      ownershipRating: ownershipRating,
      creativityRating: creativityRating,
      hintHelpfulnessRating: hintHelpfulnessRating,
      createdAt: DateTime.now(),
    );
    await _storage.insertReflection(reflection);
    return reflection;
  }
}
