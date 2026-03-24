import 'dart:async';
import 'package:flutter/services.dart';

/// Power button detection service
/// Detects triple-click of power button via native Android MethodChannel
class PowerButtonService {
  static const _channel = MethodChannel('women_safety_app/power_button');

  StreamController<bool>? _tripleClickController;

  Stream<bool> get tripleClickStream {
    _tripleClickController ??= StreamController<bool>.broadcast();
    return _tripleClickController!.stream;
  }

  Future<void> initialize() async {
    _tripleClickController ??= StreamController<bool>.broadcast();

    // Listen for triple-click events from native Android
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onTripleClick') {
        _tripleClickController?.add(true);
      }
    });

    print('PowerButtonService: native channel initialized');
  }

  /// Simulate triple click for testing
  void simulateTripleClick() {
    _tripleClickController?.add(true);
  }

  Future<void> dispose() async {
    await _tripleClickController?.close();
    _tripleClickController = null;
  }
}
