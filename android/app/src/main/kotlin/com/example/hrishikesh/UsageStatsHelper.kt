package com.example.hrishikesh

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import android.util.Log
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList

data class AppUsageInfo(
    val packageName: String,
    val totalTimeForeground: Long
)

object UsageStatsHelper {
    fun hasUsagePermission(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                context.packageName
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                context.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }
    fun getUsageStats(context: Context): List<AppUsageInfo> {
        val usageStatsList = ArrayList<AppUsageInfo>()

        val usageStatsManager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        val endTime = calendar.timeInMillis
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis

        val stats: List<UsageStats> = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        if (stats.isNotEmpty()) {
            for (usage in stats) {
                if (usage.totalTimeInForeground > 0) {
                    usageStatsList.add(
                        AppUsageInfo(
                            packageName = usage.packageName,
                            totalTimeForeground = usage.totalTimeInForeground
                        )
                    )
                }
            }
        } else {
            Log.w("UsageStatsHelper", "No usage data found. Is permission granted?")
        }

        return usageStatsList
    }
}
