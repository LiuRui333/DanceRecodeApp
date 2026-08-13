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
