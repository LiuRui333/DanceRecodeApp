import 'dart:io';

import 'package:dance_video_diary/core/database/app_database.dart';
import 'package:dance_video_diary/core/database/import_task_repository.dart';
import 'package:dance_video_diary/core/database/video_repository.dart';
import 'package:dance_video_diary/core/media/app_media_paths.dart';
import 'package:dance_video_diary/core/media/file_gateway.dart';
import 'package:dance_video_diary/core/media/hash_service.dart';
import 'package:dance_video_diary/core/media/media_inspector.dart';
import 'package:dance_video_diary/core/media/thumbnail_service.dart';
import 'package:dance_video_diary/features/import/application/import_coordinator.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('imports a video and persists media metadata', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);

    final progress = await harness.coordinator.import(<ImportSource>[
      harness.source('dance.mp4', <int>[1, 2, 3]),
    ]).toList();

    expect(progress.last.status, ImportStatus.completed);
    expect(progress.last.completed, 1);
    final videos = await harness.db.select(harness.db.practiceVideos).get();
    expect(videos, hasLength(1));
    expect(videos.single.durationMs, 1000);
    expect(videos.single.width, 1920);
    expect(videos.single.height, 1080);
    expect(videos.single.thumbnailPath, isNotNull);
    expect(
      await File(
        harness.paths.rootDirectory.path +
            Platform.pathSeparator +
            videos.single.relativePath.replaceAll('/', Platform.pathSeparator),
      ).exists(),
      isTrue,
    );
    expect(await harness.tasks.listRecoverable(), isEmpty);
  });

  test('skips metadata and thumbnail work for a duplicate', () async {
    final inspector = _Inspector();
    final thumbnail = _Thumbnail();
    final harness = await _Harness.create(
      inspector: inspector,
      thumbnail: thumbnail,
    );
    addTearDown(harness.dispose);
    final source = harness.source('same.mp4', <int>[4, 5]);
    await harness.coordinator.import(<ImportSource>[source]).drain<void>();

    final progress = await harness.coordinator.import(<ImportSource>[
      source,
    ]).toList();

    expect(progress.last.duplicate, 1);
    expect(inspector.calls, 1);
    expect(thumbnail.calls, 1);
    expect(
      await harness.db.select(harness.db.practiceVideos).get(),
      hasLength(1),
    );
  });

  test('continues a batch after one source fails', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final missing = ImportSource(
      uri: 'content://videos/missing.mp4',
      displayName: 'missing.mp4',
      sizeBytes: 1,
      modifiedAt: DateTime.utc(2026, 8, 1),
    );

    final progress = await harness.coordinator.import(<ImportSource>[
      harness.source('first.mp4', <int>[1]),
      missing,
      harness.source('third.mp4', <int>[3]),
    ]).toList();

    expect(progress.last.completed, 2);
    expect(progress.last.failed, 1);
  });

  test('thumbnail failure does not fail the import', () async {
    final harness = await _Harness.create(thumbnail: _Thumbnail(fail: true));
    addTearDown(harness.dispose);

    final progress = await harness.coordinator.import(<ImportSource>[
      harness.source('dance.mp4', <int>[1]),
    ]).toList();

    expect(progress.last.completed, 1);
    final video =
        (await harness.db.select(harness.db.practiceVideos).get()).single;
    expect(video.thumbnailPath, isNull);
  });

  test(
    'maps corrupt media to unsupportedMedia without exposing paths',
    () async {
      final harness = await _Harness.create(inspector: _Inspector(fail: true));
      addTearDown(harness.dispose);

      await harness.coordinator.import(<ImportSource>[
        harness.source('broken.mp4', <int>[1]),
      ]).drain<void>();

      final task =
          (await harness.db.select(harness.db.importTasks).get()).single;
      expect(task.errorKind, ImportErrorKind.unsupportedMedia.name);
      expect(task.errorMessage, isNot(contains(harness.root.path)));
    },
  );

  test('retry moves a failed task back through the import states', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final source = harness.source('later.mp4', <int>[8]);
    harness.bytes.remove(source.uri);
    await harness.coordinator.import(<ImportSource>[source]).drain<void>();
    final task = (await harness.db.select(harness.db.importTasks).get()).single;
    harness.bytes[source.uri] = <int>[8];

    final result = await harness.coordinator.retry(task.id);

    expect(result, isA<ImportSuccess>());
    expect(
      (await harness.tasks.getById(task.id))!.status,
      ImportStatus.completed.name,
    );
  });

  test(
    'requires source size plus the minimum reserve before copying',
    () async {
      final harness = await _Harness.create(availableBytes: 64 * 1024 * 1024);
      addTearDown(harness.dispose);

      final progress = await harness.coordinator.import(<ImportSource>[
        harness.source('dance.mp4', <int>[1]),
      ]).toList();

      expect(progress.last.failed, 1);
      final task =
          (await harness.db.select(harness.db.importTasks).get()).single;
      expect(task.errorKind, ImportErrorKind.insufficientSpace.name);
    },
  );

  test('caps a source whose size is unknown', () async {
    final harness = await _Harness.create(unknownSizeCapBytes: 2);
    addTearDown(harness.dispose);
    final source = harness.source('unknown.mp4', <int>[1, 2, 3]);
    final unknown = ImportSource(
      uri: source.uri,
      displayName: source.displayName,
      sizeBytes: -1,
      modifiedAt: source.modifiedAt,
    );

    final progress = await harness.coordinator.import(<ImportSource>[
      unknown,
    ]).toList();

    expect(progress.last.failed, 1);
    final task = (await harness.db.select(harness.db.importTasks).get()).single;
    expect(task.errorKind, ImportErrorKind.io.name);
    expect(
      await Directory(
        harness.paths.importsTempDirectory.path +
            Platform.pathSeparator +
            task.id,
      ).exists(),
      isFalse,
    );
  });

  test('database failure removes committed media and task temp', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    await harness.db.customStatement(
      'CREATE TRIGGER reject_video BEFORE INSERT ON practice_videos BEGIN SELECT RAISE(ABORT, \'reject\'); END',
    );

    await harness.coordinator.import(<ImportSource>[
      harness.source('dance.mp4', <int>[1]),
    ]).drain<void>();

    final task = (await harness.db.select(harness.db.importTasks).get()).single;
    expect(task.errorKind, ImportErrorKind.database.name);
    expect(await harness.paths.videosDirectory.list().toList(), isEmpty);
    expect(
      await Directory(
        harness.paths.importsTempDirectory.path +
            Platform.pathSeparator +
            task.id,
      ).exists(),
      isFalse,
    );
  });
}

