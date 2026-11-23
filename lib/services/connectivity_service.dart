import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper over `connectivity_plus` exposing a Wi-Fi (or ethernet) check
/// and a change stream. Cloud sync is Wi-Fi-gated, so this is the gate.
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _isWifi(List<ConnectivityResult> results) =>
      results.contains(ConnectivityResult.wifi) ||
      results.contains(ConnectivityResult.ethernet);

  Future<bool> isOnWifi() async => _isWifi(await _connectivity.checkConnectivity());

  /// Emits true whenever an unmetered (Wi-Fi/ethernet) connection becomes
  /// available — used to flush the pending sync queue.
  Stream<bool> get onWifiChanged =>
      _connectivity.onConnectivityChanged.map(_isWifi);
}
