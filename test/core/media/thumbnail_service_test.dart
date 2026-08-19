import 'package:dance_video_diary/core/media/media_inspector.dart';
import 'package:dance_video_diary/core/media/thumbnail_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'generate forwards the default 512 cap and returns the output path',
    () async {
      String? invokedMethod;
      Map<String, Object?>? invokedArguments;
      final service = MethodChannelThumbnailService(
        bridge: MethodChannelMediaBridge(
          invokeMethod: (method, arguments) async {
            invokedMethod = method;
            invokedArguments = arguments;
            return 'D:\\thumbs\\video.jpg';
          },
        ),
      );

      final result = await service.generate(
        videoAbsolutePath: 'D:\\media\\video.mp4',
        outputAbsolutePath: 'D:\\thumbs\\video.jpg',
      );

      expect(invokedMethod, 'generateThumbnail');
      expect(invokedArguments, {
        'videoAbsolutePath': 'D:\\media\\video.mp4',
        'outputAbsolutePath': 'D:\\thumbs\\video.jpg',
        'maxWidth': 512,
      });
      expect(result, 'D:\\thumbs\\video.jpg');
    },
  );

  test('generate forwards an explicit thumbnail cap', () async {
    Map<String, Object?>? invokedArguments;
    final service = MethodChannelThumbnailService(
      bridge: MethodChannelMediaBridge(
        invokeMethod: (_, arguments) async {
          invokedArguments = arguments;
          return 'D:\\thumbs\\small.jpg';
        },
      ),
    );

    await service.generate(
      videoAbsolutePath: 'D:\\media\\video.mp4',
      outputAbsolutePath: 'D:\\thumbs\\small.jpg',
      maxWidth: 320,
    );

    expect(invokedArguments?['maxWidth'], 320);
  });

  test('a stable generation failure returns null and can be retried', () async {
    var attempts = 0;
    final service = MethodChannelThumbnailService(
      bridge: MethodChannelMediaBridge(
        invokeMethod: (_, _) async {
          attempts += 1;
          if (attempts == 1) {
            throw PlatformException(
              code: 'thumbnail_generation_failed',
              message: 'android detail',
            );
          }
          return 'D:\\thumbs\\retry.jpg';
        },
      ),
    );

    final first = await service.generate(
      videoAbsolutePath: 'D:\\media\\video.mp4',
      outputAbsolutePath: 'D:\\thumbs\\retry.jpg',
    );
    final second = await service.generate(
      videoAbsolutePath: 'D:\\media\\video.mp4',
      outputAbsolutePath: 'D:\\thumbs\\retry.jpg',
    );

    expect(first, isNull);
    expect(second, 'D:\\thumbs\\retry.jpg');
    expect(attempts, 2);
  });

  test('an invalid success payload is treated as generation failure', () async {
    final service = MethodChannelThumbnailService(
      bridge: MethodChannelMediaBridge(
        invokeMethod: (_, _) async => <String, Object?>{},
      ),
    );

    expect(
      await service.generate(
        videoAbsolutePath: 'D:\\media\\video.mp4',
        outputAbsolutePath: 'D:\\thumbs\\video.jpg',
      ),
      isNull,
    );
  });

  test('a missing native plugin returns null', () async {
    final service = MethodChannelThumbnailService(
      bridge: MethodChannelMediaBridge(
        invokeMethod: (_, _) async => throw MissingPluginException(),
      ),
    );

    expect(
      await service.generate(
        videoAbsolutePath: 'D:\\media\\video.mp4',
        outputAbsolutePath: 'D:\\thumbs\\video.jpg',
      ),
      isNull,
    );
  });
}
