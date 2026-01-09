package com.audio.audio_query.utils

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Log
import com.audio.audio_query.PluginProvider
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Semaphore
import java.util.*
import java.util.concurrent.atomic.AtomicInteger
import kotlin.collections.HashSet
import com.audio.audio_query.utils.QueryArtworkColor

class QueryAudios {
    // 使用SupervisorJob确保子协程失败不影响其他协程
    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    // 添加异常处理器
    private val exceptionHandler = CoroutineExceptionHandler { _, throwable ->
        Log.e("QueryAudios", "全局协程异常: ${throwable.message}", throwable)
    }

    // 信号量控制最大并发数
    private val semaphore = Semaphore(5) // 限制最大5个并发

    // 用于跟踪已处理的音频ID，防止重复
    private val processedIds = Collections.synchronizedSet(HashSet<Long>())

    // 原子整数用于计数已处理项
    private val processedCount = AtomicInteger(0)
    fun queryAudios() {
        val result = PluginProvider.result()
        val context = PluginProvider.context() ?: run {
            result.error("CONTEXT_ERROR", "无法获取应用上下文", null)
            return
        }

        val contentResolver = PluginProvider.contentResolver()
        val eventSink = PluginProvider.progressEventSink()

        // 检查权限
        if (!PluginProvider.checkPermission()) {
            result.error("PERMISSION_DENIED", "存储权限未授予", null)
            return
        }

        // 音频文件投影字段
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ARTIST_ID,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.TRACK,
            MediaStore.Audio.Media.YEAR,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.BITRATE,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DATE_ADDED,
            MediaStore.Audio.Media.DATE_MODIFIED,
        )

        try {
            val cursor = contentResolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projection,
                "${MediaStore.Audio.Media.IS_MUSIC} != 0",
                null,
                MediaStore.Audio.Media.DEFAULT_SORT_ORDER
            )

