import 'dart:async';
import 'package:flutter/services.dart';

/// Detects triple-press of the volume-down button and emits a trigger event.
///
/// Uses a native Android AccessibilityService so it works:
///   - App in foreground
///   - App in background
///   - Screen off (with wake lock)
///
/// The user must enable the accessibility service once:
///   Settings → Accessibility → Women Safety Monitor → Enable
class VolumeButtonService {
  static const _channel = MethodChannel('women_safety_app/volume_button');
  static const _accessibilityChannel =
      MethodChannel('women_safety_app/accessibility');

  StreamController<bool>? _controller;

  Stream<bool> get tripleClickStream {
    _controller ??= StreamController<bool>.broadcast();
    return _controller!.stream;
  }

  Future<void> initialize({String phone = '', String name = ''}) async {
    _controller ??= StreamController<bool>.broadcast();

    // Receive triple-press events from native
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onVolumeTriplePress') {
        _controller?.add(true);
      }
    });

    // Start the foreground service (persistent notification)
    try {
      await _channel.invokeMethod('startListening');
    } on PlatformException catch (e) {
      print('VolumeButtonService: startListening failed — $e');
    }

    // Pass user info so native can send SOS even if Flutter engine is dead
    if (phone.isNotEmpty) {
      try {
        await _channel.invokeMethod('setUserInfo', {
          'phone': phone,
          'name': name,
        });
      } catch (_) {}
    }
  }

  /// Check if the accessibility service is enabled.
  /// Returns true if enabled, false if the user still needs to turn it on.
  Future<bool> isAccessibilityEnabled() async {
    try {
      final result =
          await _accessibilityChannel.invokeMethod<bool>('isEnabled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Open Android Accessibility Settings so the user can enable the service.
  Future<void> openAccessibilitySettings() async {
    try {
      await _accessibilityChannel.invokeMethod('openSettings');
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('stopListening');
    } catch (_) {}
    await _controller?.close();
    _controller = null;
  }

  void simulateTriplePress() => _controller?.add(true);
}
