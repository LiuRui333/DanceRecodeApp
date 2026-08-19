package com.dancediary.app

import com.dancediary.app.media.MediaBridge
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var mediaBridge: MediaBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mediaBridge = MediaBridge(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        mediaBridge?.close()
        mediaBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
