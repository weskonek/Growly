package com.growly.child_app

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.app.admin.DeviceAdminReceiver
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.growly/android_parental_control"
    private lateinit var methodChannel: MethodChannel

    private val deviceAdminComponent by lazy {
        ComponentName(this, GrowlyDeviceAdminReceiver::class.java)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                // ==================== USAGE STATS ====================
                "checkUsageStatsPermission" -> {
                    result.success(checkUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    requestUsageStatsPermission()
                    result.success(null)
                }
                "getScreenTimeByApp" -> {
                    val startMs = call.argument<Long>("start") ?: 0L
                    val endMs = call.argument<Long>("end") ?: System.currentTimeMillis()
                    val screenTime = getScreenTimeByApp(startMs, endMs)
                    result.success(screenTime)
                }
                "getTotalScreenTime" -> {
                    val startMs = call.argument<Long>("start") ?: 0L
                    val endMs = call.argument<Long>("end") ?: System.currentTimeMillis()
                    val totalTime = getTotalScreenTime(startMs, endMs)
                    result.success(totalTime)
                }
                "startAppUsageMonitoring" -> {
                    result.success(startUsageMonitoring())
                }
                "stopAppUsageMonitoring" -> {
                    result.success(stopUsageMonitoring())
                }

                // ==================== DEVICE ADMIN ====================
                "isDeviceAdmin" -> {
                    result.success(isDeviceAdmin())
                }
                "requestDeviceAdmin" -> {
                    requestDeviceAdmin()
                    result.success(null)
                }
                "removeDeviceAdmin" -> {
                    removeDeviceAdmin()
                    result.success(null)
                }
                "lockApp" -> {
                    val packageName = call.argument<String>("package") ?: ""
                    result.success(lockApp(packageName))
                }
                "unlockApp" -> {
                    val packageName = call.argument<String>("package") ?: ""
                    result.success(unlockApp(packageName))
                }
                "enableKioskMode" -> {
                    val allowedPackage = call.argument<String>("allowedPackage") ?: packageName
                    result.success(enableKioskMode(allowedPackage))
                }
                "disableKioskMode" -> {
                    result.success(disableKioskMode())
                }

                // ==================== APP INFO ====================
                "getInstalledApps" -> {
                    result.success(getInstalledApps())
                }

                // ==================== PERMISSIONS ====================
                "openUsageAccessSettings" -> {
                    openUsageAccessSettings()
                    result.success(null)
                }
                "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
                    result.success(null)
                }
                "isAccessibilityEnabled" -> {
                    result.success(isAccessibilityEnabled())
                }

                else -> result.notImplemented()
            }
        }
    }

    // ==================== USAGE STATS METHODS ====================

    private fun checkUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    private fun getScreenTimeByApp(startMs: Long, endMs: Long): Map<String, Int> {
        if (!checkUsageStatsPermission()) return emptyMap()

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startMs,
            endMs
        )

        val result = mutableMapOf<String, Int>()
        usageStats?.forEach { stats ->
            if (stats.totalTimeInForeground > 0) {
                result[stats.packageName] = (stats.totalTimeInForeground / 1000).toInt()
            }
        }
        return result
    }

    private fun getTotalScreenTime(startMs: Long, endMs: Long): Int {
        if (!checkUsageStatsPermission()) return 0

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startMs,
            endMs
        )

        var totalTime = 0L
        usageStats?.forEach { stats ->
            totalTime += stats.totalTimeInForeground
        }
        return (totalTime / 1000).toInt()
    }

    private fun startUsageMonitoring(): Boolean {
        return checkUsageStatsPermission()
    }

    private fun stopUsageMonitoring(): Boolean {
        return true
    }

    // ==================== DEVICE ADMIN METHODS ====================

    private fun isDeviceAdmin(): Boolean {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
        return devicePolicyManager.isAdminActive(deviceAdminComponent)
    }

    private fun requestDeviceAdmin() {
        val intent = Intent(android.app.admin.DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
        intent.putExtra(android.app.admin.DevicePolicyManager.EXTRA_DEVICE_ADMIN, deviceAdminComponent)
        intent.putExtra(
            android.app.admin.DevicePolicyManager.EXTRA_ADD_EXPLANATION,
            getString(R.string.device_admin_description)
        )
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    private fun removeDeviceAdmin() {
        if (isDeviceAdmin()) {
            val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
            devicePolicyManager.removeActiveAdmin(deviceAdminComponent)
        }
    }

    private fun lockApp(packageName: String): Boolean {
        if (!isDeviceAdmin()) return false
        // Store locked apps in SharedPreferences for accessibility service to check
        val prefs = getSharedPreferences("growly_parental", Context.MODE_PRIVATE)
        val lockedApps = prefs.getStringSet("locked_apps", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        lockedApps.add(packageName)
        prefs.edit().putStringSet("locked_apps", lockedApps).apply()
        return true
    }

    private fun unlockApp(packageName: String): Boolean {
        val prefs = getSharedPreferences("growly_parental", Context.MODE_PRIVATE)
        val lockedApps = prefs.getStringSet("locked_apps", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        lockedApps.remove(packageName)
        prefs.edit().putStringSet("locked_apps", lockedApps).apply()
        return true
    }

    private fun enableKioskMode(allowedPackage: String): Boolean {
        if (!isDeviceAdmin()) return false
        val prefs = getSharedPreferences("growly_parental", Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("kiosk_mode", true)
            .putString("allowed_package", allowedPackage)
            .apply()
        return true
    }

    private fun disableKioskMode(): Boolean {
        val prefs = getSharedPreferences("growly_parental", Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("kiosk_mode", false)
            .remove("allowed_package")
            .apply()
        return true
    }

    // ==================== APP INFO METHODS ====================

    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val result = mutableListOf<Map<String, Any>>()

        packages.forEach { app ->
            // Filter system apps (optional - remove filter to include all apps)
            if (app.flags and ApplicationInfo.FLAG_SYSTEM == 0 &&
                app.packageName != packageName) {
                result.add(mapOf(
                    "packageName" to app.packageName,
                    "appName" to (pm.getApplicationLabel(app).toString()),
                    "isSystemApp" to (app.flags and ApplicationInfo.FLAG_SYSTEM != 0)
                ))
            }
        }
        return result
    }

    // ==================== SETTINGS METHODS ====================

    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    private fun isAccessibilityEnabled(): Boolean {
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: ""
        return enabledServices.contains(packageName)
    }
}