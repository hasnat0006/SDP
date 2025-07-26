package com.sleeptracker
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodChannel

class UnlockReceiver(private val channel: MethodChannel) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_USER_PRESENT) {
            channel.invokeMethod("onUnlock", null)
        }
    }
}