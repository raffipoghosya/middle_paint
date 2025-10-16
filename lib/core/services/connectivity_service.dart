import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// A service that exposes network connectivity changes.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;

  /// Returns a broadcast stream of online/offline status.
  Stream<bool> onConnectivityChanged() {
    return _connectivity.onConnectivityChanged.map((results) => _isOnlineFromList(results));
  }

  /// Checks current connectivity once.
  Future<bool> isOnline() async {
    final dynamic result = await _connectivity.checkConnectivity();
    if (result is List<ConnectivityResult>) {
      return _isOnlineFromList(result);
    } else if (result is ConnectivityResult) {
      return _isOnlineSingle(result);
    }
    return false;
  }

  bool _isOnlineSingle(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  bool _isOnlineFromList(List<ConnectivityResult> results) {
    for (final r in results) {
      if (r != ConnectivityResult.none) return true;
    }
    return false;
  }

  void dispose() {
    _subscription?.cancel();
  }
}


