package com.example.hrishikesh

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class AppMonitoringService : Service() {

    private val CHANNEL_ID = "HrishikeshMonitorChannel"

    override fun onCreate() {
        super.onCreate()
        Log.d("AppMonitoringService", "Service Created")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val usageList = UsageStatsHelper.getUsageStats(this, null)
        for (app in usageList) {
            Log.d("AppUsage", "Package: ${app.packageName}, Time: ${app.totalTimeForeground / 1000} sec")
        }

        Log.d("AppMonitoringService", "Service Started")

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Hrishikesh Monitoring")
            .setContentText("Your device is being monitored by parents.")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        startForeground(1, notification)

        // TODO: Start your monitoring logic here (e.g., usage tracking)

        return START_STICKY
    }

    override fun onDestroy() {
        Log.d("AppMonitoringService", "Service Destroyed")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Hrishikesh Child Monitor",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(serviceChannel)
        }
    }
}
