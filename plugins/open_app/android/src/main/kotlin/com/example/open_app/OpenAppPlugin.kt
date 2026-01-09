package com.example.open_app

import androidx.annotation.NonNull
import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.content.Context
import android.net.Uri

import android.os.Parcelable


import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AppActivityLauncherPlugin */
class OpenAppPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "open_app")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "openApp" -> {
                val appId = call.argument<String>("appId")
                val extras = call.argument<Map<String, String>>("extras")
                val res = openApp(appId, extras)
                result.success(res)
            }
            "openMarket" -> {
                val appId = call.argument<String>("appId")
                val extras = call.argument<Map<String, String>>("extras")
                val res = openMarket(appId, extras)
                result.success(res)
            }
            "openActivity" -> {
                val appId = call.argument<String>("appId")
                val act = call.argument<String>("activity")
                val extras = call.argument<Map<String, String>>("extras")
                val res = openActivity(appId, act, extras)
                result.success(res)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun openApp(appId: String?, extras: Map<String, String>?): Boolean {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(FLAG_ACTIVITY_NEW_TASK)
        if (appId != null)
            intent.setPackage(appId)
        if (extras != null) {
            for ((key, value) in extras) {
                intent.putExtra(key, value)
            }
        }
        try {
            context.startActivity(intent)
            return true
        } catch (e: Exception) {
            println(e)
            return false
        }
    }

    private fun openMarket(appId: String?, extras: Map<String, String>?): Boolean {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(FLAG_ACTIVITY_NEW_TASK)
        if (appId != null)
            intent.data = Uri.parse("market://details?id=$appId")
        if (extras != null) {
            for ((key, value) in extras) {
                intent.putExtra(key, value)
            }
        }
        try {
            context.startActivity(intent)
            return true
        } catch (e: Exception) {
            println(e)
            return false
        }
    }

    private fun openActivity(appId: String?, act: String?, extras: Map<String, String>?): Boolean {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(FLAG_ACTIVITY_NEW_TASK)
        if (appId != null && act != null)
            intent.setClassName(
                "$appId",
                "$appId.$act"
            )
        if (extras != null) {
            for ((key, value) in extras) {
                intent.putExtra(key, value)
            }
        }
        try {
            context.startActivity(intent)
            return true
        } catch (e: Exception) {
            println(e)
            return false
        }
    }

}