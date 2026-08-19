import 'media_inspector.dart';

abstract interface class ThumbnailService {
  Future<String?> generate({
    required String videoAbsolutePath,
    required String outputAbsolutePath,
    int maxWidth = 512,
  });
}

final class MethodChannelThumbnailService implements ThumbnailService {
  MethodChannelThumbnailService({MediaBridge? bridge})
    : _bridge = bridge ?? MethodChannelMediaBridge();

  final MediaBridge _bridge;

  @override
  Future<String?> generate({
    required String videoAbsolutePath,
    required String outputAbsolutePath,
    int maxWidth = 512,
  }) async {
    try {
      final response = await _bridge.generateThumbnail(
        videoAbsolutePath: videoAbsolutePath,
        outputAbsolutePath: outputAbsolutePath,
        maxWidth: maxWidth,
      );
      return response is String && response.isNotEmpty ? response : null;
    } on MediaBridgeException {
      return null;
    }
  }
}
