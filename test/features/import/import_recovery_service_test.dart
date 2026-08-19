import 'dart:io';

import 'package:dance_video_diary/core/database/app_database.dart';
import 'package:dance_video_diary/core/database/import_task_repository.dart';
import 'package:dance_video_diary/core/database/video_repository.dart';
import 'package:dance_video_diary/core/media/app_media_paths.dart';
import 'package:dance_video_diary/features/import/application/import_recovery_service.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recent empty orphan uses directory mtime and is retained', () async {
    final root = await Directory.systemTemp.createTemp('recovery_empty_');
    final paths = AppMediaPaths(root);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    final orphan = Directory(
      '${paths.importsTempDirectory.path}${Platform.pathSeparator}recent-empty',
    );
    await orphan.create(recursive: true);
    final summary = await ImportRecoveryService(
      taskRepository: ImportTaskRepository(db),
      videoRepository: VideoRepository(db),
      paths: paths,
      runner: _Runner(failTaskId: ''),
      now: () => DateTime.now(),
    ).recoverInterrupted();
    expect(await orphan.exists(), isTrue);
    expect(summary.orphanDirectoriesDeleted, 0);
  });
  test('runner failure counts failed rather than resumed', () async {
    final root = await Directory.systemTemp.createTemp('recovery_failed_');
    final paths = AppMediaPaths(root);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    final tasks = ImportTaskRepository(db);
    final task = await tasks.createPending(_source('processing.mp4'));
    await tasks.transition(
      task.id,
      ImportStatus.copying,
      tempRelativePath: paths.importTempRelativePath(task.id),
    );
    await tasks.transition(task.id, ImportStatus.processing, tempSizeBytes: 1);
    await _tempFile(paths, task.id, <int>[1]);
    final summary = await ImportRecoveryService(
      taskRepository: tasks,
      videoRepository: VideoRepository(db),
      paths: paths,
      runner: _Runner(failTaskId: task.id),
      now: () => DateTime.now(),
    ).recoverInterrupted();
    expect(summary.resumed, 0);
    expect(summary.failed, 1);
    expect(summary.entries.single.taskId, task.id);
    expect(summary.entries.single.displayName, 'processing.mp4');
    expect(summary.entries.single.result, isA<ImportFailure>());
  });
  test('existing checkpointed database video completes idempotently', () async {
    final root = await Directory.systemTemp.createTemp('recovery_done_');
    final paths = AppMediaPaths(root);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    final tasks = ImportTaskRepository(db);
    final videos = VideoRepository(db);
    final task = await tasks.createPending(_source('done.mp4'));
    await tasks.transition(task.id, ImportStatus.copying);
    await tasks.transition(
      task.id,
      ImportStatus.processing,
      videoId: 'existing',
    );
    await videos.insertImportedVideo(_draft('existing'));
    final runner = _Runner(failTaskId: '');

    final summary = await ImportRecoveryService(
      taskRepository: tasks,
      videoRepository: videos,
      paths: paths,
      runner: runner,
      now: DateTime.now,
    ).recoverInterrupted();

    expect(summary.completed, 1);
    expect(summary.failed, 0);
    expect(runner.resumed, isEmpty);
    expect((await tasks.getById(task.id))!.status, 'completed');
    expect(await db.select(db.practiceVideos).get(), hasLength(1));
    expect(summary.entries.single.taskId, task.id);
    expect(summary.entries.single.result, isA<ImportSuccess>());
  });

  test('existing unsupported video remains failed after recovery', () async {
    final root = await Directory.systemTemp.createTemp('recovery_unsupported_');
    final paths = AppMediaPaths(root);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    final tasks = ImportTaskRepository(db);
    final videos = VideoRepository(db);
    final task = await tasks.createPending(_source('broken.mp4'));
    await tasks.transition(task.id, ImportStatus.copying);
    await tasks.transition(
      task.id,
      ImportStatus.processing,
      videoId: 'unsupported-video',
      errorKind: ImportErrorKind.unsupportedMedia,
      errorMessage: 'This video format is unsupported or corrupt.',
    );
    await videos.insertImportedVideo(_draft('unsupported-video'));
    final runner = _Runner(failTaskId: '');

    final summary = await ImportRecoveryService(
      taskRepository: tasks,
      videoRepository: videos,
      paths: paths,
      runner: runner,
      now: DateTime.now,
    ).recoverInterrupted();

    expect(summary.completed, 0);
    expect(summary.failed, 1);
    expect(runner.resumed, isEmpty);
    final recoveredTask = await tasks.getById(task.id);
    expect(recoveredTask!.status, ImportStatus.failed.name);
    expect(recoveredTask.errorKind, ImportErrorKind.unsupportedMedia.name);
    expect(
      summary.entries.single.result,
      isA<ImportFailure>().having(
        (result) => result.errorKind,
        'errorKind',
        ImportErrorKind.unsupportedMedia,
      ),
    );
    expect(await db.select(db.practiceVideos).get(), hasLength(1));
  });
  test(
    'applies every interrupted task rule and removes only old orphans',
    () async {
      final root = await Directory.systemTemp.createTemp('recovery_test_');
      final paths = AppMediaPaths(root);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() async {
        await db.close();
        await root.delete(recursive: true);
      });
      final tasks = ImportTaskRepository(db);
      final videos = VideoRepository(db);
      final pending = await tasks.createPending(_source('pending.mp4'));
      final copying = await tasks.createPending(_source('copying.mp4'));
      await tasks.transition(
        copying.id,
        ImportStatus.copying,
        tempRelativePath: paths.importTempRelativePath(copying.id),
      );
      final processing = await tasks.createPending(_source('processing.mp4'));
      await tasks.transition(
        processing.id,
        ImportStatus.copying,
        tempRelativePath: paths.importTempRelativePath(processing.id),
      );
      await tasks.transition(processing.id, ImportStatus.processing);
      await _tempFile(paths, processing.id, <int>[1]);
      final idempotent = await tasks.createPending(_source('done.mp4'));
      await tasks.transition(idempotent.id, ImportStatus.copying);
      await tasks.transition(
        idempotent.id,
        ImportStatus.processing,
        videoId: 'existing',
      );
      await videos.insertImportedVideo(_draft('existing'));
      final broken = await tasks.createPending(_source('broken.mp4'));
      await tasks.transition(broken.id, ImportStatus.copying);
      await tasks.transition(broken.id, ImportStatus.processing);
      final oldOrphan = await _tempFile(paths, 'old-orphan', <int>[2]);
      final oldTime = DateTime.now().subtract(const Duration(hours: 25));
      await oldOrphan.setLastModified(oldTime);
      await _tempFile(paths, 'recent-orphan', <int>[3]);
      final runner = _Runner(failTaskId: broken.id);

      final summary = await ImportRecoveryService(
        taskRepository: tasks,
        videoRepository: videos,
        paths: paths,
        runner: runner,
        now: () => DateTime.now(),
      ).recoverInterrupted();

      expect(runner.requeued, containsAll(<String>[pending.id, copying.id]));
      expect(runner.resumed, contains(processing.id));
      expect(
        (await tasks.getById(idempotent.id))!.status,
        ImportStatus.completed.name,
      );
      expect(
        (await tasks.getById(broken.id))!.errorKind,
        ImportErrorKind.interrupted.name,
      );
      expect(
        await Directory(
          '${paths.importsTempDirectory.path}${Platform.pathSeparator}old-orphan',
        ).exists(),
        isFalse,
      );
      expect(
        await Directory(
          '${paths.importsTempDirectory.path}${Platform.pathSeparator}recent-orphan',
        ).exists(),
        isTrue,
      );
      expect(summary.completed, 1);
      expect(summary.failed, 1);
      expect(summary.orphanDirectoriesDeleted, 1);
      expect(summary.entries, hasLength(5));
      expect(
        summary.entries.map((entry) => entry.displayName),
        containsAll(<String>[
          'pending.mp4',
          'copying.mp4',
          'processing.mp4',
          'done.mp4',
          'broken.mp4',
        ]),
      );
    },
  );
}

