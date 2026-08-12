import 'package:flutter/services.dart';

typedef MediaMethodInvoker =
    Future<Object?> Function(String method, Map<String, Object?> arguments);

abstract interface class MediaBridge {
  Future<Object?> inspectVideo(String absolutePath);

  Future<Object?> generateThumbnail({
    required String videoAbsolutePath,
    required String outputAbsolutePath,
    required int maxWidth,
  });
}

enum MediaBridgeFailureCode { nativeFailure }

final class MediaBridgeException implements Exception {
  const MediaBridgeException(this.code);

  final MediaBridgeFailureCode code;
}

final class MethodChannelMediaBridge implements MediaBridge {
  MethodChannelMediaBridge({MediaMethodInvoker? invokeMethod})
    : _invokeMethod = invokeMethod ?? _invokeOnChannel;

  static const channelName = 'com.dancediary.app/media';
  static const _channel = MethodChannel(channelName);

  final MediaMethodInvoker _invokeMethod;

  static Future<Object?> _invokeOnChannel(
    String method,
    Map<String, Object?> arguments,
  ) {
    return _channel.invokeMethod<Object?>(method, arguments);
  }

  @override
  Future<Object?> inspectVideo(String absolutePath) {
    return _invoke('inspectVideo', {'absolutePath': absolutePath});
  }

  @override
  Future<Object?> generateThumbnail({
    required String videoAbsolutePath,
    required String outputAbsolutePath,
    required int maxWidth,
  }) {
    return _invoke('generateThumbnail', {
      'videoAbsolutePath': videoAbsolutePath,
      'outputAbsolutePath': outputAbsolutePath,
      'maxWidth': maxWidth,
    });
  }

  Future<Object?> _invoke(String method, Map<String, Object?> arguments) async {
    try {
      return await _invokeMethod(method, arguments);
    } on PlatformException {
      throw const MediaBridgeException(MediaBridgeFailureCode.nativeFailure);
    }
  }
}

abstract interface class MediaInspector {
  Future<MediaMetadata> inspect(String absolutePath);
}

final class MediaMetadata {
  const MediaMetadata({
    required this.durationMs,
    required this.width,
    required this.height,
    required this.metadataRecordedAt,
  });

  final int durationMs;
  final int width;
  final int height;
  final DateTime? metadataRecordedAt;
}

enum MediaInspectionFailureCode { nativeFailure, invalidResponse }

final class MediaInspectionException implements Exception {
  const MediaInspectionException(this.code);

  final MediaInspectionFailureCode code;
}

final class MethodChannelMediaInspector implements MediaInspector {
  MethodChannelMediaInspector({MediaBridge? bridge})
    : _bridge = bridge ?? MethodChannelMediaBridge();

  final MediaBridge _bridge;

  @override
  Future<MediaMetadata> inspect(String absolutePath) async {
    final Object? response;
    try {
      response = await _bridge.inspectVideo(absolutePath);
    } on MediaBridgeException {
      throw const MediaInspectionException(
        MediaInspectionFailureCode.nativeFailure,
      );
    }

    if (response is! Map) {
      throw const MediaInspectionException(
        MediaInspectionFailureCode.invalidResponse,
      );
    }

    final durationMs = response['durationMs'];
    final width = response['width'];
    final height = response['height'];
    if (durationMs is! int || width is! int || height is! int) {
      throw const MediaInspectionException(
        MediaInspectionFailureCode.invalidResponse,
      );
    }

    final recordedAtEpochMs = response['metadataRecordedAtEpochMs'];
    return MediaMetadata(
      durationMs: durationMs,
      width: width,
      height: height,
      metadataRecordedAt: recordedAtEpochMs is int
          ? DateTime.fromMillisecondsSinceEpoch(recordedAtEpochMs, isUtc: true)
          : null,
    );
  }
}
