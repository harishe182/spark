import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/enums.dart';
import '../models/drawing_artifact.dart';
import 'storage_service.dart';

/// Persists drawing images to the filesystem and records their metadata.
///
/// The drawing canvas itself is `flutter_drawing_board`'s `DrawingController`
/// (wrapped by `DrawingCanvasWidget`). This service takes the exported PNG
/// bytes and: (1) writes them under the app's documents dir, (2) computes a
/// SHA-256 checksum for export integrity, (3) inserts a [DrawingArtifact] row.
class DrawingService {
  DrawingService(this._storage, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final StorageService _storage;
  final Uuid _uuid;

  static const _uuidGen = Uuid();

  /// Root directory for all drawing images, created on demand.
  Future<Directory> _artifactsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'artifacts'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Saves [pngBytes] as an artifact of [type] for [sessionId]/[phaseId] and
  /// records it. Returns the persisted [DrawingArtifact].
  Future<DrawingArtifact> saveArtifact({
    required String sessionId,
    String? phaseId,
    required ArtifactType type,
    required Uint8List pngBytes,
  }) async {
    final artifactId = _uuid.v4();
    final fileName = '${sessionId}_${type.value}_$artifactId.png';

    // Web preview only: path_provider / the filesystem are unavailable in the
    // browser, so we skip the PNG write and just record metadata (checksum
    // still computed) to keep the session flow and DB consistent. Native
    // tablets write the file normally.
    if (!kIsWeb) {
      final dir = await _artifactsDir();
      final file = File(p.join(dir.path, fileName));
      await file.writeAsBytes(pngBytes, flush: true);
    }

    final artifact = DrawingArtifact(
      artifactId: artifactId,
      sessionId: sessionId,
      phaseId: phaseId,
      artifactType: type,
      imagePath: p.join('artifacts', fileName),
      createdAt: DateTime.now(),
      checksum: sha256.convert(pngBytes).toString(),
    );
    await _storage.insertArtifact(artifact);
    return artifact;
  }

  /// Convenience id generator for callers that need a stable artifact id
  /// before bytes exist (e.g. preallocating a snapshot slot).
  static String newArtifactId() => _uuidGen.v4();
}