ImportSource _source(String name) => ImportSource(
  uri: 'content://$name',
  displayName: name,
  sizeBytes: 1,
  modifiedAt: DateTime.utc(2026),
);

ImportedVideoDraft _draft(String id) => ImportedVideoDraft(
  id: id,
  relativePath: 'media/videos/$id.mp4',
  sha256: 'hash',
  sizeBytes: 1,
  recordedAt: DateTime.utc(2026),
  importedAt: DateTime.utc(2026),
);

Future<File> _tempFile(AppMediaPaths paths, String id, List<int> bytes) async {
  final file = File(
    paths.rootDirectory.path +
        Platform.pathSeparator +
        paths
            .importTempRelativePath(id)
            .replaceAll('/', Platform.pathSeparator),
  );
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);
  return file;
}

final class _Runner implements ImportRecoveryRunner {
  _Runner({required this.failTaskId});
  final String failTaskId;
  final List<String> requeued = <String>[];
  final List<String> resumed = <String>[];

  @override
  Future<ImportItemResult> requeue(String taskId) async {
    requeued.add(taskId);
    return ImportItemResult.success(videoId: 'requeued-$taskId');
  }

  @override
  Future<ImportItemResult> resumeProcessing(String taskId) async {
    resumed.add(taskId);
    if (taskId == failTaskId) {
      return ImportItemResult.failure(
        errorKind: ImportErrorKind.interrupted,
        message: 'Interrupted import cannot continue.',
      );
    }
    return ImportItemResult.success(videoId: 'resumed-$taskId');
  }
}
