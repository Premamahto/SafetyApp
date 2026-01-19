# Native Power Button Detection Implementation Guide

## 📱 Android Native Implementation

This guide explains how to implement actual power button detection in Android for production use.

## ⚠️ Current Implementation

The current app uses a **simulation approach** for testing. The "Simulate Triple Click" button triggers the emergency without actual power button detection.

## 🔧 Production Implementation Steps

### Step 1: Create MainActivity.kt

Create or modify `android/app/src/main/kotlin/com/example/women_safety_app/MainActivity.kt`:

```kotlin
package com.example.women_safety_app

import android.os.Bundle
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "women_safety_app/power_button"
    private var methodChannel: MethodChannel? = null
    
    // Triple click detection
    private val clickTimes = mutableListOf<Long>()
    private val TRIPLE_CLICK_WINDOW = 2000L // 2 seconds
    private val REQUIRED_CLICKS = 3

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
        
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    result.success("Listening started")
                }
                "stopListening" -> {
                    clickTimes.clear()
                    result.success("Listening stopped")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_POWER) {
            handlePowerButtonPress()
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    private fun handlePowerButtonPress() {
        val now = System.currentTimeMillis()
        
        // Remove old clicks outside time window
        clickTimes.removeAll { now - it > TRIPLE_CLICK_WINDOW }
        
        // Add current click
        clickTimes.add(now)
        
        // Check for triple click
        if (clickTimes.size >= REQUIRED_CLICKS) {
            methodChannel?.invokeMethod("onPowerButtonPressed", null)
            clickTimes.clear()
        }
    }
}
```

### Step 2: Update AndroidManifest.xml

Ensure your `android/app/src/main/AndroidManifest.xml` has the correct activity declaration:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize"
    android:screenOrientation="portrait">
    
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
```

### Step 3: Update Flutter Service

The `power_button_service.dart` is already set up to receive events from native code. Just uncomment the platform channel code:

```dart
import 'dart:async';
import 'package:flutter/services.dart';

class PowerButtonService {
  static const platform = MethodChannel('women_safety_app/power_button');
  
  final List<DateTime> _clickTimes = [];
  static const Duration _tripleClickWindow = Duration(seconds: 2);
  static const int _requiredClicks = 3;

  StreamController<bool>? _tripleClickController;
  Stream<bool>? _tripleClickStream;

  Stream<bool> get tripleClickStream {
    _tripleClickController ??= StreamController<bool>.broadcast();
    _tripleClickStream ??= _tripleClickController!.stream;
    return _tripleClickStream!;
  }

  Future<void> initialize() async {
    try {
      platform.setMethodCallHandler(_handleMethodCall);
      await platform.invokeMethod('startListening');
    } catch (e) {
      print('Error initializing power button service: $e');
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onPowerButtonPressed') {
      _tripleClickController?.add(true);
    }
  }

  void simulateTripleClick() {
    _tripleClickController?.add(true);
  }

  Future<void> dispose() async {
    try {
      await platform.invokeMethod('stopListening');
      await _tripleClickController?.close();
    } catch (e) {
      print('Error disposing power button service: $e');
    }
  }
}
```

## 🔄 Background Service Implementation

For detection when app is in background, implement a foreground service:

### Step 4: Create Background Service

Create `android/app/src/main/kotlin/com/example/women_safety_app/PowerButtonService.kt`:

```kotlin
package com.example.women_safety_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class PowerButtonService : Service() {
    private val CHANNEL_ID = "PowerButtonServiceChannel"
    private val NOTIFICATION_ID = 1

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Service runs in foreground to detect power button
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Power Button Detection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitoring for emergency trigger"
            }
            
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Women Safety")
            .setContentText("Emergency detection active")
            .setSmallIcon(R.drawable.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()
    }
}
```

### Step 5: Update AndroidManifest.xml for Service

Add service declaration:

```xml
<service
    android:name=".PowerButtonService"
    android:enabled="true"
    android:exported="false"
    android:foregroundServiceType="location" />
