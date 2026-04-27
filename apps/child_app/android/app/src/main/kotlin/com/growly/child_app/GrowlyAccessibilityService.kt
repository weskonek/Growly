package com.growly.child_app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.content.pm.PackageManager
import android.view.accessibility.AccessibilityEvent

/**
 * Accessibility Service for blocking restricted apps.
 * Monitors window state changes to detect when restricted apps are opened
 * and returns user to the Growly home screen.
 */
class GrowlyAccessibilityService : AccessibilityService() {

    private var myPackageName: String = ""

    override fun onCreate() {
        super.onCreate()
        myPackageName = packageName
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

        // Only check window state changes
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return

        // Skip our own app
        if (packageName == myPackageName) return

        // Check if kiosk mode is enabled and this app is not allowed
        val prefs = getSharedPreferences("growly_parental", MODE_PRIVATE)
        val kioskMode = prefs.getBoolean("kiosk_mode", false)

        if (!kioskMode) return

        val allowedPackage = prefs.getString("allowed_package", myPackageName)

        // Check if this app is in the locked list or not in allowed package
        val lockedApps = prefs.getStringSet("locked_apps", emptySet()) ?: emptySet()

        if (packageName != allowedPackage && lockedApps.contains(packageName)) {
            // Block the app - return to home screen
            blockAndReturnHome()
        }
    }

    private fun blockAndReturnHome() {
        // Create home intent to return to Growly launcher
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)

        // Also bring our app to foreground
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("blocked_app", true)
        }
        startActivity(launchIntent)
    }

    override fun onInterrupt() {
        // Required but not used in our implementation
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}