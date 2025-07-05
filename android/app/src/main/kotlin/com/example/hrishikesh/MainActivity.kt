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
                    val usageList = UsageStatsHelper.getUsageStats(this)
                    val mapped = usageList.map { usage ->
                        mapOf(
                            "packageName" to usage.packageName,
                            "usage" to usage.totalTimeForeground
                        )
                    }
                    result.success(mapped)
                }
                else -> result.notImplemented()
            }
        }
    }
}
