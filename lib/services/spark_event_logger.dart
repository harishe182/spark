import '../models/spark_event.dart';
import 'storage_service.dart';

/// Sink for [SparkEvent] records. An interface so the Spark sessions depend on
/// an abstraction (and tests can capture events without a database).
abstract interface class SparkEventSink {
  Future<void> save(SparkEvent event);
}

/// Persists Spark events to encrypted local storage. Used identically by both
/// Spark arms so the event log is structurally the same regardless of
/// condition — only the `spark_type` / `condition` fields differ.
class SparkEventLogger implements SparkEventSink {
  SparkEventLogger(this._storage);

  final StorageService _storage;

  @override
  Future<void> save(SparkEvent event) => _storage.upsertSparkEvent(event);
}
