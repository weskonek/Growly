package com.growly.child_app

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.os.UserHandle
import android.widget.Toast

/**
 * Device Admin Receiver for Growly parental control.
 * Handles device admin enable/disable events and provides
 * admin-specific operations like device locking and wipe.
 */
class GrowlyDeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        // Save admin status
        val prefs = context.getSharedPreferences("growly_parental", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("device_admin_enabled", true).apply()

        // Enable kiosk mode by default when admin is enabled
        prefs.edit().putBoolean("kiosk_mode", true).apply()
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        // Clear admin status
        val prefs = context.getSharedPreferences("growly_parental", Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("device_admin_enabled", false)
            .putBoolean("kiosk_mode", false)
            .apply()

        // Disable accessibility service when admin is removed
        // This ensures child app returns to normal mode
    }

    override fun onPasswordFailed(context: Context, intent: Intent, userHandle: UserHandle) {
        super.onPasswordFailed(context, intent, userHandle)
        // Track failed attempts for security monitoring
        val prefs = context.getSharedPreferences("growly_parental", Context.MODE_PRIVATE)
        val failedAttempts = prefs.getInt("failed_password_attempts", 0) + 1
        prefs.edit().putInt("failed_password_attempts", failedAttempts).apply()
    }

    override fun onPasswordSucceeded(context: Context, intent: Intent) {
        super.onPasswordSucceeded(context, intent)
        // Reset failed attempts counter on success
        val prefs = context.getSharedPreferences("growly_parental", Context.MODE_PRIVATE)
        prefs.edit().putInt("failed_password_attempts", 0).apply()
    }
}