package com.growly.child_app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import android.app.NotificationManager
import android.app.NotificationChannel
import android.os.Process
import android.app.AppOpsManager

/**
 * Accessibility Service for blocking restricted apps + handling Flutter MethodChannel.
 *
 * Note: This service cannot directly communicate with Flutter's MethodChannel because
 * it runs in a separate process. Instead, it reads all restrictions from SharedPreferences
 * (written by MainActivity via updateRestrictions). It also implements a local
 * BroadcastReceiver approach for cross-process updates.
 */
class GrowlyAccessibilityService : AccessibilityService() {

    private var myPackageName: String = ""

    override fun onCreate() {
        super.onCreate()
        myPackageName = packageName

        // Register broadcast receiver for cross-process updates
        registerReceiver(_restrictionReceiver, android.content.IntentFilter(ACTION_RESTRICTION_UPDATE))
    }

    private val _restrictionReceiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: android.content.Context?, intent: android.content.Intent?) {
            // Broadcast to force service to re-check restrictions
            // This is a lightweight wake-up mechanism
            android.util.Log.d("GrowlyAccess", "Received restriction update broadcast")
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()

        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                        AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                   AccessibilityServiceInfo.FLAG_REQUEST_TOUCH_EXPLORATION_MODE
            notificationTimeout = 100
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return

        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return
        if (packageName == myPackageName) return

        val prefs = getSharedPreferences("growly_parental", Context.MODE_PRIVATE)
        val kioskMode = prefs.getBoolean("kiosk_mode", false)
        if (!kioskMode) return

        // Read locked apps from SharedPreferences (written by MainActivity.updateRestrictions)
        val lockedAppsRaw = prefs.getString("locked_apps", null)
        val lockedApps = if (lockedAppsRaw.isNullOrEmpty()) {
            emptySet()
        } else {
            try {
                // MainActivity stores as Set via putStringSet
                // But getStringSet can return null on some API levels
                prefs.getStringSet("locked_apps", emptySet()) ?: emptySet()
            } catch (_: Exception) {
                emptySet()
            }
        }

        // Also check JSON format (written by GrowlyAccessibilityService's own write path)
        val lockedAppsJson = prefs.getString("locked_apps_json", "")
        val lockedFromJson = if (lockedAppsJson.isNullOrEmpty()) {
            emptyList()
        } else {
            lockedAppsJson.split(",").filter { it.isNotBlank() }
        }

        val allLocked = if (lockedFromJson.isNotEmpty()) {
            lockedFromJson
        } else {
            lockedApps.toList()
        }

        if (allLocked.any { it == packageName }) {
            // Check schedule before blocking
            val scheduleMode = prefs.getString("schedule_mode", "") ?: ""
            if (scheduleMode.isNotEmpty() && scheduleMode != "disabled") {
                val scheduleStart = prefs.getString("schedule_start", "") ?: ""
                val scheduleEnd = prefs.getString("schedule_end", "") ?: ""
                if (!isWithinSchedule(scheduleStart, scheduleEnd)) {
                    return // Not in restricted hours — allow
                }
            }

            // Check screen time limit
            val screenTimeLimit = prefs.getInt("screen_time_limit_minutes", 0)
            if (screenTimeLimit > 0) {
                val currentScreenTimeMs = getCurrentScreenTimeMs()
                val limitMs = screenTimeLimit * 60 * 1000L
                if (currentScreenTimeMs >= limitMs) {
                    // Time exceeded — block
                    blockAndReturnHome()
                    return
                }
            }

            // Block
            blockAndReturnHome()
        }
    }

    private fun getCurrentScreenTimeMs(): Long {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? android.app.usage.UsageStatsManager

                if (usageStatsManager != null) {
                    val now = System.currentTimeMillis()
                    val startOfDay = getStartOfDayMs()
                    val stats = usageStatsManager.queryUsageStats(
                        android.app.usage.UsageStatsManager.INTERVAL_DAILY,
                        startOfDay,
                        now
                    )

                    var total = 0L
                    for (s in stats) {
                        total += s.totalTimeInForeground
                    }
                    return total
                }
            }
        } catch (_: Exception) {
            // Permission not granted
        }
        return 0
    }

    private fun getStartOfDayMs(): Long {
        val now = java.util.Calendar.getInstance()
        now.set(java.util.Calendar.HOUR_OF_DAY, 0)
        now.set(java.util.Calendar.MINUTE, 0)
        now.set(java.util.Calendar.SECOND, 0)
        now.set(java.util.Calendar.MILLISECOND, 0)
        return now.timeInMillis
    }

    private fun isWithinSchedule(start: String, end: String): Boolean {
        if (start.isEmpty() || end.isEmpty()) return true

        try {
            val now = java.util.Calendar.getInstance()
            val currentHour = now.get(java.util.Calendar.HOUR_OF_DAY)
            val currentMin = now.get(java.util.Calendar.MINUTE)
            val currentTotalMin = currentHour * 60 + currentMin

            val startParts = start.split(":")
            val startTotalMin = startParts[0].toInt() * 60 + startParts[1].toInt()

            val endParts = end.split(":")
            val endTotalMin = endParts[0].toInt() * 60 + endParts[1].toInt()

            return if (startTotalMin <= endTotalMin) {
                currentTotalMin in startTotalMin..endTotalMin
            } else {
                // Overnight schedule (e.g., 22:00 - 06:00)
                currentTotalMin >= startTotalMin || currentTotalMin <= endTotalMin
            }
        } catch (_: Exception) {
            return true
        }
    }

    private fun blockAndReturnHome() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)

        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("blocked_app", true)
        }
        startActivity(launchIntent)
    }

    override fun onInterrupt() {
        // Required but not used
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(_restrictionReceiver)
        } catch (_: Exception) {
            // May not be registered yet
        }
        super.onDestroy()
    }

    companion object {
        const val ACTION_RESTRICTION_UPDATE = "com.growly.RESTRICTION_UPDATE"
    }
}