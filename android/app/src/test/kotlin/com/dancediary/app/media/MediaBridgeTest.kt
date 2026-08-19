package com.dancediary.app.media

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class MediaBridgeTest {
    @Test
    fun inspectVideoRunsOnWorkerAndReturnsPortablePayloadOnResultDispatcher() {
        val backend = FakeMediaBackend()
        val worker = QueuedDispatcher()
        val results = QueuedDispatcher()
        val handler = MediaBridgeHandler(backend, worker::dispatch, results::dispatch)
        val result = RecordingResult()

        handler.onMethodCall(
            MethodCall("inspectVideo", mapOf("absolutePath" to "/data/user/0/app/video.mp4")),
            result,
        )

        assertNull(backend.inspectedPath)
        assertFalse(result.completed)
        worker.runNext()
        assertEquals("/data/user/0/app/video.mp4", backend.inspectedPath)
        assertFalse(result.completed)
        results.runNext()
        val payload = result.successValue as Map<*, *>
        assertEquals(
            setOf("durationMs", "width", "height", "metadataRecordedAtEpochMs"),
            payload.keys,
        )
        assertEquals(1_234L, payload["durationMs"])
        assertEquals(1920, payload["width"])
        assertEquals(1080, payload["height"])
        assertEquals(1_785_499_200_000L, payload["metadataRecordedAtEpochMs"])
    }

    @Test
    fun inspectVideoRejectsMissingOrRelativePaths() {
        val backend = FakeMediaBackend()
        val handler = directHandler(backend)

        val missing = RecordingResult()
        handler.onMethodCall(MethodCall("inspectVideo", emptyMap<String, Any?>()), missing)
        val relative = RecordingResult()
        handler.onMethodCall(
            MethodCall("inspectVideo", mapOf("absolutePath" to "video.mp4")),
            relative,
        )

        assertEquals("invalid_arguments", missing.errorCode)
        assertEquals("invalid_arguments", relative.errorCode)
        assertNull(backend.inspectedPath)
    }

    @Test
    fun inspectVideoMapsBackendFailureToStableError() {
        val backend = FakeMediaBackend(inspectFailure = IllegalStateException("device detail"))
        val result = RecordingResult()

        directHandler(backend).onMethodCall(
            MethodCall("inspectVideo", mapOf("absolutePath" to "/data/video.mp4")),
            result,
        )

        assertEquals("media_inspection_failed", result.errorCode)
        assertNull(result.errorMessage)
        assertNull(result.errorDetails)
    }

    @Test
    fun generateThumbnailForwardsPathsAndCap() {
        val backend = FakeMediaBackend()
        val result = RecordingResult()

        directHandler(backend).onMethodCall(
            MethodCall(
                "generateThumbnail",
                mapOf(
                    "videoAbsolutePath" to "/data/video.mp4",
                    "outputAbsolutePath" to "/data/thumb.jpg",
                    "maxWidth" to 320,
                ),
            ),
            result,
        )

        assertEquals(ThumbnailRequest("/data/video.mp4", "/data/thumb.jpg", 320), backend.thumbnailRequest)
        assertEquals("/data/thumb.jpg", result.successValue)
    }

    @Test
    fun generateThumbnailRejectsInvalidArguments() {
        val backend = FakeMediaBackend()
        val handler = directHandler(backend)
        val calls = listOf(
            MethodCall(
                "generateThumbnail",
                mapOf("outputAbsolutePath" to "/data/thumb.jpg", "maxWidth" to 512),
            ),
            MethodCall(
                "generateThumbnail",
                mapOf(
                    "videoAbsolutePath" to "/data/video.mp4",
                    "outputAbsolutePath" to "thumb.jpg",
                    "maxWidth" to 512,
                ),
            ),
            MethodCall(
                "generateThumbnail",
                mapOf(
                    "videoAbsolutePath" to "/data/video.mp4",
                    "outputAbsolutePath" to "/data/thumb.jpg",
                    "maxWidth" to 0,
                ),
            ),
        )

        val results = calls.map { call -> RecordingResult().also { handler.onMethodCall(call, it) } }

        assertTrue(results.all { it.errorCode == "invalid_arguments" })
        assertNull(backend.thumbnailRequest)
    }

    @Test
    fun generateThumbnailMapsBackendFailureToStableError() {
        val backend = FakeMediaBackend(thumbnailFailure = IllegalStateException("codec detail"))
        val result = RecordingResult()

        directHandler(backend).onMethodCall(
            MethodCall(
                "generateThumbnail",
                mapOf(
                    "videoAbsolutePath" to "/data/video.mp4",
                    "outputAbsolutePath" to "/data/thumb.jpg",
                    "maxWidth" to 512,
                ),
            ),
            result,
        )

        assertEquals("thumbnail_generation_failed", result.errorCode)
        assertNull(result.errorMessage)
        assertNull(result.errorDetails)
    }

    @Test
    fun unknownMethodsAreNotImplemented() {
        val result = RecordingResult()

        directHandler(FakeMediaBackend()).onMethodCall(MethodCall("other", null), result)

        assertTrue(result.notImplemented)
    }

    @Test
    fun availableBytesForwardsAbsolutePathAndReturnsBackendValue() {
        val backend = FakeMediaBackend()
        val result = RecordingResult()

        directHandler(backend).onMethodCall(
            MethodCall("availableBytes", mapOf("absolutePath" to "/data/user/0/app")),
            result,
        )

        assertEquals("/data/user/0/app", backend.availableBytesPath)
        assertEquals(9_876L, result.successValue)
    }

    @Test
    fun availableBytesRejectsRelativePathAndMapsBackendFailure() {
        val relativeBackend = FakeMediaBackend()
        val relative = RecordingResult()
        directHandler(relativeBackend).onMethodCall(
            MethodCall("availableBytes", mapOf("absolutePath" to "private")),
            relative,
        )
        assertEquals("invalid_arguments", relative.errorCode)

        val failed = RecordingResult()
        directHandler(FakeMediaBackend(availableBytesFailure = IllegalStateException("disk detail")))
            .onMethodCall(
                MethodCall("availableBytes", mapOf("absolutePath" to "/data/private")),
                failed,
            )
        assertEquals("storage_query_failed", failed.errorCode)
        assertNull(failed.errorMessage)
    }

    private fun directHandler(backend: MediaBackend): MediaBridgeHandler =
        MediaBridgeHandler(backend, { task -> task() }, { task -> task() })
}

