package com.example.women_safety_app

import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.telephony.SmsManager
import android.text.TextUtils
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val SMS_CHANNEL = "women_safety_app/sms"
    private val POWER_CHANNEL = "women_safety_app/power_button"
    private val VOLUME_CHANNEL = "women_safety_app/volume_button"
    private val ACCESSIBILITY_CHANNEL = "women_safety_app/accessibility"

    private var powerChannel: MethodChannel? = null
    private var volumeChannel: MethodChannel? = null

    // Power button triple-click detection (foreground only)
    private val powerClickTimes = mutableListOf<Long>()
    private val tripleClickWindowMs = 2000L
    private val requiredClicks = 3

    // Volume button service instance (singleton via companion)
    private var volumeKeyService: VolumeKeyService? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── SMS channel ──────────────────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendSms" -> {
                        val phone = call.argument<String>("phone")
                        val message = call.argument<String>("message")
                        if (phone != null && message != null) {
                            if (sendSms(phone, message)) result.success(true)
                            else result.error("SMS_FAILED", "Failed to send SMS", null)
                        } else {
                            result.error("INVALID_ARGS", "phone and message required", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // ── Power button channel ─────────────────────────────────────────────
        powerChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, POWER_CHANNEL
        )

        // ── Volume button channel ────────────────────────────────────────────
        volumeChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, VOLUME_CHANNEL
        )
        // Share the channel with VolumeKeyService so it can call Flutter
        VolumeKeyService.methodChannel = volumeChannel

        volumeChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    startVolumeService()
                    result.success(null)
                }
                "stopListening" -> {
                    stopVolumeService()
                    result.success(null)
                }
                "setUserInfo" -> {
                    VolumeKeyService.emergencyPhone = call.argument<String>("phone") ?: ""
                    VolumeKeyService.emergencyUserName = call.argument<String>("name") ?: ""
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ── Accessibility channel ────────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isEnabled" -> result.success(isAccessibilityServiceEnabled())
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ── Volume foreground service ────────────────────────────────────────────

    private fun startVolumeService() {
        val intent = Intent(this, VolumeKeyService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopVolumeService() {
        stopService(Intent(this, VolumeKeyService::class.java))
    }

    // ── Accessibility check ──────────────────────────────────────────────────

    private fun isAccessibilityServiceEnabled(): Boolean {
        val fullName = "$packageName/${SafetyAccessibilityService::class.java.name}"
        val shortName = "$packageName/.${SafetyAccessibilityService::class.java.simpleName}"
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        android.util.Log.d("SafetyApp", "Looking for: $fullName or $shortName")
        android.util.Log.d("SafetyApp", "Enabled services: $enabledServices")
        return TextUtils.SimpleStringSplitter(':').apply {
            setString(enabledServices)
        }.any {
            it.equals(fullName, ignoreCase = true) ||
            it.equals(shortName, ignoreCase = true)
        }
    }

    // ── Key event interception ───────────────────────────────────────────────

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN) {
            when (event.keyCode) {
                // Volume down → forward to VolumeKeyService for triple-press detection
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    VolumeKeyService.methodChannel?.let {
                        // Reuse the service logic via a local helper
                        handleVolumeDown()
                    }
                    // Don't consume — let the system still adjust volume
                    return super.dispatchKeyEvent(event)
                }
                // Power button → triple-click detection (foreground only)
                KeyEvent.KEYCODE_POWER -> {
                    val now = System.currentTimeMillis()
                    powerClickTimes.removeAll { now - it > tripleClickWindowMs }
                    powerClickTimes.add(now)
                    if (powerClickTimes.size >= requiredClicks) {
                        powerClickTimes.clear()
                        powerChannel?.invokeMethod("onTripleClick", null)
                    }
                    return true
                }
            }
        }
        return super.dispatchKeyEvent(event)
    }

    // Inline triple-press logic (mirrors VolumeKeyService for when app is foreground)
    private val volumePressTimestamps = mutableListOf<Long>()
    private fun handleVolumeDown() {
        val now = System.currentTimeMillis()
        volumePressTimestamps.removeAll { now - it > tripleClickWindowMs }
        volumePressTimestamps.add(now)
        if (volumePressTimestamps.size >= requiredClicks) {
            volumePressTimestamps.clear()
            volumeChannel?.invokeMethod("onVolumeTriplePress", null)
        }
    }

    // ── SMS helper ───────────────────────────────────────────────────────────

    private fun sendSms(phone: String, message: String): Boolean {
        return try {
            val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= 31) {
                applicationContext.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
            val parts = smsManager.divideMessage(message)
            smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    // Keep old onKeyDown for compatibility (power button)
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_POWER) {
            // Already handled in dispatchKeyEvent
            return true
        }
        return super.onKeyDown(keyCode, event)
    }
}
