import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/csv_writer.dart';
import 'session_summary.dart';
import 'storage_service.dart';

/// Result of an export run, surfaced to the facilitator UI.
class ExportResult {
  const ExportResult({
    required this.directoryPath,
    required this.fileCount,
    required this.checksum,
    required this.blind,
  });

  final String directoryPath;
  final int fileCount;

  /// SHA-256 over the manifest, giving the whole export one integrity hash.
  final String checksum;
  final bool blind;
}

/// Builds research-ready exports from local storage:
///  * `data.json`     — full structured records for every participant/session.
///  * `summary.csv`   — one analysis row per session ([SessionSummary]).
///  * `images/`       — all drawing artifacts.
///  * `manifest.json` — file list with per-file checksums + export metadata.
///
/// [exportBlind] additionally produces a rater-safe bundle: drawings renamed
/// to opaque codes with NO condition or participant id, plus a separate
/// `blind_key.csv` that the researcher keeps to un-blind later.
class ExportService {
  ExportService(this._storage);

  final StorageService _storage;

  Future<Directory> _exportsRoot() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'exports'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _artifactsRoot() async {
    final base = await getApplicationDocumentsDirectory();
    return Directory(p.join(base.path, 'artifacts'));
  }

  /// Full export with all data and images.
  Future<ExportResult> exportFull() async {
    final stamp = _stamp();
    final root = await _exportsRoot();
    final outDir = Directory(p.join(root.path, 'export_$stamp'));
    await outDir.create(recursive: true);
    final imagesDir = Directory(p.join(outDir.path, 'images'));
    await imagesDir.create();

    final participants = await _storage.getAllParticipants();
    final conditionById = {
      for (final pt in participants) pt.participantId: pt,
    };

    final jsonData = <String, Object?>{
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'participants': [for (final pt in participants) pt.toMap()],
      'sessions': <Object?>[],
    };
    final summaryRows = <List<Object?>>[SessionSummary.csvHeaders];
    final copiedImages = <String>[];

    final sessions = await _storage.getAllSessions();
    for (final session in sessions) {
      final participant = conditionById[session.participantId];
      if (participant == null) continue;

      final phases = await _storage.getPhasesForSession(session.sessionId);
      final ideas = await _storage.getIdeasForSession(session.sessionId);
      final sparkEvents =
          await _storage.getSparkEventsForSession(session.sessionId);
      final artifacts =
          await _storage.getArtifactsForSession(session.sessionId);
      final reflection =
          await _storage.getReflectionForSession(session.sessionId);
      final notes = await _storage.getNotesForSession(session.sessionId);
      final overrides =
          await _storage.getOverrideEventsForSession(session.sessionId);

      (jsonData['sessions'] as List<Object?>).add({
        'session': session.toMap(),
        'phases': [for (final x in phases) x.toMap()],
        'ideas': [for (final x in ideas) x.toMap()],
        'spark_events': [for (final x in sparkEvents) x.toMap()],
        'artifacts': [for (final x in artifacts) x.toMap()],
        'reflection': reflection?.toMap(),
        'facilitator_notes': [for (final x in notes) x.toMap()],
        'override_events': [for (final x in overrides) x.toMap()],
      });

      summaryRows.add(
        SessionSummary.fromData(
          session: session,
          ideas: ideas,
          sparkEvents: sparkEvents,
          phases: phases,
          reflection: reflection,
          condition: participant.assignedCondition,
        ).toCsvRow(),
      );

      for (final artifact in artifacts) {
        final copied =
            await _copyImage(artifact.imagePath, imagesDir, artifact.imagePath);
        if (copied != null) copiedImages.add(copied);
      }
    }

    await File(p.join(outDir.path, 'data.json'))
        .writeAsString(const JsonEncoder.withIndent('  ').convert(jsonData));
    await File(p.join(outDir.path, 'summary.csv'))
        .writeAsString(CsvWriter.toCsv(summaryRows));

    return _writeManifest(outDir, blind: false, extraImages: copiedImages);
  }

