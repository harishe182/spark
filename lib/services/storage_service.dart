import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../core/constants.dart';
import '../models/drawing_artifact.dart';
import '../models/facilitator_note.dart';
import '../models/idea.dart';
import '../models/override_event.dart';
import '../models/participant.dart';
import '../models/phase.dart';
import '../models/reflection.dart';
import '../models/session.dart';
import '../models/spark_event.dart';
import '../models/sync_record.dart';

/// Owns the encrypted SQLite database (SQLCipher) and exposes typed CRUD for
/// each model. All research data lands here first (offline-first); cloud sync
/// (Firebase) is layered on top in a later phase.
///
/// Encryption: the database is opened with a passphrase. For MVP the
/// passphrase is supplied by the caller; Phase 5 will move key custody into
/// platform secure storage (Keychain / Keystore) — see plan §Phase 5.
class StorageService {
  StorageService._(this._db);

  final Database _db;

  /// Exposes the raw database for advanced queries (e.g. export aggregation).
  Database get database => _db;

  /// Opens (creating if needed) the encrypted database with [passphrase].
  ///
  /// [overrideDirectory] lets tests point at a temp dir; production uses the
  /// app documents directory.
  static Future<StorageService> open({
    required String passphrase,
    String? overrideDirectory,
  }) async {
    // Web preview only: SQLCipher is native-only, so the browser uses an
    // UNENCRYPTED in-browser (IndexedDB-backed) database. This path is for
    // visual preview/testing — never for real participant data.
    if (kIsWeb) {
      final db = await databaseFactoryFfiWeb.openDatabase(
        AppInfo.dbFileName,
        options: OpenDatabaseOptions(
          version: AppInfo.dbVersion,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
          onCreate: _createSchema,
        ),
      );
      return StorageService._(db);
    }

    final dir =
        overrideDirectory ?? (await getApplicationDocumentsDirectory()).path;
    final dbPath = p.join(dir, AppInfo.dbFileName);

    final db = await openDatabase(
      dbPath,
      version: AppInfo.dbVersion,
      password: passphrase,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createSchema,
    );
    return StorageService._(db);
  }

