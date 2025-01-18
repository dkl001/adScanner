package com.example.ad_scanner

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import android.app.ActivityManager
import android.content.Context
import android.view.WindowManager
import android.app.AppOpsManager
import android.os.Process
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.os.Build
import java.util.concurrent.TimeUnit

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.scanner/apps"
    private var usageStatsManager: UsageStatsManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        usageStatsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        } else null

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getRunningApps" -> {
                    try {
                        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val runningProcesses = activityManager.runningAppProcesses
                        val runningApps = mutableListOf<Map<String, Any>>()
                        
                        runningProcesses?.forEach { process ->
                            runningApps.add(mapOf(
                                "processName" to process.processName,
                                "pid" to process.pid,
                                "pkgList" to process.pkgList.toList(),
                                "importance" to process.importance
                            ))
                        }
                        result.success(runningApps)
                    } catch (e: Exception) {
                        result.error("ERROR", e.toString(), null)
                    }
                }
                "getInstalledApps" -> {
                    try {
                        val packageManager = context.packageManager
                        val apps = mutableListOf<Map<String, Any>>()
                        
                        val packages = packageManager.getInstalledPackages(
                            PackageManager.GET_PERMISSIONS or 
                            PackageManager.GET_SERVICES or
                            PackageManager.GET_PROVIDERS
                        )

                        for (packageInfo in packages) {
                            val appInfo = packageManager.getApplicationInfo(packageInfo.packageName, 0)
                            val permissions = packageInfo.requestedPermissions?.toList() ?: listOf()
                            
                            apps.add(mapOf(
                                "name" to packageManager.getApplicationLabel(appInfo).toString(),
                                "packageName" to packageInfo.packageName,
                                "permissions" to permissions,
                                "isSystemApp" to ((appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0),
                                "hasOverlayPermission" to hasOverlayPermission(packageInfo.packageName),
                                "hasNotificationPermission" to hasNotificationPermission(packageInfo.packageName)
                            ))
                        }
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("ERROR", e.toString(), null)
                    }
                }
                "checkForAds" -> {
                    try {
                        val adDetections = checkForInvasiveAds()
                        result.success(adDetections)
                    } catch (e: Exception) {
                        result.error("ERROR", e.toString(), null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasOverlayPermission(packageName: String): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        return try {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_SYSTEM_ALERT_WINDOW,
                Process.myUid(),
                packageName
            ) == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            false
        }
    }

    private fun hasNotificationPermission(packageName: String): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // Pour Android 8.0 (API 26) et plus
                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
                notificationManager.areNotificationsEnabled()
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                // Pour Android 4.4 à 7.1
                val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
                appOps.checkOpNoThrow(
                    "OP_POST_NOTIFICATION",
                    Process.myUid(),
                    packageName
                ) == AppOpsManager.MODE_ALLOWED
            } else {
                // Pour les versions plus anciennes, on suppose que la permission est accordée
                true
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun checkForInvasiveAds(): List<Map<String, Any>> {
        val detections = mutableListOf<Map<String, Any>>()
        val endTime = System.currentTimeMillis()
        val startTime = endTime - TimeUnit.MINUTES.toMillis(5)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            usageStatsManager?.let { manager ->
                val usageEvents = manager.queryEvents(startTime, endTime)
                val event = UsageEvents.Event()

                while (usageEvents.hasNextEvent()) {
                    usageEvents.getNextEvent(event)
                    
                    if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                        event.eventType == UsageEvents.Event.ACTIVITY_PAUSED) {
                        
                        try {
                            val packageManager = context.packageManager
                            val appInfo = packageManager.getApplicationInfo(event.packageName, 0)
                            
                            if (hasOverlayPermission(event.packageName)) {
                                val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                                val hasOverlayWindows = windowManager.defaultDisplay != null
                                
                                if (hasOverlayWindows) {
                                    detections.add(mapOf(
                                        "packageName" to event.packageName,
                                        "appName" to packageManager.getApplicationLabel(appInfo).toString(),
                                        "type" to "overlay",
                                        "timestamp" to event.timeStamp
                                    ))
                                }
                            }
                        } catch (e: Exception) {
                            // Ignorer les erreurs individuelles pour continuer la détection
                        }
                    }
                }
            }
        }

        return detections
    }
}