package com.growly.child_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Boot Receiver to restart monitoring services after device reboot.
 * Ensures parental controls are active even after device restart.
 */
class GrowlyBootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {

            val prefs = context.getSharedPreferences("growly_parental", Context.MODE_PRIVATE)

            // Check if parental controls should be active
            val deviceAdminEnabled = prefs.getBoolean("device_admin_enabled", false)
            val kioskMode = prefs.getBoolean("kiosk_mode", false)

            if (deviceAdminEnabled || kioskMode) {
                // Start the monitor service
                val serviceIntent = Intent(context, GrowlyMonitorService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            }
        }
    }
}