final class _Harness {
  _Harness(
    this.root,
    this.paths,
    this.db,
    this.tasks,
    this.coordinator,
    this.bytes,
  );

  static Future<_Harness> create({
    _Inspector? inspector,
    _Thumbnail? thumbnail,
    int availableBytes = 1024 * 1024 * 1024,
    int unknownSizeCapBytes = 4 * 1024 * 1024 * 1024,
  }) async {
    final root = await Directory.systemTemp.createTemp('coordinator_test_');
    final paths = AppMediaPaths(root);
    final db = AppDatabase(NativeDatabase.memory());
    final tasks = ImportTaskRepository(db);
    final bytes = <String, List<int>>{};
    final coordinator = ImportCoordinator(
      taskRepository: tasks,
      videoRepository: VideoRepository(db),
      paths: paths,
      fileGateway: FileGateway(paths),
      hashService: HashService(),
      mediaInspector: inspector ?? _Inspector(),
      thumbnailService: thumbnail ?? _Thumbnail(),
      openSource: (uri) {
        final sourceBytes = bytes[uri];
        if (sourceBytes == null) {
          return Stream<List<int>>.error(StateError('unavailable'));
        }
        return Stream<List<int>>.value(sourceBytes);
      },
      availableBytes: (_) async => availableBytes,
      unknownSizeCapBytes: unknownSizeCapBytes,
    );
    return _Harness(root, paths, db, tasks, coordinator, bytes);
  }

  final Directory root;
  final AppMediaPaths paths;
  final AppDatabase db;
  final ImportTaskRepository tasks;
  final ImportCoordinator coordinator;
  final Map<String, List<int>> bytes;

  ImportSource source(String name, List<int> data) {
    final uri = 'content://videos/$name';
    bytes[uri] = data;
    return ImportSource(
      uri: uri,
      displayName: name,
      sizeBytes: data.length,
      modifiedAt: DateTime.utc(2026, 8, 1),
    );
  }

  Future<void> dispose() async {
    await db.close();
    await root.delete(recursive: true);
  }
}

final class _Inspector implements MediaInspector {
  _Inspector({this.fail = false});

  final bool fail;
  int calls = 0;

  @override
  Future<MediaMetadata> inspect(String absolutePath) async {
    calls++;
    if (fail) {
      throw const MediaInspectionException(
        MediaInspectionFailureCode.nativeFailure,
      );
    }
    return MediaMetadata(
      durationMs: 1000,
      width: 1920,
      height: 1080,
      metadataRecordedAt: DateTime.utc(2026, 7, 1),
    );
  }
}

final class _Thumbnail implements ThumbnailService {
  _Thumbnail({this.fail = false});

  final bool fail;
  int calls = 0;

  @override
  Future<String?> generate({
    required String videoAbsolutePath,
    required String outputAbsolutePath,
    int maxWidth = 512,
  }) async {
    calls++;
    if (fail) throw StateError('thumbnail failed');
    await File(outputAbsolutePath).create(recursive: true);
    return outputAbsolutePath;
  }
}
