import 'dart:io';

import 'package:path/path.dart' as path;

final class AppMediaPaths {
  AppMediaPaths(Directory rootDirectory)
    : rootDirectory = Directory(
        path.normalize(path.absolute(rootDirectory.path)),
      ) {
    videosDirectory = _directoryAt('media/videos');
    thumbnailsDirectory = _directoryAt('media/thumbnails');
    importsTempDirectory = _directoryAt('temp/imports');
    databaseDirectory = _directoryAt('database');

    for (final directory in <Directory>[
      videosDirectory,
      thumbnailsDirectory,
      importsTempDirectory,
      databaseDirectory,
    ]) {
      directory.createSync(recursive: true);
    }
  }

  final Directory rootDirectory;
  late final Directory videosDirectory;
  late final Directory thumbnailsDirectory;
  late final Directory importsTempDirectory;
  late final Directory databaseDirectory;

  String videoRelativePath(String videoId, String? safeExtension) {
    return path.posix.join(
      'media',
      'videos',
      '${_safeIdentifier(videoId)}${_safeExtension(safeExtension)}',
    );
  }

  String thumbnailRelativePath(String videoId) {
    return path.posix.join(
      'media',
      'thumbnails',
      '${_safeIdentifier(videoId)}.jpg',
    );
  }

  String importTempRelativePath(String taskId) {
    return path.posix.join(
      'temp',
      'imports',
      _safeIdentifier(taskId),
      'source',
    );
  }

  Directory _directoryAt(String relativePath) {
    final resolved = path.normalize(
      path.join(rootDirectory.path, relativePath),
    );
    if (!path.isWithin(rootDirectory.path, resolved)) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Must stay in root',
      );
    }
    return Directory(resolved);
  }

  String _safeIdentifier(String value) {
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'identifier',
        'Must be a safe path segment',
      );
    }
    return value;
  }

  String _safeExtension(String? value) {
    if (value == null || !RegExp(r'^\.[A-Za-z0-9]{1,16}$').hasMatch(value)) {
      return '';
    }
    return value.toLowerCase();
  }
}
