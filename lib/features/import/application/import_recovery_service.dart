import 'dart:io';

import 'package:dance_video_diary/core/database/import_task_repository.dart';
import 'package:dance_video_diary/core/database/video_repository.dart';
import 'package:dance_video_diary/core/media/app_media_paths.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:path/path.dart' as path;

abstract interface class ImportRecoveryRunner {
  Future<ImportItemResult> requeue(String taskId);

  Future<ImportItemResult> resumeProcessing(String taskId);
}

final class RecoverySummary {
  const RecoverySummary({
    required this.requeued,
    required this.resumed,
    required this.completed,
    required this.failed,
    required this.orphanDirectoriesDeleted,
    required this.entries,
  });

  final int requeued;
  final int resumed;
  final int completed;
  final int failed;
  final int orphanDirectoriesDeleted;
  final List<ImportResultEntry> entries;
}

final class ImportRecoveryService {
  const ImportRecoveryService({
    required ImportTaskRepository taskRepository,
    required VideoRepository videoRepository,
    required this.paths,
    required this.runner,
    required this.now,
  }) : _tasks = taskRepository,
       _videos = videoRepository;

  final ImportTaskRepository _tasks;
  final VideoRepository _videos;
  final AppMediaPaths paths;
  final ImportRecoveryRunner runner;
  final DateTime Function() now;

  Future<RecoverySummary> recoverInterrupted() async {
    final active = await _tasks.listRecoverable();
    var requeued = 0;
    var resumed = 0;
    var completed = 0;
    var failed = 0;
    final entries = <ImportResultEntry>[];
    for (final task in active) {
      if (task.videoId != null &&
          await _videos.findById(task.videoId!) != null) {
        if (task.status == ImportStatus.processing.name &&
            task.errorKind == ImportErrorKind.unsupportedMedia.name) {
          final message =
              task.errorMessage ??
              'This video format is unsupported or corrupt.';
          await _tasks.transition(
            task.id,
            ImportStatus.failed,
            errorKind: ImportErrorKind.unsupportedMedia,
            errorMessage: message,
            videoId: task.videoId,
          );
          failed++;
          entries.add(
            ImportResultEntry(
              taskId: task.id,
              displayName: task.displayName,
              result: ImportItemResult.failure(
                errorKind: ImportErrorKind.unsupportedMedia,
                message: message,
              ),
            ),
          );
          continue;
        }
        if (task.status == ImportStatus.pending.name) {
          await _tasks.transition(task.id, ImportStatus.copying);
          await _tasks.transition(task.id, ImportStatus.processing);
        } else if (task.status == ImportStatus.copying.name) {
          await _tasks.transition(task.id, ImportStatus.processing);
        }
        await _tasks.transition(
          task.id,
          ImportStatus.completed,
          progress: 1,
          videoId: task.videoId,
        );
        completed++;
        entries.add(
          ImportResultEntry(
            taskId: task.id,
            displayName: task.displayName,
            result: ImportItemResult.success(videoId: task.videoId!),
          ),
        );
        continue;
      }
      final temp = _tempFile(task.id);
      if (task.status == ImportStatus.pending.name) {
        final result = await runner.requeue(task.id);
        if (result is ImportFailure) {
          failed++;
        } else {
          requeued++;
        }
        entries.add(
          ImportResultEntry(
            taskId: task.id,
            displayName: task.displayName,
            result: result,
          ),
        );
      } else if (task.status == ImportStatus.copying.name) {
        if (await temp.exists()) await temp.parent.delete(recursive: true);
        await _tasks.transition(
          task.id,
          ImportStatus.failed,
          errorKind: ImportErrorKind.interrupted,
          errorMessage: 'Interrupted import will be retried.',
        );
        final result = await runner.requeue(task.id);
        if (result is ImportFailure) {
          failed++;
        } else {
          requeued++;
        }
        entries.add(
          ImportResultEntry(
            taskId: task.id,
            displayName: task.displayName,
            result: result,
          ),
        );
      } else if ((await temp.exists() && await temp.length() > 0) ||
          task.videoId != null) {
        final result = await runner.resumeProcessing(task.id);
        if (result is ImportFailure) {
          failed++;
        } else {
          resumed++;
        }
        entries.add(
          ImportResultEntry(
            taskId: task.id,
            displayName: task.displayName,
            result: result,
          ),
        );
      } else {
        await _tasks.transition(
          task.id,
          ImportStatus.failed,
          errorKind: ImportErrorKind.interrupted,
          errorMessage: 'Interrupted import cannot continue.',
        );
        failed++;
        entries.add(
          ImportResultEntry(
            taskId: task.id,
            displayName: task.displayName,
            result: ImportItemResult.failure(
              errorKind: ImportErrorKind.interrupted,
              message: 'Interrupted import cannot continue.',
            ),
          ),
        );
      }
    }
    final deleted = await _deleteOldOrphans(
      active.map((task) => task.id).toSet(),
    );
    return RecoverySummary(
      requeued: requeued,
      resumed: resumed,
      completed: completed,
      failed: failed,
      orphanDirectoriesDeleted: deleted,
      entries: List.unmodifiable(entries),
    );
  }

  File _tempFile(String taskId) => File(
    path.join(
      paths.rootDirectory.path,
      paths
          .importTempRelativePath(taskId)
          .replaceAll('/', Platform.pathSeparator),
    ),
  );

  Future<int> _deleteOldOrphans(Set<String> activeIds) async {
    var deleted = 0;
    await for (final entity in paths.importsTempDirectory.list()) {
      if (entity is! Directory ||
          activeIds.contains(path.basename(entity.path))) {
        continue;
      }
      DateTime? modified;
      await for (final child in entity.list(recursive: true)) {
        final childModified = await child.stat().then((stat) => stat.modified);
        if (modified == null || childModified.isAfter(modified)) {
          modified = childModified;
        }
      }
      modified ??= await entity.stat().then((stat) => stat.modified);
      if (now().difference(modified!) > const Duration(hours: 24)) {
        await entity.delete(recursive: true);
        deleted++;
      }
    }
    return deleted;
  }
}
