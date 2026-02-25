package com.audio.audio_query.utils

import android.content.ContentResolver
import android.content.ContentUris
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.util.Size
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.audio.audio_query.PluginProvider
import com.audio.audio_query.helper.QueryHelper
import com.audio.audio_query.types.checkArtworkFormat
import com.audio.audio_query.types.checkArtworkType
import io.flutter.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.io.FileInputStream
import com.audio.audio_query.utils.QueryArtworkColor

/**
 * 优化后的 QueryArtwork（保持原调用逻辑）
 */
class QueryArtwork : ViewModel() {

    companion object {
        private const val TAG = "QueryArtwork"
    }

    private val helper = QueryHelper()

    private var type: Int = -1
    private var id: Number = 0
    private var quality: Int = 100
    private var size: Int = 200
    private lateinit var uri: Uri
    private lateinit var resolver: ContentResolver
    private lateinit var format: Bitmap.CompressFormat

    /**
     * Method to "query" artwork.
     */
    fun queryArtwork() {
        val call = PluginProvider.call()
        val result = PluginProvider.result()
        val context = PluginProvider.context()

        this.resolver = context.contentResolver
        id = call.argument("id")!!
        size = call.argument("size")!!
        quality = call.argument("quality")!!
        if (quality > 100) quality = 50

        format = checkArtworkFormat(call.argument("format")!!)
        uri = checkArtworkType(call.argument("type")!!)
        type = call.argument("type")!!

        Log.d(TAG, "Query config: ")
        Log.d(TAG, "\tid: $id")
        Log.d(TAG, "\tquality: $quality")
        Log.d(TAG, "\tformat: $format")
        Log.d(TAG, "\turi: $uri")
        Log.d(TAG, "\ttype: $type")

        // Query everything in background for a better performance.
        viewModelScope.launch {
            try {
                var resultArtList = loadArt()

                // Sometimes android will extract a 'wrong' or 'empty' artwork. Just set as null.
                if (resultArtList != null && resultArtList.isEmpty()) {
                    Log.i(TAG, "Artwork for '$id' is empty. Returning null")
                    resultArtList = null
                }
                result.success(resultArtList)
            } catch (e: Exception) {
                Log.e(TAG, "queryArtwork failed: ${e.message}", e)
                result.error("QUERY_ERROR", e.message, null)
            }
        }
    }

    fun queryArtworkWithColor() {
        val call = PluginProvider.call()
        val result = PluginProvider.result()
        val context = PluginProvider.context()

        this.resolver = context.contentResolver
        id = call.argument("id")!!
        size = call.argument("size")!!
        quality = call.argument("quality")!!
        if (quality > 100) quality = 50

        format = checkArtworkFormat(call.argument("format")!!)
        uri = checkArtworkType(call.argument("type")!!)
        type = call.argument("type")!!

        Log.d(TAG, "Query config: ")
        Log.d(TAG, "\tid: $id")
        Log.d(TAG, "\tquality: $quality")
        Log.d(TAG, "\tformat: $format")
        Log.d(TAG, "\turi: $uri")
        Log.d(TAG, "\ttype: $type")

        // Query everything in background for a better performance.
        viewModelScope.launch {
            try {
                var resultArtList = loadArt()

                // Sometimes android will extract a 'wrong' or 'empty' artwork. Just set as null.
                if (resultArtList != null && resultArtList.isEmpty()) {
                    Log.i(TAG, "Artwork for '$id' is empty. Returning null")
                    resultArtList = null
                }

                val color = if (resultArtList != null) {
                    QueryArtworkColor().queryArtworkColorSync(resultArtList, id.toString())
                } else {
                    null
                }

                result.success(mapOf("data" to resultArtList, "color" to color))
            } catch (e: Exception) {
                Log.e(TAG, "queryArtworkWithColor failed: ${e.message}", e)
                result.error("QUERY_ERROR", e.message, null)
            }
        }
    }

    // Loading in Background (优化版)
    private suspend fun loadArt(): ByteArray? = withContext(Dispatchers.IO) {
        var bitmap: Bitmap? = null

        try {
            if (Build.VERSION.SDK_INT >= 29) {
                // Android 10+: 使用 loadThumbnail（已经返回正确尺寸）
                val query = if (type == 2 || type == 3 || type == 4) {
                    val item = helper.loadFirstItem(type, id, resolver)
                    if (item == null) return@withContext null
                    ContentUris.withAppendedId(uri, item.toLong())
                } else {
                    ContentUris.withAppendedId(uri, id.toLong())
                }

                bitmap = resolver.loadThumbnail(query, Size(size, size), null)

                // 直接转换，不重复压缩
                return@withContext bitmapToByteArray(bitmap, format, quality)
            } else {
                // Android 9 及以下：使用 MediaMetadataRetriever
                val item = helper.loadFirstItem(type, id, resolver)
                if (item == null) return@withContext null

                try {
                    val file = FileInputStream(item)
                    val metadata = MediaMetadataRetriever()
                    metadata.setDataSource(file.fd)
                    val image = metadata.embeddedPicture

                    var result: ByteArray? = null
                    if (image != null) {
                        // 计算采样率，减少内存占用
                        val options = BitmapFactory.Options().apply {
                            inJustDecodeBounds = true
                        }
                        BitmapFactory.decodeByteArray(image, 0, image.size, options)

                        options.inSampleSize = calculateInSampleSize(options, size, size)
                        options.inJustDecodeBounds = false
                        options.inPreferredConfig = Bitmap.Config.RGB_565

                        val convertedBitmap = BitmapFactory.decodeByteArray(image, 0, image.size, options)
                        result = bitmapToByteArray(convertedBitmap, format, quality)
                        convertedBitmap?.recycle()
                    }

                    // 兼容所有 Android 版本的资源释放
                    file.close()
                    try {
                        if (Build.VERSION.SDK_INT >= 29) {
                            metadata.close()
                        } else {
                            metadata.release()
                        }
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to close MediaMetadataRetriever: ${e.message}")
                    }

                    return@withContext result
                } catch (e: Exception) {
                    Log.w(TAG, "($id) Message: $e")
                    return@withContext null
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "($id) Message: $e")
            return@withContext null
        } finally {
            // 确保回收 Bitmap
            bitmap?.recycle()
        }
    }

    /**
     * Bitmap 转换为 ByteArray（优化版）
     */
    private fun bitmapToByteArray(
        bitmap: Bitmap?,
        format: Bitmap.CompressFormat,
        quality: Int
    ): ByteArray? {
        if (bitmap == null) return null

        val byteArrayBase = ByteArrayOutputStream()
        try {
            bitmap.compress(format, quality, byteArrayBase)
        } catch (e: Exception) {
            Log.w(TAG, "bitmapToByteArray failed: ${e.message}")
            return null
        }

        return try {
            byteArrayBase.toByteArray()
        } finally {
            try {
                byteArrayBase.close()
            } catch (e: Exception) {
                Log.w(TAG, "Failed to close ByteArrayOutputStream: ${e.message}")
            }
        }
    }

    /**
     * 计算采样率（减少内存占用）
     */
    private fun calculateInSampleSize(
        options: BitmapFactory.Options,
        reqWidth: Int,
        reqHeight: Int
    ): Int {
        val (width, height) = options.outWidth to options.outHeight
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2

            while (halfHeight / inSampleSize >= reqHeight &&
                halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }

        return inSampleSize
    }
}