  /// Rater-safe blind export: images only, renamed to opaque codes, with NO
  /// condition or participant id exposed. A separate key file is written for
  /// the researcher to un-blind.
  Future<ExportResult> exportBlind() async {
    final stamp = _stamp();
    final root = await _exportsRoot();
    final outDir = Directory(p.join(root.path, 'blind_$stamp'));
    await outDir.create(recursive: true);
    final imagesDir = Directory(p.join(outDir.path, 'images'));
    await imagesDir.create();

    final sessions = await _storage.getAllSessions();
    final blindManifest = <Map<String, Object?>>[];
    final keyRows = <List<Object?>>[
      ['blind_code', 'participant_id', 'condition', 'session_id', 'mode'],
    ];
    final participants = await _storage.getAllParticipants();
    final byId = {for (final pt in participants) pt.participantId: pt};

    var counter = 0;
    for (final session in sessions) {
      final participant = byId[session.participantId];
      if (participant == null) continue;
      final artifacts =
          await _storage.getArtifactsForSession(session.sessionId);

      for (final artifact in artifacts) {
        counter++;
        final blindCode = 'A${counter.toString().padLeft(4, '0')}';
        final ext = p.extension(artifact.imagePath);
        final blindName = '$blindCode$ext';
        await _copyImage(artifact.imagePath, imagesDir, blindName);

        // Rater-facing: no condition, no participant id.
        blindManifest.add({
          'blind_code': blindCode,
          'artifact_type': artifact.artifactType.value,
          'image': 'images/$blindName',
        });
        // Researcher-only key (kept separate from rater bundle).
        keyRows.add([
          blindCode,
          participant.participantId,
          participant.assignedCondition.value,
          session.sessionId,
          session.mode.value,
        ]);
      }
    }

    await File(p.join(outDir.path, 'blind_manifest.json')).writeAsString(
        const JsonEncoder.withIndent('  ').convert(blindManifest));
    await File(p.join(outDir.path, 'blind_key.csv'))
        .writeAsString(CsvWriter.toCsv(keyRows));

    return _writeManifest(outDir, blind: true);
  }

  /// Copies a stored artifact image into [destDir] under [destName] (which may
  /// include subpaths — only the basename is used). Returns the basename, or
  /// null if the source is missing.
  Future<String?> _copyImage(
      String relativeSourcePath, Directory destDir, String destName) async {
    final artifactsRoot = await _artifactsRoot();
    // Stored paths look like 'artifacts/<file>'; resolve to the real file.
    final fileName = p.basename(relativeSourcePath);
    final source = File(p.join(artifactsRoot.path, fileName));
    if (!await source.exists()) return null;
    final outName = p.basename(destName);
    await source.copy(p.join(destDir.path, outName));
    return outName;
  }

  /// Walks [outDir], hashes every file, and writes `manifest.json`. The
  /// returned [ExportResult.checksum] is a hash over those per-file hashes.
  Future<ExportResult> _writeManifest(
    Directory outDir, {
    required bool blind,
    List<String> extraImages = const [],
  }) async {
    final files = <Map<String, Object?>>[];
    final hashes = <String>[];

    await for (final entity in outDir.list(recursive: true)) {
      if (entity is! File) continue;
      if (p.basename(entity.path) == 'manifest.json') continue;
      final bytes = await entity.readAsBytes();
      final hash = sha256.convert(bytes).toString();
      hashes.add(hash);
      files.add({
        'path': p.relative(entity.path, from: outDir.path),
        'bytes': bytes.length,
        'checksum': hash,
      });
    }

    hashes.sort();
    final manifestChecksum =
        sha256.convert(utf8.encode(hashes.join())).toString();

    final manifest = {
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'blind': blind,
      'file_count': files.length,
      'checksum': manifestChecksum,
      'files': files,
    };
    await File(p.join(outDir.path, 'manifest.json')).writeAsString(
        const JsonEncoder.withIndent('  ').convert(manifest));

    return ExportResult(
      directoryPath: outDir.path,
      fileCount: files.length,
      checksum: manifestChecksum,
      blind: blind,
    );
  }

  String _stamp() => DateTime.now()
      .toUtc()
      .toIso8601String()
      .replaceAll(RegExp(r'[:.]'), '-');
}
