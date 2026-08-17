import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity =
      Connectivity(); // Instance of Connectivity to check network status
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOnline = true;
  bool _isChecking = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isChecking => _isChecking;

  ConnectivityProvider() {
    _initConnectivity(); //check initial connectivity status
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivity,
    ); // setup listener once and listen to connectivity changes and update the status accordingly
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 5),
      );

      _isOnline =
          result.isNotEmpty &&
          result.first !=
              ConnectivityResult
                  .none; // Set initial connectivity status based on the result
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
      _isOnline = true; // Assume online if there's an error
    }
    notifyListeners(); // Notify listeners about the initial connectivity status
  }

  // Listen to connectivity changes and update the status accordingly
  void _updateConnectivity(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _isOnline = result.isNotEmpty && !result.contains(ConnectivityResult.none);

    if (wasOnline != _isOnline) {
      debugPrint(
        'Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}',
      ); // Log connectivity changes
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Manually re-check connection
  Future<void> recheckConnection() async {
    if (_isChecking) return; // avoid overlapping check on rapid taps
    _isChecking = true;
    notifyListeners();
    try {
      await _initConnectivity();
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
