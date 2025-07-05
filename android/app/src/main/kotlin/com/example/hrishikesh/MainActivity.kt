package com.example.hrishikesh

import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// For retrieving app usage statistics
import com.example.hrishikesh.UsageStatsHelper

class MainActivity: FlutterActivity() {
    private val CHANNEL = "parent_control/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceId" -> {
                    val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                    result.success(androidId)
                }
                "getUsageStats" -> {
                    val dateMillis = call.argument<Long>("dateMillis")
                    val usageList = UsageStatsHelper.getUsageStats(this, dateMillis)
                    val mapped = usageList.map { usage ->
                        mapOf(
                            "packageName" to usage.packageName,
                            "usage" to usage.totalTimeForeground,
                            "appName" to usage.appName,
                            "icon" to usage.icon
                        )
                    }
                    result.success(mapped)
                }
                "hasUsagePermission" -> {
                    val granted = UsageStatsHelper.hasUsagePermission(this)
                    result.success(granted)
                }
                else -> result.notImplemented()
            }
        }
    }
}