  static Future<void> _createSchema(Database db, int version) async {
    const statements = <String>[
      Participant.createTableSql,
      Session.createTableSql,
      Phase.createTableSql,
      Idea.createTableSql,
      SparkEvent.createTableSql,
      DrawingArtifact.createTableSql,
      Reflection.createTableSql,
      FacilitatorNote.createTableSql,
      OverrideEvent.createTableSql,
      SyncRecord.createTableSql,
      _appSettingsTableSql,
    ];
    final batch = db.batch();
    for (final sql in statements) {
      batch.execute(sql);
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() => _db.close();

  // --- Participants -------------------------------------------------------

  Future<void> insertParticipant(Participant participant) async {
    await _db.insert(
      Participant.tableName,
      participant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Participant>> getAllParticipants() async {
    final rows = await _db.query(
      Participant.tableName,
      orderBy: 'created_at DESC',
    );
    return rows.map(Participant.fromMap).toList();
  }

  Future<Participant?> getParticipant(String participantId) async {
    final rows = await _db.query(
      Participant.tableName,
      where: 'participant_id = ?',
      whereArgs: [participantId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Participant.fromMap(rows.first);
  }

  // --- Sessions -----------------------------------------------------------

  Future<void> upsertSession(Session session) async {
    await _db.insert(
      Session.tableName,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Session>> getSessionsForParticipant(String participantId) async {
    final rows = await _db.query(
      Session.tableName,
      where: 'participant_id = ?',
      whereArgs: [participantId],
      orderBy: 'start_time ASC',
    );
    return rows.map(Session.fromMap).toList();
  }

  Future<List<Session>> getAllSessions() async {
    final rows = await _db.query(Session.tableName, orderBy: 'start_time ASC');
    return rows.map(Session.fromMap).toList();
  }

  // --- Phases -------------------------------------------------------------

  Future<void> upsertPhase(Phase phase) async {
    await _db.insert(
      Phase.tableName,
      phase.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Phase>> getPhasesForSession(String sessionId) async {
    final rows = await _db.query(
      Phase.tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'start_time ASC',
    );
    return rows.map(Phase.fromMap).toList();
  }

  // --- Ideas --------------------------------------------------------------

  Future<void> upsertIdea(Idea idea) async {
    await _db.insert(
      Idea.tableName,
      idea.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Idea>> getIdeasForSession(String sessionId) async {
    final rows = await _db.query(
      Idea.tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return rows.map(Idea.fromMap).toList();
  }

  // --- Spark events -------------------------------------------------------

  Future<void> upsertSparkEvent(SparkEvent event) async {
    await _db.insert(
      SparkEvent.tableName,
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SparkEvent>> getSparkEventsForSession(String sessionId) async {
    final rows = await _db.query(
      SparkEvent.tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'shown_at ASC',
    );
    return rows.map(SparkEvent.fromMap).toList();
  }

  // --- Drawing artifacts --------------------------------------------------

  Future<void> insertArtifact(DrawingArtifact artifact) async {
    await _db.insert(
      DrawingArtifact.tableName,
      artifact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DrawingArtifact>> getArtifactsForSession(
      String sessionId) async {
    final rows = await _db.query(
      DrawingArtifact.tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return rows.map(DrawingArtifact.fromMap).toList();
  }

  // --- Reflections --------------------------------------------------------

  Future<void> insertReflection(Reflection reflection) async {
    await _db.insert(
      Reflection.tableName,
      reflection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Reflection?> getReflectionForSession(String sessionId) async {
    final rows = await _db.query(
      Reflection.tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Reflection.fromMap(rows.first);
  }

  // --- Facilitator notes --------------------------------------------------

  Future<void> insertFacilitatorNote(FacilitatorNote note) async {
    await _db.insert(
      FacilitatorNote.tableName,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FacilitatorNote>> getNotesForSession(String sessionId) async {
    final rows = await _db.query(
      FacilitatorNote.tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return rows.map(FacilitatorNote.fromMap).toList();
  }

  // --- Override events -----------------------------------------------------

  Future<void> insertOverrideEvent(OverrideEvent event) async {
    await _db.insert(
      OverrideEvent.tableName,
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OverrideEvent>> getOverrideEventsForSession(
      String sessionId) async {
    final rows = await _db.query(
      OverrideEvent.tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return rows.map(OverrideEvent.fromMap).toList();
  }

  // --- Sync records --------------------------------------------------------

  Future<void> upsertSyncRecord(SyncRecord record) async {
    await _db.insert(
      SyncRecord.tableName,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SyncRecord?> getSyncRecord(String sessionId) async {
    final rows = await _db.query(
      SyncRecord.tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SyncRecord.fromMap(rows.first);
  }

  Future<List<SyncRecord>> getSyncRecordsByStatus(SyncStatus status) async {
    final rows = await _db.query(
      SyncRecord.tableName,
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'updated_at ASC',
    );
    return rows.map(SyncRecord.fromMap).toList();
  }

  /// Counts sync records grouped by status (for the export-screen badge).
  Future<Map<SyncStatus, int>> syncStatusCounts() async {
    final rows = await _db.rawQuery(
      'SELECT status, COUNT(*) AS n FROM ${SyncRecord.tableName} GROUP BY status',
    );
    final counts = <SyncStatus, int>{};
    for (final row in rows) {
      counts[SyncStatus.fromValue(row['status']! as String)] =
          (row['n'] as int?) ?? 0;
    }
    return counts;
  }

  // --- App settings (simple key/value) ------------------------------------

  static const String _appSettingsTableSql = '''
    CREATE TABLE app_settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  Future<String?> getSetting(String key) async {
    final rows = await _db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    await _db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
