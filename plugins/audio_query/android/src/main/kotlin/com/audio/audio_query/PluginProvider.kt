package com.audio.audio_query

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.ContentResolver
import java.lang.ref.WeakReference
import android.os.Build
import androidx.core.app.ActivityCompat
import android.content.pm.PackageManager
import io.flutter.plugin.common.EventChannel

object PluginProvider {
  private const val ERROR_MESSAGE =
    "Tried to get one of the methods but the 'PluginProvider' has not initialized"

  private lateinit var context: WeakReference<Context>

  private lateinit var activity: WeakReference<Activity?>

  private lateinit var call: WeakReference<MethodCall>

  private lateinit var result: WeakReference<MethodChannel.Result>

  private lateinit var contentResolver: WeakReference<ContentResolver>

  private lateinit var progressEventSink: WeakReference<EventChannel.EventSink?>

  fun set(activity: Activity) {
    this.context = WeakReference(activity.applicationContext)
    this.activity = WeakReference(activity)
    this.contentResolver = WeakReference(activity.applicationContext.contentResolver)
  }

  fun setCurrentMethod(call: MethodCall, result: MethodChannel.Result) {
    this.call = WeakReference(call)
    this.result = WeakReference(result)
  }

  fun setProgressEventSink(eventSink: EventChannel.EventSink?) {
    this.progressEventSink = WeakReference(eventSink)
  }

  fun progressEventSink(): EventChannel.EventSink? {
    return this.progressEventSink.get() ?: throw UninitializedPluginProviderException(ERROR_MESSAGE)
  }

  fun context(): Context {
    return this.context.get() ?: throw UninitializedPluginProviderException(ERROR_MESSAGE)
  }

  fun activity(): Activity {
    return this.activity.get() ?: throw UninitializedPluginProviderException(ERROR_MESSAGE)
  }

  fun call(): MethodCall {
    return this.call.get() ?: throw UninitializedPluginProviderException(ERROR_MESSAGE)
  }

  fun result(): MethodChannel.Result {
    return this.result.get() ?: throw UninitializedPluginProviderException(ERROR_MESSAGE)
  }

  fun contentResolver(): ContentResolver {
    return this.contentResolver.get() ?: throw UninitializedPluginProviderException(ERROR_MESSAGE)
  }


  fun checkPermission(): Boolean {
    val context = this.context()

    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      ActivityCompat.checkSelfPermission(
        context,
        android.Manifest.permission.READ_MEDIA_AUDIO
      ) == PackageManager.PERMISSION_GRANTED
    } else {
      ActivityCompat.checkSelfPermission(
        context,
        android.Manifest.permission.READ_EXTERNAL_STORAGE
      ) == PackageManager.PERMISSION_GRANTED
    }
  }


  class UninitializedPluginProviderException(msg: String) : Exception(msg)
}
