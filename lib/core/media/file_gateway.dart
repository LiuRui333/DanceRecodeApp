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
    final resolvedDestination = await _temporaryFile(destination);

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
    final resolvedTemporaryFile = await _temporaryFile(temporaryFile);
    final resolvedDestination = await _videoFile(destination);
    final commitLock = await _videoFile(
      File('${resolvedDestination.path}.lock'),
    );
    var ownsLock = false;

    try {
      try {
        await commitLock.create(exclusive: true);
        ownsLock = true;
      } catch (_) {
        if (await commitLock.exists()) {
          throw StateError('Another commit is already in progress');
        }
        rethrow;
      }

      if (await resolvedDestination.exists()) {
        throw StateError('Destination file already exists');
      }

      final revalidatedTemporaryFile = await _temporaryFile(
        resolvedTemporaryFile,
      );
      final revalidatedDestination = await _videoFile(resolvedDestination);
      if (await revalidatedDestination.exists()) {
        throw StateError('Destination file already exists');
      }
      await revalidatedTemporaryFile.rename(revalidatedDestination.path);
    } finally {
      if (ownsLock) {
        await _deleteCommitLock(commitLock);
      }
    }
  }

  Future<File> _temporaryFile(File file) {
    return _fileWithin(file, _paths.importsTempDirectory, 'temporaryFile');
  }

  Future<File> _videoFile(File file) {
    return _fileWithin(file, _paths.videosDirectory, 'destination');
  }

  Future<File> _fileWithin(
    File file,
    Directory directory,
    String argumentName,
  ) async {
    final resolved = path.normalize(path.absolute(file.path));
    if (!path.isWithin(_paths.rootDirectory.path, resolved) ||
        !path.isWithin(directory.path, resolved)) {
      throw ArgumentError.value(
        file.path,
        argumentName,
        'Must stay in app root',
      );
    }

    final realRoot = await _resolveExistingPath(_paths.rootDirectory.path);
    final realDirectory = await _resolveExistingPath(directory.path);
    final realFile = await _resolveNearestExistingPath(resolved);
    if (!path.isWithin(realRoot, realDirectory) ||
        !path.isWithin(realRoot, realFile) ||
        !path.isWithin(realDirectory, realFile)) {
      throw ArgumentError.value(
        file.path,
        argumentName,
        'Must resolve within the app root',
      );
    }
    return File(resolved);
  }

  Future<void> _deleteIfExists(File file) async {
    try {
      final revalidatedFile = await _temporaryFile(file);
      if (await revalidatedFile.exists()) {
        await revalidatedFile.delete();
      }
    } on ArgumentError {
      // A changed link must not make cleanup delete outside the app root.
    }
  }

  Future<void> _deleteCommitLock(File commitLock) async {
    try {
      final revalidatedLock = await _videoFile(commitLock);
      if (await revalidatedLock.exists()) {
        await revalidatedLock.delete();
      }
    } on ArgumentError {
      // A changed link must not make lock cleanup delete outside the app root.
    }
  }

  Future<String> _resolveNearestExistingPath(String candidate) async {
    var existingPath = candidate;
    final missingSegments = <String>[];

    while (await FileSystemEntity.type(existingPath, followLinks: false) ==
        FileSystemEntityType.notFound) {
      final parent = path.dirname(existingPath);
      if (parent == existingPath) {
        throw ArgumentError.value(candidate, 'path', 'Has no existing parent');
      }
      missingSegments.add(path.basename(existingPath));
      existingPath = parent;
    }
    final resolvedExistingPath = await _resolveExistingPath(existingPath);
    return path.normalize(
      path.joinAll(<String>[resolvedExistingPath, ...missingSegments.reversed]),
    );
  }

  Future<String> _resolveExistingPath(String existingPath) async {
    final entityType = await FileSystemEntity.type(
      existingPath,
      followLinks: false,
    );
    if (entityType == FileSystemEntityType.directory) {
      return Directory(existingPath).resolveSymbolicLinks();
    }
    if (entityType == FileSystemEntityType.file) {
      return File(existingPath).resolveSymbolicLinks();
    }
    if (entityType == FileSystemEntityType.link) {
      return Link(existingPath).resolveSymbolicLinks();
    }
    if (entityType == FileSystemEntityType.notFound) {
      throw ArgumentError.value(existingPath, 'path', 'Does not exist');
    }
    throw StateError('Unsupported filesystem entity');
  }
}
