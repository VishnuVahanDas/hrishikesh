package com.example.hrishikesh

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
    fun getUsageStats(context: Context): List<AppUsageInfo> {
        val usageStatsList = ArrayList<AppUsageInfo>()

        val usageStatsManager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val endTime = System.currentTimeMillis()
        val startTime = endTime - 1000 * 60 * 60 // last 1 hour

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
