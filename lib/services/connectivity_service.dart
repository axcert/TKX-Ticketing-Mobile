import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = true;
  bool _hasCheckedInitialConnection = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// Initialize connectivity service and listen for changes
  Future<void> initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(results);
    });
  }

  /// Check current connectivity status
  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      _hasCheckedInitialConnection = true;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _isOnline = false;
      notifyListeners();
    }
  }

  /// Update connection status based on connectivity results
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if any of the results indicate a connection
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      notifyListeners();

      // Log connectivity change
      debugPrint(
        'Connectivity changed: ${hasConnection ? "Online" : "Offline"}',
      );
    }
  }

  /// Dispose connectivity subscription
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