            coroutineScope.launch(exceptionHandler) {
                try {
                    cursor?.use { audioCursor ->
                        if (audioCursor.count == 0) {
                            sendCompletionSignal()
                            return@launch
                        }

                        // 预加载所有音频数据到列表，避免并发访问Cursor
                        val audioList = mutableListOf<AudioItem>()
                        while (audioCursor.moveToNext()) {
                            audioList.add(AudioItem.fromCursor(audioCursor))
                        }

                        Log.d("QueryAudios", "预加载完成，共${audioList.size}个音频文件")

                        // 基于预加载列表创建并行任务
                        processAudioList(audioList)

                        // 发送完成信号
                        sendCompletionSignal()
                    } ?: run {
                        Log.e("QueryAudios", "查询音频Cursor为空")
                        result.error("QUERY_FAILED", "无法查询音频文件", null)
                    }
                } catch (e: Exception) {
                    Log.e("QueryAudios", "音频扫描过程异常", e)
                    result.error("SCAN_ERROR", "音频扫描失败: ${e.message}", null)
                } finally {
                    // 取消协程作用域，释放资源
                    coroutineScope.cancel()
                }
            }
        } catch (e: Exception) {
            Log.e("QueryAudios", "初始化查询异常", e)
            result.error("INIT_FAILED", "初始化音频查询失败", null)
        }
    }

    /**
     * 处理预加载的音频列表
     */
    private suspend fun processAudioList(audioList: List<AudioItem>) {
        val processingJobs = mutableListOf<Deferred<Unit>>()

        // 为每个音频项创建处理任务
        for (audioItem in audioList) {
            val job = coroutineScope.async(exceptionHandler) {
                semaphore.acquire()
                try {
                    processAudioItem(audioItem)
                } finally {
                    semaphore.release()
                }
            }
            processingJobs.add(job)

            // 每10个任务等待一次，避免任务创建过多导致内存问题
            if (processingJobs.size % 10 == 0) {
                processingJobs.takeLast(10).awaitAll()
            }
        }

        // 等待剩余任务完成
        processingJobs.awaitAll()
        Log.d("QueryAudios", "所有音频处理完成，总处理: ${processedCount.get()}/${audioList.size}")
    }

    /**
     * 处理单个预加载的音频项
     */
    private suspend fun processAudioItem(audioItem: AudioItem) {
        // 检查是否已处理，防止重复
        if (!processedIds.add(audioItem.id)) {
            Log.w("QueryAudios", "检测到重复音频ID: ${audioItem.id}, 标题: ${audioItem.title}")
            return
        }

        val eventSink = PluginProvider.progressEventSink() ?: return

        // 使用use块确保MediaMetadataRetriever正确释放
        MediaMetadataRetriever().use { retriever ->
            try {
                // 设置数据源
                retriever.setDataSource(audioItem.dataPath)

                // 提取原始尺寸封面
                val coverImage = extractOriginalCover(retriever, audioItem.id.toString())

                // 使用挂起函数同步获取颜色结果
                val color = if (coverImage != null) {
                    QueryArtworkColor().queryArtworkColorSync(coverImage, audioItem.id.toString())
                } else {
                    null
                }


                val audioData = mutableMapOf<String, Any?>().apply {
                    // 基本信息（来自预加载的AudioItem）
                    put("_id", audioItem.id)
                    put("title", audioItem.title)
                    put("artist", audioItem.artist)
                    put("artist_id", audioItem.artistId)
                    put("album", audioItem.album)
                    put("album_id", audioItem.albumId)
                    put("track", audioItem.track)
                    put("year", audioItem.year)
                    put("duration", audioItem.duration)
                    put("_data", audioItem.dataPath)
                    put("_uri", audioItem.uri)
                    put("date_added", audioItem.dateAdded)
                    put("date_modified", audioItem.dateModified)

                    // 技术参数（从MediaMetadataRetriever提取）
                    put("bitRate", getBitRate(retriever, audioItem.bitRate))
                    put("sampleRate", getSampleRate(retriever))
                    put("bitDepth", getBitDepth(retriever))
                    put(
                        "quality", getAudioQuality(
                            getSampleRate(retriever),
                            getBitDepth(retriever)
                        )
                    )

                    // 添加封面图片
                    put("cover_image", coverImage) // 原始尺寸封面字节数组，无封面时为null

                    put("color", color)
                }

                // 在主线程发送数据
                withContext(Dispatchers.Main) {
                    eventSink.success(
                        mapOf(
                            "type" to "data",
                            "data" to audioData
                        )
                    )
                }

                // 原子操作递增计数
                val currentCount = processedCount.incrementAndGet()
                Log.d("QueryAudios", "已处理: $currentCount, 音频: ${audioItem.title}")

                // 短暂延迟避免事件发送过快
                delay(10)
            } catch (e: Exception) {
                Log.e("QueryAudios", "处理音频失败: ${audioItem.title} (ID: ${audioItem.id})", e)
                // 处理失败时从已处理集合中移除，允许重试
                processedIds.remove(audioItem.id)
            }
        }
    }

    /**
     * 提取原始尺寸封面图片
     * @param retriever MediaMetadataRetriever实例
     * @param audioId 音频ID，用于缓存键
     * @return 原始封面字节数组，无封面时返回null
     */
    private suspend fun extractOriginalCover(
        retriever: MediaMetadataRetriever,
        audioId: String
    ): ByteArray? = withContext(Dispatchers.IO) {
        try {
            // 提取原始封面字节数组（不缩放，保持原始尺寸）
            val coverBytes = retriever.embeddedPicture
            if (coverBytes != null) {
                // 存入缓存
                return@withContext coverBytes
            }
            return@withContext null
        } catch (e: Exception) {
            Log.e("QueryAudios", "提取封面失败", e)
            return@withContext null
        }
    }

    /**
     * 获取比特率
     */
    private fun getBitRate(retriever: MediaMetadataRetriever, cursorBitRate: Int): Int {
        return try {
            if (cursorBitRate > 0) cursorBitRate else {
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)
                    ?.toIntOrNull() ?: 0
            }
        } catch (e: NumberFormatException) {
            0
        }
    }

    /**
     * 获取采样率
     */
    private fun getSampleRate(retriever: MediaMetadataRetriever): Int {
        return try {
            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_SAMPLERATE)?.toIntOrNull()
                ?: 0
        } catch (e: NumberFormatException) {
            0
        }
    }

    /**
     * 获取比特深度
     */
    private fun getBitDepth(retriever: MediaMetadataRetriever): Int {
        return try {
            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITS_PER_SAMPLE)
                ?.toIntOrNull()
                ?: 0
        } catch (e: NumberFormatException) {
            0
        }
    }

    /**
     * 判断音频质量等级
     */
    private fun getAudioQuality(sampleRate: Int?, bitDepth: Int?): String {
        val validSampleRate = sampleRate ?: 0
        val validBitDepth = bitDepth ?: 0

        return when {
            validSampleRate >= 44100 && validBitDepth >= 24 -> "HR"
            validSampleRate in 44100..48000 && validBitDepth in 16..23 -> "SQ"
            else -> "HQ"
        }
    }

    /**
     * 发送完成信号
     */
    private fun sendCompletionSignal() {
        val eventSink = PluginProvider.progressEventSink() ?: return

        Handler(Looper.getMainLooper()).post {
            eventSink.success(
                mapOf(
                    "type" to "complete",
                    "processedCount" to processedCount.get()
                )
            )
        }
    }

    /**
     * 取消所有协程任务
     */
    fun cancel() {
        coroutineScope.cancel()
        processedIds.clear()
        processedCount.set(0)
        Log.d("QueryAudios", "扫描已取消")
    }

    /**
     * 音频数据模型类，存储预加载的音频信息
     */
    data class AudioItem(
        val id: Long,
        val title: String?,
        val artist: String?,
        val artistId: Number,
        val album: String?,
        val albumId: Number,
        val track: Int,
        val year: Int,
        val duration: Long,
        val bitRate: Int,
        val size: Long,
        val dataPath: String,
        val uri: String,
        val dateAdded: Long,
        val dateModified: Long
    ) {
        companion object {
            /**
             * 从Cursor创建AudioItem，预加载所有必要数据
             */
            fun fromCursor(cursor: Cursor): AudioItem {
                // 获取ID（处理不同Android版本）
                val id = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID))
                } else {
                    cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)).toLong()
                }

                // 创建音频URI
                val audioUri = ContentUris.withAppendedId(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    id
                ).toString()

                // 获取艺术家ID和专辑ID（处理不同Android版本）
                val artistId = getColumnValue(cursor, MediaStore.Audio.Media.ARTIST_ID)
                val albumId = getColumnValue(cursor, MediaStore.Audio.Media.ALBUM_ID)

                return AudioItem(
                    id = id,
                    title = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)),
                    artist = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)),
                    artistId = artistId,
                    album = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)),
                    albumId = albumId,
                    track = cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TRACK)),
                    year = cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.YEAR)),
                    duration = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)),
                    bitRate = try {
                        cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.BITRATE))
                    } catch (e: Exception) {
                        0
                    },
                    size = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)),
                    dataPath = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)),
                    uri = audioUri,
                    dateAdded = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)),
                    dateModified = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_MODIFIED))
                )
            }

            /**
             * 根据Android版本获取正确的列值（Int或Long）
             */
            private fun getColumnValue(cursor: Cursor, columnName: String): Number {
                val columnIndex = cursor.getColumnIndexOrThrow(columnName)
                return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    cursor.getLong(columnIndex)
                } else {
                    cursor.getInt(columnIndex)
                }
            }
        }
    }
}

