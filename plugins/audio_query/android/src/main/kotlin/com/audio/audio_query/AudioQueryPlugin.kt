package com.audio.audio_query

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.audio.audio_query.utils.QueryAudios
import com.audio.audio_query.utils.QueryArtwork
import com.audio.audio_query.utils.AudioUtil
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.Log
import android.content.ContentResolver
import android.content.ContentUris
import android.net.Uri
import java.io.File
import android.provider.MediaStore
import android.os.Build

class AudioQueryPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private val TAG: String = "AudioQueryPlugin"
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private val REQUEST_CODE_DELETE = 1001
    private var pendingResult: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // 初始化MethodChannel
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_query")
        channel.setMethodCallHandler(this)

        // 初始化EventChannel
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "audio_query_progress")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                PluginProvider.setProgressEventSink(events)
            }

            override fun onCancel(arguments: Any?) {
                PluginProvider.setProgressEventSink(null)
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        PluginProvider.setCurrentMethod(call, result)

        when (call.method) {
            "queryAudios" -> {
                try {
                    QueryAudios().queryAudios()
                } catch (e: Exception) {
                    result.error("QUERY_FAILED", e.message, null)
                }
            }

            "deleteMediaFile" -> {
                try {
                    deleteMediaFile()
                } catch (e: Exception) {
                    result.error("DELETE_FAILED", e.message, null)
                }
            }

            "deleteMediaFolder" -> {
                try {
                    deleteMediaFilesInFolder()
                } catch (e: Exception) {
                    result.error("DELETE_FAILED", e.message, null)
                }
            }

            "queryArtwork" -> {
                try {
                    QueryArtwork().queryArtwork()
                } catch (e: Exception) {
                    result.error("QUERY_FAILED", e.message, null)
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.i(TAG, "Attached to activity")
        PluginProvider.set(binding.activity)

        binding.addActivityResultListener { requestCode, resultCode, _ ->
            if (requestCode == REQUEST_CODE_DELETE) {
                if (resultCode == Activity.RESULT_OK) {
                    Log.i("FlutterMediaDelete", "Files deleted successfully")
                    pendingResult?.success(true)
                } else {
                    Log.i("FlutterMediaDelete", "File deletion denied by user")
                    pendingResult?.error(
                        "USER_DENIED",
                        "File deletion was denied by the user",
                        null
                    )
                }
                pendingResult = null
                true
            } else {
                false
            }
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.i(TAG, "Reattached to activity (config changes)")
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.i(TAG, "Detached from engine (config changes)")
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        Log.i(TAG, "Detached from activity")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "Detached from engine")
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    fun deleteMediaFile() {
        val call = PluginProvider.call()
        val result = PluginProvider.result()
        val activity = PluginProvider.activity()
        val contentResolver = PluginProvider.contentResolver()
        val filePath = call.argument<String>("filePath")!!

        if (filePath == null) {
            result.error("INVALID_ARGUMENT", "File path cannot be null", null)
        }

        val file = File(filePath)
        val projection = arrayOf(MediaStore.MediaColumns._ID)
        val selection = "${MediaStore.MediaColumns.DATA}=?"
        val selectionArgs = arrayOf(file.absolutePath)

        // Try to find the media file in all three categories: Video, Audio, Images
        val mediaUri = AudioUtil().findMediaUri(filePath, contentResolver, selection, selectionArgs)

        if (mediaUri != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                try {
                    val deleteRequest =
                        MediaStore.createDeleteRequest(
                            contentResolver,
                            listOf(mediaUri)
                        ).intentSender
                    activity!!.startIntentSenderForResult(
                        deleteRequest,
                        REQUEST_CODE_DELETE,
                        null,
                        0,
                        0,
                        0
                    )
                    pendingResult = result
                } catch (e: Exception) {
                    Log.e("FlutterMediaDelete", "Error deleting file", e)
                    result.error("ERROR", "Delete request failed", e.message)
                }
            } else {
                // Handle file deletion directly for older Android versions
                try {
                    val rowsDeleted = contentResolver.delete(mediaUri, null, null)
                    if (rowsDeleted > 0) {
                        result.success(true)
                    } else {
                        result.error("DELETE_FAILED", "Failed to delete file", null)
                    }
                } catch (e: Exception) {
                    Log.e("FlutterMediaDelete", "Error deleting file", e)
                    result.error("ERROR", "Failed to delete file", e.message)
                }
            }
        } else {
            result.error("FILE_NOT_FOUND", "File not found", null)
        }
    }

    fun deleteMediaFilesInFolder() {
        val contentResolver = PluginProvider.contentResolver()
        val call = PluginProvider.call()
        val folderPath = call.argument<String>("folderPath")
        val result = PluginProvider.result()
        val activity = PluginProvider.activity()
        val selection = "${MediaStore.MediaColumns.DATA} LIKE ?"
        val selectionArgs = arrayOf("$folderPath/%")
        val urisToDelete = mutableListOf<Uri>()

        // Fetch all media types (Video, Audio, Images) from MediaStore
        urisToDelete.addAll(
            AudioUtil().queryMediaUris(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                contentResolver,
                selection,
                selectionArgs
            )
        )
        urisToDelete.addAll(
            AudioUtil().queryMediaUris(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                contentResolver,
                selection,
                selectionArgs
            )
        )
        urisToDelete.addAll(
            AudioUtil().queryMediaUris(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                contentResolver,
                selection,
                selectionArgs
            )
        )

        if (urisToDelete.isEmpty()) {
            result.success(true)
            return
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val deleteRequest =
                    MediaStore.createDeleteRequest(contentResolver, urisToDelete).intentSender
                activity!!.startIntentSenderForResult(
                    deleteRequest,
                    REQUEST_CODE_DELETE,
                    null,
                    0,
                    0,
                    0
                )
                pendingResult = result
            } else {
                // Directly delete files for older Android versions
                var success = true
                for (uri in urisToDelete) {
                    val rowsDeleted = contentResolver.delete(uri, null, null)
                    if (rowsDeleted <= 0) {
                        success = false
                    }
                }
                if (success) {
                    result.success(true)
                } else {
                    result.error("DELETE_FAILED", "Failed to delete some files", null)
                }
            }
        } catch (e: Exception) {
            Log.e("FlutterMediaDelete", "Error deleting files", e)
            result.error("ERROR", "Failed to create delete request", e.message)
        }
    }
}

