package com.example.flutter_posts

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlin.random.Random

class MainActivity : FlutterActivity() {

    private val channelId = "likes_channel"
    private val notificationPermissionRequestCode = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Request notification permission (Android 13+)
        requestNotificationPermission()

        // Create notification channel
        createNotificationChannel()

        // Pigeon: Flutter → Android
        NativeNotificationApi.setUp(
            flutterEngine.dartExecutor.binaryMessenger,
            object : NativeNotificationApi {

                override fun showNotification(payload: NotificationPayload) {
                    Toast.makeText(
                        this@MainActivity,
                        "Native notification sent",
                        Toast.LENGTH_SHORT
                    ).show()

                    val notification = NotificationCompat.Builder(
                        this@MainActivity,
                        channelId
                    )
                        .setSmallIcon(android.R.drawable.btn_star_big_on)
                        .setContentTitle(payload.title)
                        .setContentText(payload.body)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setCategory(NotificationCompat.CATEGORY_SOCIAL)
                        .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                        .setAutoCancel(true)
                        .build()

                    NotificationManagerCompat.from(this@MainActivity)
                        .notify(Random.nextInt(), notification)
                }
            }
        )
    }

    // Runtime permission for Android 13+
    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                    notificationPermissionRequestCode
                )
            }
        }
    }

    // Notification channel (Android 8+)
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Likes notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for post likes"
                enableVibration(true)
            }

            val manager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }
}
