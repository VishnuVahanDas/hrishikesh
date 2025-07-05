package com.example.hrishikesh

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import android.util.Base64
import android.util.Log
import androidx.core.graphics.drawable.toBitmap
import java.io.ByteArrayOutputStream
import java.util.*
import kotlin.collections.ArrayList

data class AppUsageInfo(
    val packageName: String,
    val totalTimeForeground: Long,
    val appName: String,
    val icon: String
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

    fun getUsageStats(context: Context, dateMillis: Long?): List<AppUsageInfo> {
        val usageStatsList = ArrayList<AppUsageInfo>()

        val usageStatsManager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        if (dateMillis != null && dateMillis > 0) {
            calendar.timeInMillis = dateMillis
        }
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = startTime + 24L * 60 * 60 * 1000

        val stats: List<UsageStats> = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val pm = context.packageManager

        if (stats.isNotEmpty()) {
            for (usage in stats) {
                if (usage.totalTimeInForeground > 0) {
                    try {
                        val appInfo = pm.getApplicationInfo(usage.packageName, 0)
                        val label = pm.getApplicationLabel(appInfo).toString()
                        val drawable = pm.getApplicationIcon(appInfo)
                        val bitmap: Bitmap = if (drawable is BitmapDrawable) {
                            drawable.bitmap
                        } else {
                            drawable.toBitmap()
                        }
                        val stream = ByteArrayOutputStream()
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                        val encoded = Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
                        usageStatsList.add(
                            AppUsageInfo(
                                packageName = usage.packageName,
                                totalTimeForeground = usage.totalTimeInForeground,
                                appName = label,
                                icon = encoded
                            )
                        )
                    } catch (e: PackageManager.NameNotFoundException) {
                        Log.w("UsageStatsHelper", "Package not found: ${usage.packageName}")
                    }
                }
            }
        } else {
            Log.w("UsageStatsHelper", "No usage data found. Is permission granted?")
        }

        return usageStatsList
    }
}

