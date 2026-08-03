import 'dart:async';
import 'dart:io';

import 'package:dance_video_diary/core/media/app_media_paths.dart';
import 'package:path/path.dart' as path;

final class CopyResult {
  const CopyResult({required this.copiedBytes});

  final int copiedBytes;
}

final class FileGateway {
  FileGateway(this._paths);

  final AppMediaPaths _paths;

  Future<CopyResult> copySourceToTemp({
    required Stream<List<int>> source,
    required int? expectedBytes,
    required File destination,
    required void Function(int copiedBytes) onProgress,
  }) async {
    final resolvedDestination = _temporaryFile(destination);

    try {
      await resolvedDestination.parent.create(recursive: true);
      final output = resolvedDestination.openWrite();
      var copiedBytes = 0;

      try {
        await for (final chunk in source) {
          output.add(chunk);
          copiedBytes += chunk.length;
          onProgress(copiedBytes);
        }
        await output.close();
      } catch (_) {
        await output.close();
        rethrow;
      }

      final destinationLength = await resolvedDestination.length();
      if (destinationLength != copiedBytes ||
          (expectedBytes != null && copiedBytes != expectedBytes)) {
        throw StateError('Copied byte count does not match destination length');
      }
      return CopyResult(copiedBytes: copiedBytes);
    } catch (_) {
      await _deleteIfExists(resolvedDestination);
      rethrow;
    }
  }

  Future<void> commitTempFile({
    required File temporaryFile,
    required File destination,
  }) async {
    final resolvedTemporaryFile = _temporaryFile(temporaryFile);
    final resolvedDestination = _videoFile(destination);

    if (await resolvedDestination.exists()) {
      throw StateError('Destination file already exists');
    }
    await resolvedTemporaryFile.rename(resolvedDestination.path);
  }

  File _temporaryFile(File file) {
    return _fileWithin(file, _paths.importsTempDirectory, 'temporaryFile');
  }

  File _videoFile(File file) {
    return _fileWithin(file, _paths.videosDirectory, 'destination');
  }

  File _fileWithin(File file, Directory directory, String argumentName) {
    final resolved = path.normalize(path.absolute(file.path));
    if (!path.isWithin(_paths.rootDirectory.path, resolved) ||
        !path.isWithin(directory.path, resolved)) {
      throw ArgumentError.value(
        file.path,
        argumentName,
        'Must stay in app root',
      );
    }
    return File(resolved);
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
