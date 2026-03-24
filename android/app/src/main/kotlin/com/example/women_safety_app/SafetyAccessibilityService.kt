package com.example.women_safety_app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.os.Build
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent

/**
 * Accessibility service that intercepts volume-down key events system-wide.
 *
 * This is the ONLY Android API that can capture hardware key events when
 * the app is in the background or the screen is off (with wake lock).
 *
 * The user must manually enable it once in:
 *   Settings → Accessibility → Women Safety → Enable
 *
 * On triple-press within 2 seconds → starts VolumeKeyService which
 * sends the SOS (SMS + call) directly from native code.
 */
class SafetyAccessibilityService : AccessibilityService() {

    private val pressTimestamps = mutableListOf<Long>()
    private val windowMs = 2000L
    private val requiredPresses = 3

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Request key event interception
        serviceInfo = serviceInfo.apply {
            flags = flags or AccessibilityServiceInfo.FLAG_REQUEST_FILTER_KEY_EVENTS
        }
    }

    override fun onKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN &&
            event.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN
        ) {
            val now = System.currentTimeMillis()
            pressTimestamps.removeAll { now - it > windowMs }
            pressTimestamps.add(now)

            if (pressTimestamps.size >= requiredPresses) {
                pressTimestamps.clear()
                triggerSos()
            }
            // Return false so volume still changes normally
            return false
        }
        return false
    }

    private fun triggerSos() {
        // If the Flutter engine / MethodChannel is alive, use it
        val channel = VolumeKeyService.methodChannel
        if (channel != null) {
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                channel.invokeMethod("onVolumeTriplePress", null)
            }
        } else {
            // Flutter engine is dead (app fully killed) — trigger natively
            val intent = Intent(this, VolumeKeyService::class.java).apply {
                action = VolumeKeyService.ACTION_TRIGGER_SOS
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}
    override fun onInterrupt() {}
}
