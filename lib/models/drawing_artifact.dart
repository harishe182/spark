import '../core/enums.dart';
import 'db_codec.dart';

/// Metadata for a saved drawing image (final drawing, periodic snapshot, or
/// pre/post-test artifact). The image bytes live on the filesystem at
/// [imagePath]; [checksum] guarantees export integrity.
class DrawingArtifact {
  const DrawingArtifact({
    required this.artifactId,
    required this.sessionId,
    required this.phaseId,
    required this.artifactType,
    required this.imagePath,
    required this.createdAt,
    this.thumbnailPath,
    this.checksum,
  });

  final String artifactId;
  final String sessionId;
  final String? phaseId;
  final ArtifactType artifactType;
  final String imagePath;
  final String? thumbnailPath;
  final DateTime createdAt;
  final String? checksum;

  DrawingArtifact copyWith({
    String? artifactId,
    String? sessionId,
    String? phaseId,
    ArtifactType? artifactType,
    String? imagePath,
    String? thumbnailPath,
    DateTime? createdAt,
    String? checksum,
  }) {
    return DrawingArtifact(
      artifactId: artifactId ?? this.artifactId,
      sessionId: sessionId ?? this.sessionId,
      phaseId: phaseId ?? this.phaseId,
      artifactType: artifactType ?? this.artifactType,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      checksum: checksum ?? this.checksum,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'artifact_id': artifactId,
      'session_id': sessionId,
      'phase_id': phaseId,
      'artifact_type': artifactType.value,
      'image_path': imagePath,
      'thumbnail_path': thumbnailPath,
      'created_at': DbCodec.dateToString(createdAt),
      'checksum': checksum,
    };
  }

  factory DrawingArtifact.fromMap(Map<String, Object?> map) {
    return DrawingArtifact(
      artifactId: map['artifact_id']! as String,
      sessionId: map['session_id']! as String,
      phaseId: map['phase_id'] as String?,
      artifactType: ArtifactType.fromValue(map['artifact_type']! as String),
      imagePath: map['image_path']! as String,
      thumbnailPath: map['thumbnail_path'] as String?,
      createdAt: DbCodec.stringToDate(map['created_at'])!,
      checksum: map['checksum'] as String?,
    );
  }

  static const String tableName = 'drawing_artifacts';

  static const String createTableSql = '''
    CREATE TABLE $tableName (
      artifact_id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      phase_id TEXT,
      artifact_type TEXT NOT NULL,
      image_path TEXT NOT NULL,
      thumbnail_path TEXT,
      created_at TEXT NOT NULL,
      checksum TEXT,
      FOREIGN KEY (session_id) REFERENCES sessions(session_id),
      FOREIGN KEY (phase_id) REFERENCES phases(phase_id)
    )
  ''';
}
