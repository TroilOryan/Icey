package com.audio.audio_query.utils

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.util.LruCache
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.palette.graphics.Palette
import com.audio.audio_query.PluginProvider
import io.flutter.Log
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.math.min

/**
 * 精简版QueryArtwork，专注于图片颜色解析功能
 * 保留原有类名和核心结构，删除媒体库查询相关代码
 */
class QueryArtworkColor : ViewModel() {
    companion object {
        private const val TAG = "QueryArtwork"
        private const val COLOR_ANALYSIS_SIZE = 100 // 固定分析尺寸
        private const val CACHE_SIZE = 50 // 缓存大小
        private const val CACHE_EXPIRE_MINUTES = 5 // 缓存有效期（分钟）
    }

    /**
     * 缓存数据类
     */
    private data class CacheEntry(
        val primaryColor: Int,
        val secondaryColor: Int?,
        val isDark: Boolean,
        val timestamp: Long = System.currentTimeMillis()
    )

    // 颜色解析结果缓存
    private val colorCache = LruCache<String, CacheEntry>(CACHE_SIZE)

    // 协程异常处理器
    private val coroutineExceptionHandler = CoroutineExceptionHandler { _, throwable ->
        Log.e(TAG, "协程执行异常: ${throwable.message}", throwable)
        try {
            val result = PluginProvider.result()
            result.error("ANALYSIS_ERROR", throwable.message, throwable.stackTraceToString())
        } catch (e: Exception) {
            Log.e(TAG, "传递异常到result失败", e)
        }
    }

    suspend fun queryArtworkColorSync(data: ByteArray, cacheKey: String): Map<String, Any?>? =
        withContext(Dispatchers.IO) {
            processImageData(data, cacheKey)
        }

    /**
     * 处理图片数据并解析颜色
     */
    private suspend fun processImageData(
        imageData: ByteArray,
        cacheKey: String?
    ): Map<String, Any?> =
        withContext(Dispatchers.IO) {
            // 检查缓存
            cacheKey?.let { key ->
                colorCache.get(key)?.let { entry ->
                    if (System.currentTimeMillis() - entry.timestamp < CACHE_EXPIRE_MINUTES * 60 * 1000) {
                        Log.d(TAG, "使用缓存结果: $key")
                        return@withContext mapOf(
                            "primaryColor" to entry.primaryColor,
                            "secondaryColor" to entry.secondaryColor,
                            "isDark" to entry.isDark
                        )
                    }
                    colorCache.remove(key)
                    Log.d(TAG, "缓存已过期: $key")
                }
            }

            // 解析图片并提取颜色
            val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
            val (primaryColor, secondaryColor, isDark) = extractColors(bitmap)
            bitmap.recycle()

            // 存入缓存
            cacheKey?.let { key ->
                colorCache.put(
                    key, CacheEntry(
                        primaryColor = primaryColor,
                        secondaryColor = secondaryColor,
                        isDark = isDark
                    )
                )
                Log.d(TAG, "存入缓存: $key")
            }

            return@withContext mapOf(
                "primaryColor" to primaryColor,
                "secondaryColor" to secondaryColor,
                "isDark" to isDark
            )
        }

    /**
     * 提取颜色核心方法
     */
    private fun extractColors(bitmap: Bitmap): Triple<Int, Int?, Boolean> {
        return try {
            // 缩放到固定尺寸分析（100x100px）
            val scale = min(
                COLOR_ANALYSIS_SIZE.toFloat() / bitmap.width,
                COLOR_ANALYSIS_SIZE.toFloat() / bitmap.height
            )
            val scaledBitmap = Bitmap.createScaledBitmap(
                bitmap,
                (bitmap.width * scale).toInt(),
                (bitmap.height * scale).toInt(),
                true // 使用双线性过滤，保持图片质量
            )

            val palette = Palette.from(scaledBitmap)
                .maximumColorCount(32)
                .clearFilters()
                .generate()

            val sortedSwatches = palette.swatches
                .filterNotNull()
                .sortedByDescending { it.population }

            val totalPopulation = sortedSwatches.sumOf { it.population.toLong() }.toFloat()
            // 将比较的0.05显式转为Float，同时将it.population转为Float确保除法精度
            val significantSwatches =
                sortedSwatches.filter { it.population.toFloat() / totalPopulation > 0.05f }

            val primaryColor = significantSwatches.getOrNull(0)?.rgb ?: Color.WHITE
            val secondaryColor = significantSwatches.getOrNull(1)?.rgb ?: Color.WHITE
            val isDark =
                (Color.luminance(primaryColor) < 0.4) || (Color.luminance(secondaryColor) < 0.4)

            scaledBitmap.recycle()
            Triple(primaryColor, secondaryColor, isDark)
        } catch (e: Exception) {
            Log.e(TAG, "颜色提取异常", e)
            Triple(Color.BLACK, null, true)
        }
    }

    /**
     * 清除所有缓存
     */
    fun clearCache() {
        colorCache.evictAll()
        Log.d(TAG, "已清除所有缓存")
    }

    /**
     * 清除指定缓存
     */
    fun removeCache(cacheKey: String) {
        colorCache.remove(cacheKey)
        Log.d(TAG, "已清除缓存: $cacheKey")
    }
}
