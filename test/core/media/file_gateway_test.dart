import 'dart:async';
import 'dart:io';

import 'package:dance_video_diary/core/media/app_media_paths.dart';
import 'package:dance_video_diary/core/media/file_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('FileGateway', () {
    late Directory root;
    late AppMediaPaths paths;
    late FileGateway gateway;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('dance-video-file-gateway-');
      paths = AppMediaPaths(root);
      gateway = FileGateway(paths);
    });

    tearDown(() async {
      await root.delete(recursive: true);
    });

    test(
      'copies chunks to a private temporary file and reports cumulative progress',
      () async {
        final destination = _tempFile(paths, 'task-1');
        final progress = <int>[];

        final result = await gateway.copySourceToTemp(
          source: Stream<List<int>>.fromIterable(const <List<int>>[
            <int>[1, 2],
            <int>[3, 4, 5],
          ]),
          expectedBytes: 5,
          destination: destination,
          onProgress: progress.add,
        );

        expect(result.copiedBytes, 5);
        expect(await destination.readAsBytes(), <int>[1, 2, 3, 4, 5]);
        expect(progress, <int>[2, 5]);
      },
    );

    test(
      'deletes an incomplete temporary file after a source read failure',
      () async {
        final destination = _tempFile(paths, 'task-1');

        await expectLater(
          gateway.copySourceToTemp(
            source: _failingSource(),
            expectedBytes: null,
            destination: destination,
            onProgress: (_) {},
          ),
          throwsA(isA<StateError>()),
        );

        expect(await destination.exists(), isFalse);
      },
    );

    test(
      'deletes an incomplete temporary file when copied bytes differ from expected bytes',
      () async {
        final destination = _tempFile(paths, 'task-1');

        await expectLater(
          gateway.copySourceToTemp(
            source: Stream<List<int>>.value(const <int>[1, 2, 3]),
            expectedBytes: 4,
            destination: destination,
            onProgress: (_) {},
          ),
          throwsA(isA<StateError>()),
        );

        expect(await destination.exists(), isFalse);
      },
    );

    test(
      'rejects a copy destination outside the private import directory',
      () async {
        final outsideTemp = File(path.join(root.path, 'outside', 'source'));

        await expectLater(
          gateway.copySourceToTemp(
            source: Stream<List<int>>.value(const <int>[1]),
            expectedBytes: 1,
            destination: outsideTemp,
            onProgress: (_) {},
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('moves a private temporary file into the videos directory', () async {
      final temporaryFile = _tempFile(paths, 'task-1');
      await temporaryFile.parent.create(recursive: true);
      await temporaryFile.writeAsBytes(const <int>[1, 2, 3]);
      final destination = _videoFile(paths, 'video-1');

      await gateway.commitTempFile(
        temporaryFile: temporaryFile,
        destination: destination,
      );

      expect(await temporaryFile.exists(), isFalse);
      expect(await destination.readAsBytes(), <int>[1, 2, 3]);
    });

    test('does not overwrite an existing video during commit', () async {
      final temporaryFile = _tempFile(paths, 'task-1');
      await temporaryFile.parent.create(recursive: true);
      await temporaryFile.writeAsBytes(const <int>[1, 2, 3]);
      final destination = _videoFile(paths, 'video-1');
      await destination.writeAsBytes(const <int>[9]);

      await expectLater(
        gateway.commitTempFile(
          temporaryFile: temporaryFile,
          destination: destination,
        ),
        throwsA(isA<StateError>()),
      );

      expect(await temporaryFile.readAsBytes(), <int>[1, 2, 3]);
      expect(await destination.readAsBytes(), <int>[9]);
    });

    test(
      'rejects commit paths outside their configured private directories',
      () async {
        final temporaryFile = File(path.join(root.path, 'other', 'source'));
        await temporaryFile.parent.create(recursive: true);
        await temporaryFile.writeAsBytes(const <int>[1]);
        final destination = _videoFile(paths, 'video-1');

        await expectLater(
          gateway.commitTempFile(
            temporaryFile: temporaryFile,
            destination: destination,
          ),
          throwsA(isA<ArgumentError>()),
        );

        final validTemporaryFile = _tempFile(paths, 'task-1');
        await validTemporaryFile.parent.create(recursive: true);
        await validTemporaryFile.writeAsBytes(const <int>[1]);
        final thumbnailDestination = File(
          path.join(paths.thumbnailsDirectory.path, 'video-1.jpg'),
        );

        await expectLater(
          gateway.commitTempFile(
            temporaryFile: validTemporaryFile,
            destination: thumbnailDestination,
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );
  });
}

File _tempFile(AppMediaPaths paths, String taskId) {
  return File(
    path.join(paths.rootDirectory.path, paths.importTempRelativePath(taskId)),
  );
}

File _videoFile(AppMediaPaths paths, String videoId) {
  return File(
    path.join(
      paths.rootDirectory.path,
      paths.videoRelativePath(videoId, '.mp4'),
    ),
  );
}

Stream<List<int>> _failingSource() async* {
  yield const <int>[1, 2, 3];
  throw StateError('source read failed');
}
