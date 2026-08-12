import 'package:dance_video_diary/core/media/media_inspector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'inspect forwards the path and maps portable metadata primitives',
    () async {
      String? invokedMethod;
      Map<String, Object?>? invokedArguments;
      final bridge = MethodChannelMediaBridge(
        invokeMethod: (method, arguments) async {
          invokedMethod = method;
          invokedArguments = arguments;
          return <String, Object?>{
            'durationMs': 12345,
            'width': 1920,
            'height': 1080,
            'metadataRecordedAtEpochMs': 1785499200000,
          };
        },
      );
      final inspector = MethodChannelMediaInspector(bridge: bridge);

      final metadata = await inspector.inspect('D:\\media\\practice.mp4');

      expect(invokedMethod, 'inspectVideo');
      expect(invokedArguments, {'absolutePath': 'D:\\media\\practice.mp4'});
      expect(metadata.durationMs, 12345);
      expect(metadata.width, 1920);
      expect(metadata.height, 1080);
      expect(
        metadata.metadataRecordedAt,
        DateTime.fromMillisecondsSinceEpoch(1785499200000, isUtc: true),
      );
    },
  );

  test('missing optional recorded time stays null', () async {
    final inspector = MethodChannelMediaInspector(
      bridge: MethodChannelMediaBridge(
        invokeMethod: (_, _) async => <String, Object?>{
          'durationMs': 800,
          'width': 640,
          'height': 480,
          'metadataRecordedAtEpochMs': null,
        },
      ),
    );

    final metadata = await inspector.inspect('D:\\media\\plain.mp4');

    expect(metadata.metadataRecordedAt, isNull);
  });

  test('malformed optional recorded time is ignored safely', () async {
    final inspector = MethodChannelMediaInspector(
      bridge: MethodChannelMediaBridge(
        invokeMethod: (_, _) async => <String, Object?>{
          'durationMs': 800,
          'width': 640,
          'height': 480,
          'metadataRecordedAtEpochMs': 'unknown',
        },
      ),
    );

    final metadata = await inspector.inspect('D:\\media\\plain.mp4');

    expect(metadata.metadataRecordedAt, isNull);
  });

  test('malformed native payload becomes a stable inspection error', () async {
    final inspector = MethodChannelMediaInspector(
      bridge: MethodChannelMediaBridge(
        invokeMethod: (_, _) async => <String, Object?>{
          'durationMs': 'not-an-integer',
          'width': 640,
          'height': 480,
        },
      ),
    );

    await expectLater(
      inspector.inspect('D:\\media\\broken.mp4'),
      throwsA(
        isA<MediaInspectionException>().having(
          (error) => error.code,
          'code',
          MediaInspectionFailureCode.invalidResponse,
        ),
      ),
    );
  });

  test('platform failures do not leak through the inspector', () async {
    final inspector = MethodChannelMediaInspector(
      bridge: MethodChannelMediaBridge(
        invokeMethod: (_, _) async => throw PlatformException(
          code: 'media_inspection_failed',
          message: 'android detail',
        ),
      ),
    );

    await expectLater(
      inspector.inspect('D:\\media\\unreadable.mp4'),
      throwsA(
        isA<MediaInspectionException>().having(
          (error) => error.code,
          'code',
          MediaInspectionFailureCode.nativeFailure,
        ),
      ),
    );
  });
}