```

## 📱 Alternative: Volume Button Detection

Since power button detection can be restricted on some devices, use volume buttons as alternative:

```kotlin
override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
    when (keyCode) {
        KeyEvent.KEYCODE_POWER,
        KeyEvent.KEYCODE_VOLUME_DOWN,
        KeyEvent.KEYCODE_VOLUME_UP -> {
            handleEmergencyButtonPress()
            return true
        }
    }
    return super.onKeyDown(keyCode, event)
}
```

## 🍎 iOS Implementation

For iOS, use volume button detection:

### Create iOS Plugin

Create `ios/Runner/PowerButtonPlugin.swift`:

```swift
import Flutter
import UIKit
import MediaPlayer

public class PowerButtonPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var clickTimes: [Date] = []
    private let tripleClickWindow: TimeInterval = 2.0
    private let requiredClicks = 3
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "women_safety_app/power_button",
            binaryMessenger: registrar.messenger()
        )
        let instance = PowerButtonPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startListening":
            startVolumeButtonMonitoring()
            result("Listening started")
        case "stopListening":
            stopVolumeButtonMonitoring()
            result("Listening stopped")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startVolumeButtonMonitoring() {
        // Monitor volume button presses
        let volumeView = MPVolumeView(frame: .zero)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(volumeChanged),
            name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil
        )
    }
    
    @objc private func volumeChanged() {
        handleButtonPress()
    }
    
    private func handleButtonPress() {
        let now = Date()
        
        // Remove old clicks
        clickTimes = clickTimes.filter { 
            now.timeIntervalSince($0) <= tripleClickWindow 
        }
        
        // Add current click
        clickTimes.append(now)
        
        // Check for triple click
        if clickTimes.count >= requiredClicks {
            channel?.invokeMethod("onPowerButtonPressed", arguments: nil)
            clickTimes.removeAll()
        }
    }
    
    private func stopVolumeButtonMonitoring() {
        NotificationCenter.default.removeObserver(self)
        clickTimes.removeAll()
    }
}
```

### Register Plugin in AppDelegate

Update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        PowerButtonPlugin.register(with: controller.registrar(forPlugin: "PowerButtonPlugin")!)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

## 🧪 Testing Native Implementation

### Android Testing

1. Build and run the app
2. Press power button 3 times quickly
3. Check logcat for events:
   ```bash
   adb logcat | grep "PowerButton"
   ```

### iOS Testing

1. Build and run on iOS device
2. Press volume up/down 3 times quickly
3. Check console for events

## ⚠️ Important Considerations

### Android Limitations

1. **Power Button Access**: Some Android versions restrict power button access
2. **Background Restrictions**: Android 8+ has strict background limitations
3. **Battery Optimization**: May kill background services
4. **Device Variations**: Different manufacturers handle power button differently

### Solutions

1. **Use Volume Buttons**: More reliable than power button
2. **Foreground Service**: Keep service alive with notification
3. **Shake Detection**: Alternative trigger method
4. **Widget**: Quick access from home screen

### iOS Limitations

1. **No Power Button Access**: iOS doesn't allow power button detection
2. **Volume Button Alternative**: Use volume buttons instead
3. **Background Limitations**: iOS restricts background execution

## 🔐 Permissions Required

### Android

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### iOS

```xml
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
</array>
```

## 📊 Testing Checklist

- [ ] Power button detection in foreground
- [ ] Power button detection in background
- [ ] Triple click timing accuracy
- [ ] False positive prevention
- [ ] Battery impact assessment
- [ ] Multiple device testing
- [ ] Android version compatibility
- [ ] iOS version compatibility

## 🚀 Deployment

1. Test on multiple devices
2. Monitor battery usage
3. Handle edge cases
4. Provide user feedback
5. Add settings to customize trigger

---

**Note**: The current demo app uses simulation for testing. Implement native code for production deployment.

**Recommendation**: Use volume buttons instead of power button for better reliability across devices.
