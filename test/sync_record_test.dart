import 'package:flutter_test/flutter_test.dart';
import 'package:spark/models/sync_record.dart';

void main() {
  test('SyncRecord round-trips through map', () {
    final original = SyncRecord(
      sessionId: 's1',
      status: SyncStatus.failed,
      updatedAt: DateTime.parse('2026-06-25T10:00:00Z'),
      error: 'network down',
    );
    final restored = SyncRecord.fromMap(original.toMap());
    expect(restored.sessionId, 's1');
    expect(restored.status, SyncStatus.failed);
    expect(restored.error, 'network down');
    expect(restored.updatedAt.toUtc(), original.updatedAt.toUtc());
  });

  test('copyWith can clear error on success', () {
    final pending = SyncRecord(
      sessionId: 's1',
      status: SyncStatus.pending,
      updatedAt: DateTime.now(),
      error: 'prev',
    );
    final synced = pending.copyWith(
      status: SyncStatus.synced,
      updatedAt: DateTime.now(),
    );
    expect(synced.status, SyncStatus.synced);
    expect(synced.error, isNull);
  });

  test('SyncStatus.fromValue rejects unknown', () {
    expect(() => SyncStatus.fromValue('weird'), throwsArgumentError);
  });
}
