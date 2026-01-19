import 'dart:async';

/// Power button detection service
/// Detects triple-click of volume/power button to trigger emergency
/// 
/// NOTE: For production, implement native Android code to detect power button.
/// This demo version uses a simulated approach for testing.
class PowerButtonService {
  // Triple click detection
  final List<DateTime> _clickTimes = [];
  static const Duration _tripleClickWindow = Duration(seconds: 2);
  static const int _requiredClicks = 3;

  StreamController<bool>? _tripleClickController;
  Stream<bool>? _tripleClickStream;

  /// Get stream of triple-click events
  Stream<bool> get tripleClickStream {
    _tripleClickController ??= StreamController<bool>.broadcast();
    _tripleClickStream ??= _tripleClickController!.stream;
    return _tripleClickStream!;
  }

  /// Initialize power button listener
  /// 
  /// For production implementation:
  /// 1. Create native Android code in MainActivity.kt
  /// 2. Override onKeyDown to detect KEYCODE_POWER
  /// 3. Send events to Flutter via MethodChannel
  /// 4. Handle background service for detection when app is closed
  Future<void> initialize() async {
    try {
      print('Power button service initialized');
      print('Use the "Simulate Triple Click" button for testing');
      
      // In production, set up platform channel here:
      // static const platform = MethodChannel('women_safety_app/power_button');
      // platform.setMethodCallHandler(_handleMethodCall);
    } catch (e) {
      print('Error initializing power button service: $e');
    }
  }

  /// Handle power button press
  /// This would be called from native code in production
  void _handlePowerButtonPress() {
    final now = DateTime.now();
    
    // Remove old clicks outside the time window
    _clickTimes.removeWhere(
      (time) => now.difference(time) > _tripleClickWindow,
    );
    
    // Add current click
    _clickTimes.add(now);
    
    // Check if we have triple click
    if (_clickTimes.length >= _requiredClicks) {
      _tripleClickController?.add(true);
      _clickTimes.clear();
    }
  }

  /// Manually trigger triple click (for testing and demo)
  void simulateTripleClick() {
    _tripleClickController?.add(true);
  }

  /// Stop listening
  Future<void> dispose() async {
    try {
      await _tripleClickController?.close();
    } catch (e) {
      print('Error disposing power button service: $e');
    }
  }
}
