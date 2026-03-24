package com.example.women_safety_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.telephony.SmsManager
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel

/**
 * Foreground service with two responsibilities:
 *
 * 1. Shows a persistent "Safety Monitor Active" notification so Android
 *    keeps the process alive and the AccessibilityService keeps running.
 *
 * 2. When ACTION_TRIGGER_SOS is received (app fully killed, no Flutter engine),
 *    sends the emergency SMS natively without needing Flutter at all.
 */
class VolumeKeyService : Service() {

    companion object {
        const val CHANNEL_ID = "volume_key_service"
        const val NOTIF_ID = 1001
        const val ACTION_TRIGGER_SOS = "com.example.women_safety_app.TRIGGER_SOS"

        /** Shared with MainActivity so AccessibilityService can call Flutter when alive */
        var methodChannel: MethodChannel? = null

        /** Set by Flutter via MethodChannel so native SOS knows who to call */
        var emergencyPhone: String = ""
        var emergencyUserName: String = ""
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIF_ID, buildNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_TRIGGER_SOS) {
            sendNativeSos()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ── Native SOS (Flutter engine dead) ────────────────────────────────────

    private fun sendNativeSos() {
        val phone = emergencyPhone.ifBlank { return }
        val message = buildSosMessage()
        try {
            val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= 31) {
                applicationContext.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
            val parts = smsManager.divideMessage(message)
            smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Also launch the app so the user sees the SOS screen
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("sos_triggered", true)
        }
        launchIntent?.let { startActivity(it) }
    }

    private fun buildSosMessage(): String {
        val name = emergencyUserName.ifBlank { "User" }
        return """EMERGENCY ALERT!

$name needs immediate help!

This SOS was triggered via volume button.

Time: ${java.util.Date()}

Please respond immediately!"""
    }

    // ── Notification ─────────────────────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Safety Monitor",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors volume button for emergency trigger"
                setShowBadge(false)
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val tapIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pi = PendingIntent.getActivity(
            this, 0, tapIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Safety Monitor Active")
            .setContentText("Triple-press volume ↓ to send SOS")
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setContentIntent(pi)
            .build()
    }
}