/**
 * 辅助函数：获取列值（兼容不同Android版本）
 */
private fun getColumnValue(cursor: Cursor, columnName: String): Number {
    val columnIndex = cursor.getColumnIndexOrThrow(columnName)
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        cursor.getLong(columnIndex)
    } else {
        cursor.getInt(columnIndex)
    }
}

/**
 * 辅助函数：获取比特率
 */
private fun getBitRate(retriever: MediaMetadataRetriever, cursorBitRate: Int): Int {
    return try {
        if (cursorBitRate > 0) cursorBitRate else {
            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)?.toIntOrNull()
                ?: 0
        }
    } catch (e: NumberFormatException) {
        0
    }
}

/**
 * 辅助函数：获取采样率
 */
private fun getSampleRate(retriever: MediaMetadataRetriever): Int {
    return try {
        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_SAMPLERATE)?.toIntOrNull()
            ?: 0
    } catch (e: NumberFormatException) {
        0
    }
}

/**
 * 辅助函数：获取比特深度
 */
private fun getBitDepth(retriever: MediaMetadataRetriever): Int {
    return try {
        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITS_PER_SAMPLE)
            ?.toIntOrNull()
            ?: 0
    } catch (e: NumberFormatException) {
        0
    }
}

/**
 * 辅助函数：获取音频质量
 */
private fun getAudioQuality(sampleRate: Int?, bitDepth: Int?): String {
    val validSampleRate = sampleRate ?: 0
    val validBitDepth = bitDepth ?: 0

    return when {
        validSampleRate >= 44100 && validBitDepth >= 24 -> "HR"
        validSampleRate in 44100..48000 && validBitDepth in 16..23 -> "SQ"
        else -> "HQ"
    }
}