private class FakeMediaBackend(
    private val inspectFailure: Throwable? = null,
    private val thumbnailFailure: Throwable? = null,
    private val availableBytesFailure: Throwable? = null,
) : MediaBackend {
    var inspectedPath: String? = null
    var thumbnailRequest: ThumbnailRequest? = null
    var availableBytesPath: String? = null

    override fun inspect(absolutePath: String): MediaInfo {
        inspectFailure?.let { throw it }
        inspectedPath = absolutePath
        return MediaInfo(
            durationMs = 1_234L,
            width = 1920,
            height = 1080,
            metadataRecordedAtEpochMs = 1_785_499_200_000L,
        )
    }

    override fun generateThumbnail(
        videoAbsolutePath: String,
        outputAbsolutePath: String,
        maxWidth: Int,
    ): String {
        thumbnailFailure?.let { throw it }
        thumbnailRequest = ThumbnailRequest(videoAbsolutePath, outputAbsolutePath, maxWidth)
        return outputAbsolutePath
    }

    override fun availableBytes(absolutePath: String): Long {
        availableBytesFailure?.let { throw it }
        availableBytesPath = absolutePath
        return 9_876L
    }
}

private data class ThumbnailRequest(
    val videoAbsolutePath: String,
    val outputAbsolutePath: String,
    val maxWidth: Int,
)

private class QueuedDispatcher {
    private val tasks = ArrayDeque<() -> Unit>()

    fun dispatch(task: () -> Unit) {
        tasks.addLast(task)
    }

    fun runNext() {
        tasks.removeFirst().invoke()
    }
}

private class RecordingResult : MethodChannel.Result {
    var successValue: Any? = null
    var errorCode: String? = null
    var errorMessage: String? = null
    var errorDetails: Any? = null
    var notImplemented = false
    var completed = false

    override fun success(result: Any?) {
        successValue = result
        completed = true
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        this.errorCode = errorCode
        this.errorMessage = errorMessage
        this.errorDetails = errorDetails
        completed = true
    }

    override fun notImplemented() {
        notImplemented = true
        completed = true
    }
}
