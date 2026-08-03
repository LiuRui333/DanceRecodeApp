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
    late List<Link> directoryLinks;
    late List<Directory> outsideDirectories;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('dance-video-file-gateway-');
      paths = AppMediaPaths(root);
      gateway = FileGateway(paths);
      directoryLinks = <Link>[];
      outsideDirectories = <Directory>[];
    });

    tearDown(() async {
      for (final directoryLink in directoryLinks) {
        if (await directoryLink.exists()) {
          await directoryLink.delete();
        }
      }
      await root.delete(recursive: true);
      for (final outsideDirectory in outsideDirectories) {
        await outsideDirectory.delete(recursive: true);
      }
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

    test(
      'rejects a temporary copy path that resolves through a directory link outside the app root',
      () async {
        final outsideDirectory = await _outsideDirectory(outsideDirectories);
        final outsideFile = File(path.join(outsideDirectory.path, 'source'));
        await outsideFile.writeAsBytes(const <int>[9]);
        final linkedDirectory = Directory(
          path.join(paths.importsTempDirectory.path, 'escaped'),
        );
        directoryLinks.add(
          await _createDirectoryLink(
            link: linkedDirectory,
            target: outsideDirectory,
          ),
        );

        await expectLater(
          gateway.copySourceToTemp(
            source: Stream<List<int>>.value(const <int>[1]),
            expectedBytes: 2,
            destination: File(path.join(linkedDirectory.path, 'source')),
            onProgress: (_) {},
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(await outsideFile.readAsBytes(), <int>[9]);
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
      'rejects commit source paths that resolve through a directory link outside the app root',
      () async {
        final outsideDirectory = await _outsideDirectory(outsideDirectories);
        final outsideFile = File(path.join(outsideDirectory.path, 'source'));
        await outsideFile.writeAsBytes(const <int>[1, 2, 3]);
        final linkedDirectory = Directory(
          path.join(paths.importsTempDirectory.path, 'escaped'),
        );
        directoryLinks.add(
          await _createDirectoryLink(
            link: linkedDirectory,
            target: outsideDirectory,
          ),
        );
        final destination = _videoFile(paths, 'video-1');

        await expectLater(
          gateway.commitTempFile(
            temporaryFile: File(path.join(linkedDirectory.path, 'source')),
            destination: destination,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(await outsideFile.readAsBytes(), <int>[1, 2, 3]);
        expect(await destination.exists(), isFalse);
      },
    );

    test(
      'rejects commit destinations that resolve through a directory link outside the app root',
      () async {
        final temporaryFile = _tempFile(paths, 'task-1');
        await temporaryFile.parent.create(recursive: true);
        await temporaryFile.writeAsBytes(const <int>[1, 2, 3]);
        final outsideDirectory = await _outsideDirectory(outsideDirectories);
        final linkedDirectory = Directory(
          path.join(paths.videosDirectory.path, 'escaped'),
        );
        directoryLinks.add(
          await _createDirectoryLink(
            link: linkedDirectory,
            target: outsideDirectory,
          ),
        );
        final destination = File(
          path.join(linkedDirectory.path, 'video-1.mp4'),
        );

        await expectLater(
          gateway.commitTempFile(
            temporaryFile: temporaryFile,
            destination: destination,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(await temporaryFile.readAsBytes(), <int>[1, 2, 3]);
        expect(await destination.exists(), isFalse);
      },
    );

    test(
      'allows exactly one concurrent commit for the same destination',
      () async {
        final firstTemporaryFile = _tempFile(paths, 'task-1');
        final secondTemporaryFile = _tempFile(paths, 'task-2');
        await firstTemporaryFile.parent.create(recursive: true);
        await secondTemporaryFile.parent.create(recursive: true);
        await firstTemporaryFile.writeAsBytes(const <int>[1, 1, 1]);
        await secondTemporaryFile.writeAsBytes(const <int>[2, 2, 2]);
        final destination = _videoFile(paths, 'video-1');

        final attempts = await Future.wait(<Future<_CommitAttempt>>[
          _commitAttempt(gateway, firstTemporaryFile, destination),
          _commitAttempt(gateway, secondTemporaryFile, destination),
        ]);
        final successfulIndex = attempts.indexWhere(
          (attempt) => attempt.succeeded,
        );
        final failedIndex = attempts.indexWhere(
          (attempt) => !attempt.succeeded,
        );

        expect(
          successfulIndex,
          isNot(-1),
          reason: attempts.map((attempt) => attempt.error).join(', '),
        );
        expect(failedIndex, isNot(-1));
        expect(attempts.where((attempt) => attempt.succeeded), hasLength(1));
        expect(attempts[failedIndex].error, isA<StateError>());
        expect(
          await destination.readAsBytes(),
          successfulIndex == 0 ? <int>[1, 1, 1] : <int>[2, 2, 2],
        );
        expect(
          await (successfulIndex == 0
                  ? firstTemporaryFile
                  : secondTemporaryFile)
              .exists(),
          isFalse,
        );
        expect(
          await (failedIndex == 0 ? firstTemporaryFile : secondTemporaryFile)
              .readAsBytes(),
          failedIndex == 0 ? <int>[1, 1, 1] : <int>[2, 2, 2],
        );
      },
    );

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

Future<Directory> _outsideDirectory(List<Directory> outsideDirectories) async {
  final directory = await Directory.systemTemp.createTemp(
    'dance-video-outside-',
  );
  outsideDirectories.add(directory);
  return directory;
}

Future<Link> _createDirectoryLink({
  required Directory link,
  required Directory target,
}) async {
  if (Platform.isWindows) {
    final result = await Process.run('cmd.exe', <String>[
      '/c',
      'mklink',
      '/J',
      link.path,
      target.path,
    ]);
    if (result.exitCode != 0) {
      throw StateError('Could not create directory junction: ${result.stderr}');
    }
  } else {
    await Link(link.path).create(target.path);
  }
  return Link(link.path);
}

Future<_CommitAttempt> _commitAttempt(
  FileGateway gateway,
  File temporaryFile,
  File destination,
) async {
  try {
    await gateway.commitTempFile(
      temporaryFile: temporaryFile,
      destination: destination,
    );
    return const _CommitAttempt.succeeded();
  } catch (error) {
    return _CommitAttempt.failed(error);
  }
}

final class _CommitAttempt {
  const _CommitAttempt.succeeded() : succeeded = true, error = null;

  const _CommitAttempt.failed(this.error) : succeeded = false;

  final bool succeeded;
  final Object? error;
}
