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

  test('reports the current filename then appends each item result', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);

    final progress = await harness.coordinator.import(<ImportSource>[
      harness.source('first.mp4', <int>[1]),
      harness.source('second.mp4', <int>[2]),
    ]).toList();

    expect(progress, hasLength(5));
    expect(progress[1].currentFileName, 'first.mp4');
    expect(progress[1].entries, isEmpty);
    expect(progress[2].entries.single.displayName, 'first.mp4');
    expect(progress[3].currentFileName, 'second.mp4');
    expect(progress[3].entries, hasLength(1));
    expect(progress.last.currentFileName, isNull);
    expect(progress.last.entries.map((entry) => entry.displayName), <String>[
      'first.mp4',
      'second.mp4',
    ]);
    expect(
      progress.last.entries.map((entry) => entry.taskId),
      everyElement(isNotEmpty),
    );
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
    'keeps a safely copied corrupt video while reporting unsupportedMedia',
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
      expect(task.status, ImportStatus.failed.name);
      expect(task.videoId, isNotNull);
      final video =
          (await harness.db.select(harness.db.practiceVideos).get()).single;
      expect(video.id, task.videoId);
      expect(video.durationMs, isNull);
      expect(video.width, isNull);
      expect(video.height, isNull);
      expect(video.metadataRecordedAt, isNull);
      expect(video.thumbnailPath, isNull);
      expect(
        await File(
          '${harness.root.path}${Platform.pathSeparator}${video.relativePath.replaceAll('/', Platform.pathSeparator)}',
        ).readAsBytes(),
        <int>[1],
      );
      expect(await harness.paths.thumbnailsDirectory.list().toList(), isEmpty);
      expect(
        await Directory(
          '${harness.paths.importsTempDirectory.path}${Platform.pathSeparator}${task.id}',
        ).exists(),
        isFalse,
      );
    },
  );

  test(
    'retrying a retained unsupported video resolves as a duplicate',
    () async {
      final inspector = _Inspector(fail: true);
      final harness = await _Harness.create(inspector: inspector);
      addTearDown(harness.dispose);
      final source = harness.source('broken.mp4', <int>[1]);
      await harness.coordinator.import(<ImportSource>[source]).drain<void>();
      final task =
          (await harness.db.select(harness.db.importTasks).get()).single;

      final result = await harness.coordinator.retry(task.id);

      expect(result, isA<ImportDuplicate>());
      expect(
        await harness.db.select(harness.db.practiceVideos).get(),
        hasLength(1),
      );
      expect(inspector.calls, 1);
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

  test('retry preserves known size and reapplies the space gate', () async {
    var availableBytes = 1024 * 1024 * 1024;
    final harness = await _Harness.create(
      availableBytesReader: () => availableBytes,
    );
    addTearDown(harness.dispose);
    final source = harness.source('later.mp4', <int>[8]);
    harness.bytes.remove(source.uri);
    await harness.coordinator.import(<ImportSource>[source]).drain<void>();
    final task = (await harness.db.select(harness.db.importTasks).get()).single;
    expect(task.sourceSizeBytes, 1);
    harness.bytes[source.uri] = <int>[8];
    availableBytes = 64 * 1024 * 1024;

    final result = await harness.coordinator.retry(task.id);

    expect(result, isA<ImportFailure>());
    expect(
      (result as ImportFailure).errorKind,
      ImportErrorKind.insufficientSpace,
    );
    expect((await harness.tasks.getById(task.id))!.sourceSizeBytes, 1);
  });

  test('unavailable source maps to sourceUnavailable', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final source = harness.source('missing.mp4', <int>[1]);
    harness.bytes.remove(source.uri);
    await harness.coordinator.import(<ImportSource>[source]).drain<void>();
    final task = (await harness.db.select(harness.db.importTasks).get()).single;
    expect(task.errorKind, ImportErrorKind.sourceUnavailable.name);
  });

  test(
    'thumbnail file is removed when generation throws after writing',
    () async {
      final harness = await _Harness.create(
        thumbnail: _Thumbnail(failAfterWrite: true),
      );
      addTearDown(harness.dispose);
      await harness.coordinator.import(<ImportSource>[
        harness.source('dance.mp4', <int>[1]),
      ]).drain<void>();
      expect(await harness.paths.thumbnailsDirectory.list().toList(), isEmpty);
    },
  );

  test(
    'thumbnail file is removed when generation writes then returns null',
    () async {
      final harness = await _Harness.create(
        thumbnail: _Thumbnail(returnNullAfterWrite: true),
      );
      addTearDown(harness.dispose);

      await harness.coordinator.import(<ImportSource>[
        harness.source('dance.mp4', <int>[1]),
      ]).drain<void>();

      expect(await harness.paths.thumbnailsDirectory.list().toList(), isEmpty);
      expect(
        (await harness.db.select(harness.db.practiceVideos).get())
            .single
            .thumbnailPath,
        isNull,
      );
    },
  );

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

  test('thumbnail file is removed when final media commit fails', () async {
    const videoId = 'fixed-video';
    final harness = await _Harness.create(videoIdGenerator: () => videoId);
    addTearDown(harness.dispose);
    await File(
      '${harness.paths.videosDirectory.path}${Platform.pathSeparator}$videoId.mp4',
    ).create(recursive: true);
    await harness.coordinator.import(<ImportSource>[
      harness.source('dance.mp4', <int>[1]),
    ]).drain<void>();
    expect(await harness.paths.thumbnailsDirectory.list().toList(), isEmpty);
  });

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

  test(
    'database failure after unsupported inspection removes committed media and task temp',
    () async {
      final harness = await _Harness.create(inspector: _Inspector(fail: true));
      addTearDown(harness.dispose);
      await harness.db.customStatement(
        'CREATE TRIGGER reject_video BEFORE INSERT ON practice_videos BEGIN SELECT RAISE(ABORT, \'reject\'); END',
      );

      await harness.coordinator.import(<ImportSource>[
        harness.source('dance.mp4', <int>[1]),
      ]).drain<void>();

      final task =
          (await harness.db.select(harness.db.importTasks).get()).single;
      expect(task.errorKind, ImportErrorKind.database.name);
      expect(await harness.db.select(harness.db.practiceVideos).get(), isEmpty);
      expect(await harness.paths.videosDirectory.list().toList(), isEmpty);
      expect(
        await Directory(
          harness.paths.importsTempDirectory.path +
              Platform.pathSeparator +
              task.id,
        ).exists(),
        isFalse,
      );
    },
  );

  test(
    'resumeProcessing continues from complete temp without opening source',
    () async {
      final harness = await _Harness.create();
      addTearDown(harness.dispose);
      final source = harness.source('resume.mp4', <int>[7, 8]);
      final task = await harness.tasks.createPending(source);
      final relative = harness.paths.importTempRelativePath(task.id);
      await harness.tasks.transition(
        task.id,
        ImportStatus.copying,
        tempRelativePath: relative,
      );
      await harness.tasks.transition(
        task.id,
        ImportStatus.processing,
        tempSizeBytes: 2,
      );
      final temp = File(
        '${harness.root.path}${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}',
      );
      await temp.create(recursive: true);
      await temp.writeAsBytes(<int>[7, 8]);
      harness.bytes.remove(source.uri);
      final result = await harness.coordinator.resumeProcessing(task.id);
      expect(result, isA<ImportSuccess>());
      expect(
        await harness.db.select(harness.db.importTasks).get(),
        hasLength(1),
      );
    },
  );

  test(
    'resumeProcessing rejects a temp whose persisted byte count differs',
    () async {
      final harness = await _Harness.create();
      addTearDown(harness.dispose);
      final source = harness.source('partial.mp4', <int>[1, 2]);
      final task = await harness.tasks.createPending(source);
      final relative = harness.paths.importTempRelativePath(task.id);
      await harness.tasks.transition(
        task.id,
        ImportStatus.copying,
        tempRelativePath: relative,
      );
      await harness.tasks.transition(
        task.id,
        ImportStatus.processing,
        tempSizeBytes: 2,
      );
      final temp = File(
        '${harness.root.path}${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}',
      );
      await temp.create(recursive: true);
      await temp.writeAsBytes(<int>[1]);
      final result = await harness.coordinator.resumeProcessing(task.id);
      expect(result, isA<ImportFailure>());
      expect((result as ImportFailure).errorKind, ImportErrorKind.interrupted);
    },
  );

  test(
    'resumeProcessing inserts the checkpointed video after an atomic move',
    () async {
      const videoId = 'checkpointed-video';
      final harness = await _Harness.create();
      addTearDown(harness.dispose);
      final source = harness.source('resume.mp4', <int>[7, 8]);
      final task = await harness.tasks.createPending(source);
      await harness.tasks.transition(
        task.id,
        ImportStatus.copying,
        tempRelativePath: harness.paths.importTempRelativePath(task.id),
      );
      await harness.tasks.transition(
        task.id,
        ImportStatus.processing,
        tempSizeBytes: 2,
        videoId: videoId,
      );
      final finalFile = File(
        '${harness.paths.videosDirectory.path}${Platform.pathSeparator}$videoId.mp4',
      );
      await finalFile.create(recursive: true);
      await finalFile.writeAsBytes(<int>[7, 8]);

      final result = await harness.coordinator.resumeProcessing(task.id);

      expect(result, isA<ImportSuccess>());
      final videos = await harness.db.select(harness.db.practiceVideos).get();
      expect(videos, hasLength(1));
      expect(videos.single.id, videoId);
      expect(videos.single.relativePath, 'media/videos/$videoId.mp4');
      expect((await harness.tasks.getById(task.id))!.status, 'completed');
    },
  );

  test(
    'failed database recovery removes final media and permits a clean retry',
    () async {
      const videoId = 'checkpointed-video';
      final harness = await _Harness.create(
        videoIdGenerator: () => 'retry-video',
      );
      addTearDown(harness.dispose);
      final source = harness.source('resume.mp4', <int>[7, 8]);
      final task = await harness.tasks.createPending(source);
      await harness.tasks.transition(
        task.id,
        ImportStatus.copying,
        tempRelativePath: harness.paths.importTempRelativePath(task.id),
      );
      await harness.tasks.transition(
        task.id,
        ImportStatus.processing,
        tempSizeBytes: 2,
        videoId: videoId,
      );
      final finalFile = File(
        '${harness.paths.videosDirectory.path}${Platform.pathSeparator}$videoId.mp4',
      );
      await finalFile.create(recursive: true);
      await finalFile.writeAsBytes(<int>[7, 8]);
      await harness.db.customStatement(
        'CREATE TRIGGER reject_recovered_video BEFORE INSERT ON practice_videos BEGIN SELECT RAISE(ABORT, \'reject\'); END',
      );

      final failed = await harness.coordinator.resumeProcessing(task.id);

      expect(failed, isA<ImportFailure>());
      expect(await finalFile.exists(), isFalse);
      expect((await harness.tasks.getById(task.id))!.videoId, isNull);
      await harness.db.customStatement('DROP TRIGGER reject_recovered_video');
      final retried = await harness.coordinator.retry(task.id);
      expect(retried, isA<ImportSuccess>());
      expect((retried as ImportSuccess).videoId, 'retry-video');
    },
  );

  test('resumeProcessing ignores an untrusted persisted temp path', () async {
    final inspector = _Inspector();
    final harness = await _Harness.create(inspector: inspector);
    addTearDown(harness.dispose);
    final victim = File(
      '${harness.paths.videosDirectory.path}${Platform.pathSeparator}victim.mp4',
    );
    await victim.create(recursive: true);
    await victim.writeAsBytes(<int>[9]);
    final task = await harness.tasks.createPending(
      harness.source('malicious.mp4', <int>[9]),
    );
    await harness.tasks.transition(
      task.id,
      ImportStatus.copying,
      tempRelativePath: 'media/videos/victim.mp4',
    );
    await harness.tasks.transition(
      task.id,
      ImportStatus.processing,
      tempSizeBytes: 1,
    );

    final result = await harness.coordinator.resumeProcessing(task.id);

    expect(result, isA<ImportFailure>());
    expect(await victim.readAsBytes(), <int>[9]);
    expect(inspector.calls, 0);
  });

  test('file source opener maps a missing file to sourceUnavailable', () async {
    final harness = await _Harness.create(openSource: openFileSource);
    addTearDown(harness.dispose);
    final missing = ImportSource(
      uri: '${harness.root.path}${Platform.pathSeparator}missing.mp4',
      displayName: 'missing.mp4',
      sizeBytes: 1,
      modifiedAt: DateTime.utc(2026),
    );

    await harness.coordinator.import(<ImportSource>[missing]).drain<void>();

    final task = (await harness.db.select(harness.db.importTasks).get()).single;
    expect(task.errorKind, ImportErrorKind.sourceUnavailable.name);
  });

  test('same filename with different hash imports independently', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final first = harness.source('same.mp4', <int>[1]);
    await harness.coordinator.import(<ImportSource>[first]).drain<void>();
    final second = harness.source('same.mp4', <int>[2]);
    await harness.coordinator.import(<ImportSource>[second]).drain<void>();
    expect(
      await harness.db.select(harness.db.practiceVideos).get(),
      hasLength(2),
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
    int Function()? availableBytesReader,
    int unknownSizeCapBytes = 4 * 1024 * 1024 * 1024,
    String Function()? videoIdGenerator,
    SourceOpener? openSource,
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
      openSource:
          openSource ??
          (uri) {
            final sourceBytes = bytes[uri];
            if (sourceBytes == null) {
              return Stream<List<int>>.error(
                const SourceUnavailableException(),
              );
            }
            return Stream<List<int>>.value(sourceBytes);
          },
      availableBytes: (_) async =>
          availableBytesReader?.call() ?? availableBytes,
      unknownSizeCapBytes: unknownSizeCapBytes,
      videoIdGenerator: videoIdGenerator,
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
  _Thumbnail({
    this.fail = false,
    this.failAfterWrite = false,
    this.returnNullAfterWrite = false,
  });

  final bool fail;
  final bool failAfterWrite;
  final bool returnNullAfterWrite;
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
    if (failAfterWrite) throw StateError('thumbnail failed after write');
    if (returnNullAfterWrite) return null;
    return outputAbsolutePath;
  }
}
