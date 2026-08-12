import 'package:dance_video_diary/features/import/application/video_picker_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final importTime = DateTime.utc(2026, 8, 3, 9, 30);

  test('cancellation returns an empty source list', () async {
    final client = _FakeVideoPickerClient(pickedFiles: const []);
    final gateway = ImagePickerVideoPickerGateway(
      client: client,
      now: () => importTime,
    );

    expect(await gateway.pickVideos(), isEmpty);
    expect(client.calls, ['recover', 'pick']);
  });

  test(
    'usable lost videos are returned before starting another pick',
    () async {
      final client = _FakeVideoPickerClient(
        recoveredFiles: [
          PickerFile(
            path: '/cache/recovered.mp4',
            name: 'recovered.mp4',
            mimeType: 'video/mp4',
            sizeBytes: 240,
            modifiedAt: DateTime.parse('2026-08-01T12:30:00+08:00'),
          ),
        ],
        pickedFiles: [
          const PickerFile(
            path: '/cache/new.mp4',
            name: 'new.mp4',
            mimeType: 'video/mp4',
            sizeBytes: 400,
          ),
        ],
      );
      final gateway = ImagePickerVideoPickerGateway(
        client: client,
        now: () => importTime,
      );

      final sources = await gateway.pickVideos();

      expect(client.calls, ['recover']);
      expect(sources, hasLength(1));
      expect(sources.single.uri, '/cache/recovered.mp4');
      expect(sources.single.displayName, 'recovered.mp4');
      expect(sources.single.sizeBytes, 240);
      expect(sources.single.mediaRecordedAt, isNull);
      expect(sources.single.modifiedAt, DateTime.utc(2026, 8, 1, 4, 30));
    },
  );

  test(
    'MIME type wins and an extension allowlist handles missing MIME',
    () async {
      final client = _FakeVideoPickerClient(
        pickedFiles: [
          const PickerFile(
            path: '/cache/mislabeled.mp4',
            name: 'mislabeled.mp4',
            mimeType: 'image/jpeg',
            sizeBytes: 1,
          ),
          const PickerFile(
            path: '/cache/clip.bin',
            name: 'clip.bin',
            mimeType: 'video/mp4',
            sizeBytes: 2,
          ),
          const PickerFile(
            path: '/cache/fallback.MOV',
            name: 'fallback.MOV',
            sizeBytes: 3,
          ),
          const PickerFile(
            path: '/cache/photo.jpg',
            name: 'photo.jpg',
            sizeBytes: 4,
          ),
        ],
      );
      final gateway = ImagePickerVideoPickerGateway(
        client: client,
        now: () => importTime,
      );

      final sources = await gateway.pickVideos();

      expect(sources.map((source) => source.uri), [
        '/cache/clip.bin',
        '/cache/fallback.MOV',
      ]);
    },
  );

  test('maps available fields and uses UTC import fallbacks', () async {
    final client = _FakeVideoPickerClient(
      pickedFiles: [
        PickerFile(
          path: 'content://picker/video/7',
          name: 'practice.webm',
          mimeType: 'video/webm',
          sizeBytes: 8192,
          mediaRecordedAt: DateTime.parse('2026-07-31T20:15:00+08:00'),
        ),
        const PickerFile(
          path: '/cache/no-size.m4v',
          name: 'no-size.m4v',
          mimeType: 'video/x-m4v',
        ),
      ],
    );
    final gateway = ImagePickerVideoPickerGateway(
      client: client,
      now: () => importTime,
    );

    final sources = await gateway.pickVideos();

    expect(sources.first.uri, 'content://picker/video/7');
    expect(sources.first.displayName, 'practice.webm');
    expect(sources.first.sizeBytes, 8192);
    expect(sources.first.mediaRecordedAt, DateTime.utc(2026, 7, 31, 12, 15));
    expect(sources.first.modifiedAt, importTime);
    expect(sources.last.sizeBytes, 0);
    expect(sources.last.modifiedAt, importTime);
  });

  test('lost-data plugin errors become a stable adapter error', () async {
    final gateway = ImagePickerVideoPickerGateway(
      client: _FakeVideoPickerClient(recoveryFailed: true),
      now: () => importTime,
    );

    await expectLater(
      gateway.pickVideos(),
      throwsA(
        isA<VideoPickerException>().having(
          (error) => error.code,
          'code',
          VideoPickerFailureCode.lostDataRecoveryFailed,
        ),
      ),
    );
  });
}

final class _FakeVideoPickerClient implements VideoPickerClient {
  _FakeVideoPickerClient({
    this.recoveredFiles = const [],
    this.pickedFiles = const [],
    this.recoveryFailed = false,
  });

  final List<PickerFile> recoveredFiles;
  final List<PickerFile> pickedFiles;
  final bool recoveryFailed;
  final List<String> calls = [];

  @override
  Future<List<PickerFile>> pickMultipleMedia() async {
    calls.add('pick');
    return pickedFiles;
  }

  @override
  Future<PickerRecovery> recoverLostData() async {
    calls.add('recover');
    return PickerRecovery(files: recoveredFiles, failed: recoveryFailed);
  }
}
