package com.dancediary.app.media

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.text.ParsePosition
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.math.max
import kotlin.math.roundToInt

internal data class MediaInfo(
    val durationMs: Long,
    val width: Int,
    val height: Int,
    val metadataRecordedAtEpochMs: Long?,
)

internal interface MediaBackend {
    fun inspect(absolutePath: String): MediaInfo

    fun generateThumbnail(
        videoAbsolutePath: String,
        outputAbsolutePath: String,
        maxWidth: Int,
    ): String
}

internal class MediaBridgeHandler(
    private val backend: MediaBackend,
    private val workerDispatcher: ((() -> Unit) -> Unit),
    private val resultDispatcher: ((() -> Unit) -> Unit),
) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "inspectVideo" -> inspectVideo(call, result)
            "generateThumbnail" -> generateThumbnail(call, result)
            else -> resultDispatcher { result.notImplemented() }
        }
    }

    private fun inspectVideo(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        val absolutePath = arguments?.get("absolutePath") as? String
        if (absolutePath == null || !isAbsolutePath(absolutePath)) {
            invalidArguments(result)
            return
        }

        workerDispatcher {
            try {
                val info = backend.inspect(absolutePath)
                resultDispatcher {
                    result.success(
                        mapOf(
                            "durationMs" to info.durationMs,
                            "width" to info.width,
                            "height" to info.height,
                            "metadataRecordedAtEpochMs" to info.metadataRecordedAtEpochMs,
                        ),
                    )
                }
            } catch (_: Exception) {
                resultDispatcher { result.error("media_inspection_failed", null, null) }
            }
        }
    }

    private fun generateThumbnail(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        val videoAbsolutePath = arguments?.get("videoAbsolutePath") as? String
        val outputAbsolutePath = arguments?.get("outputAbsolutePath") as? String
        val maxWidth = (arguments?.get("maxWidth") as? Number)?.toInt()
        if (videoAbsolutePath == null ||
            !isAbsolutePath(videoAbsolutePath) ||
            outputAbsolutePath == null ||
            !isAbsolutePath(outputAbsolutePath) ||
            maxWidth == null ||
            maxWidth <= 0
        ) {
            invalidArguments(result)
            return
        }

        workerDispatcher {
            try {
                val outputPath = backend.generateThumbnail(
                    videoAbsolutePath,
                    outputAbsolutePath,
                    maxWidth,
                )
                resultDispatcher { result.success(outputPath) }
            } catch (_: Exception) {
                resultDispatcher { result.error("thumbnail_generation_failed", null, null) }
            }
        }
    }

    private fun invalidArguments(result: MethodChannel.Result) {
        resultDispatcher { result.error("invalid_arguments", null, null) }
    }

    private fun isAbsolutePath(path: String?): Boolean {
        if (path.isNullOrBlank()) return false
        return path.startsWith('/') ||
            path.startsWith("\\\\") ||
            WINDOWS_ABSOLUTE_PATH.matches(path)
    }

    private companion object {
        val WINDOWS_ABSOLUTE_PATH = Regex("^[A-Za-z]:[\\\\/].*")
    }
}

internal class AndroidMediaBackend : MediaBackend {
    override fun inspect(absolutePath: String): MediaInfo {
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(absolutePath)
            return MediaInfo(
                durationMs = requiredLong(retriever, MediaMetadataRetriever.METADATA_KEY_DURATION),
                width = requiredInt(retriever, MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH),
                height = requiredInt(retriever, MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT),
                metadataRecordedAtEpochMs = parseRecordedAt(
                    retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE),
                ),
            )
        } finally {
            retriever.release()
        }
    }

    override fun generateThumbnail(
        videoAbsolutePath: String,
        outputAbsolutePath: String,
        maxWidth: Int,
    ): String {
        val retriever = MediaMetadataRetriever()
        var frame: Bitmap? = null
        var outputBitmap: Bitmap? = null
        try {
            retriever.setDataSource(videoAbsolutePath)
            frame = retriever.getFrameAtTime(0L, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                ?: error("Video frame is unavailable")
            outputBitmap = scaleDown(frame, maxWidth)
            FileOutputStream(File(outputAbsolutePath)).use { stream ->
                check(outputBitmap.compress(Bitmap.CompressFormat.JPEG, 85, stream)) {
                    "JPEG encoding failed"
                }
            }
            return outputAbsolutePath
        } finally {
            if (outputBitmap !== frame) outputBitmap?.recycle()
            frame?.recycle()
            retriever.release()
        }
    }

    private fun requiredLong(retriever: MediaMetadataRetriever, key: Int): Long =
        retriever.extractMetadata(key)?.toLongOrNull()
            ?: error("Required video metadata is unavailable")

    private fun requiredInt(retriever: MediaMetadataRetriever, key: Int): Int =
        retriever.extractMetadata(key)?.toIntOrNull()
            ?: error("Required video metadata is unavailable")

    private fun scaleDown(bitmap: Bitmap, maxWidth: Int): Bitmap {
        val longestEdge = max(bitmap.width, bitmap.height)
        if (longestEdge <= maxWidth) return bitmap

        val scale = maxWidth.toDouble() / longestEdge.toDouble()
        val targetWidth = (bitmap.width * scale).roundToInt().coerceAtLeast(1)
        val targetHeight = (bitmap.height * scale).roundToInt().coerceAtLeast(1)
        return Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, true)
    }

    private fun parseRecordedAt(rawValue: String?): Long? {
        if (rawValue.isNullOrBlank()) return null
        for (pattern in RECORDED_AT_PATTERNS) {
            val formatter = SimpleDateFormat(pattern, Locale.US).apply {
                isLenient = false
                timeZone = UTC
            }
            val position = ParsePosition(0)
            val parsed = formatter.parse(rawValue, position)
            if (parsed != null && position.index == rawValue.length) return parsed.time
        }
        return null
    }

    private companion object {
        val UTC: TimeZone = TimeZone.getTimeZone("UTC")
        val RECORDED_AT_PATTERNS = listOf(
            "yyyyMMdd'T'HHmmss.SSSX",
            "yyyyMMdd'T'HHmmssX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSX",
            "yyyy-MM-dd'T'HH:mm:ssX",
        )
    }
}

internal class MediaBridge(
    messenger: BinaryMessenger,
    private val executor: ExecutorService = Executors.newSingleThreadExecutor(),
    backend: MediaBackend = AndroidMediaBackend(),
    mainHandler: Handler = Handler(Looper.getMainLooper()),
) {
    private val channel = MethodChannel(messenger, CHANNEL_NAME)

    init {
        channel.setMethodCallHandler(
            MediaBridgeHandler(
                backend,
                { task -> executor.execute(task) },
                { task -> mainHandler.post(task) },
            ),
        )
    }

    fun close() {
        channel.setMethodCallHandler(null)
        executor.shutdownNow()
    }

    companion object {
        const val CHANNEL_NAME = "com.dancediary.app/media"
    }
}
