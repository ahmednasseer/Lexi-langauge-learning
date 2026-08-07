import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _offlineController = StreamController<bool>.broadcast();
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isOffline => _isOffline;
  Stream<bool> get offlineStream => _offlineController.stream;

  Future<void> init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOffline = results.contains(ConnectivityResult.none);

      _subscription = _connectivity.onConnectivityChanged.listen((results) {
        final wasOffline = _isOffline;
        _isOffline = results.contains(ConnectivityResult.none);
        if (wasOffline != _isOffline) {
          _offlineController.add(_isOffline);
          debugPrint('Connectivity changed: ${_isOffline ? "offline" : "online"}');
        }
      });
    } catch (e) {
      debugPrint('Connectivity init error: $e');
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOffline = results.contains(ConnectivityResult.none);
      return !_isOffline;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _offlineController.close();
  }
}
