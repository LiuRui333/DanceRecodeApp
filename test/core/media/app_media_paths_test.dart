import 'dart:io';

import 'package:dance_video_diary/core/media/app_media_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppMediaPaths', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('dance-video-media-paths-');
    });

    tearDown(() async {
      await root.delete(recursive: true);
    });

    test('creates the app-private media, import, and database directories', () {
      AppMediaPaths(root);

      expect(
        Directory(
          '${root.path}${Platform.pathSeparator}media${Platform.pathSeparator}videos',
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(
          '${root.path}${Platform.pathSeparator}media${Platform.pathSeparator}thumbnails',
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(
          '${root.path}${Platform.pathSeparator}temp${Platform.pathSeparator}imports',
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory('${root.path}${Platform.pathSeparator}database').existsSync(),
        isTrue,
      );
    });

    test('returns database-safe POSIX relative media paths', () {
      final paths = AppMediaPaths(root);

      expect(paths.videoRelativePath('abc', '.MP4'), 'media/videos/abc.mp4');
      expect(paths.videoRelativePath('abc', '../mp4'), 'media/videos/abc');
      expect(paths.thumbnailRelativePath('abc'), 'media/thumbnails/abc.jpg');
      expect(
        paths.importTempRelativePath('task-1'),
        'temp/imports/task-1/source',
      );
    });

    test(
      'rejects untrusted identifiers that could escape the private root',
      () {
        final paths = AppMediaPaths(root);

        expect(
          () => paths.videoRelativePath('../outside', '.mp4'),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => paths.thumbnailRelativePath(r'..\\outside'),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => paths.importTempRelativePath('../task'),
          throwsA(isA<ArgumentError>()),
        );
      },
    );
  });
}
