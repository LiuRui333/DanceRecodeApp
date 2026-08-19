import 'package:dance_video_diary/core/database/app_database.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class ImportTaskRepository {
  const ImportTaskRepository(this._database);

  final AppDatabase _database;

  Future<ImportTask?> getById(String taskId) {
    return (_database.select(
      _database.importTasks,
    )..where((row) => row.id.equals(taskId))).getSingleOrNull();
  }

  Future<ImportTask> createPending(ImportSource source) async {
    final now = DateTime.now().toUtc();
    final task = ImportTasksCompanion.insert(
      id: const Uuid().v4(),
      sourceUri: source.uri,
      displayName: source.displayName,
      sourceSizeBytes: Value(source.sizeBytes),
      sourceModifiedAt: Value(source.modifiedAt.toUtc()),
      mediaRecordedAt: Value(source.mediaRecordedAt?.toUtc()),
      status: ImportStatus.pending.name,
      createdAt: now,
      updatedAt: now,
    );
    await _database.into(_database.importTasks).insert(task);
    return (_database.select(
      _database.importTasks,
    )..where((row) => row.id.equals(task.id.value))).getSingle();
  }

  Future<ImportTask> transition(
    String taskId,
    ImportStatus next, {
    double? progress,
    ImportErrorKind? errorKind,
    String? errorMessage,
    String? videoId,
    String? tempRelativePath,
    int? tempSizeBytes,
  }) async {
    final current = await (_database.select(
      _database.importTasks,
    )..where((row) => row.id.equals(taskId))).getSingleOrNull();
    if (current == null) {
      throw StateError('Import task not found: $taskId');
    }

    final currentStatus = ImportStatus.values.byName(current.status);
    if (!_isLegalTransition(currentStatus, next)) {
      throw StateError(
        'Illegal import task transition: $currentStatus -> $next',
      );
    }

    final changed =
        await (_database.update(_database.importTasks)..where(
              (row) =>
                  row.id.equals(taskId) & row.status.equals(current.status),
            ))
            .write(
              ImportTasksCompanion(
                status: Value(next.name),
                progress: progress == null
                    ? const Value.absent()
                    : Value(progress),
                errorKind: errorKind == null
                    ? const Value.absent()
                    : Value(errorKind.name),
                errorMessage: errorMessage == null
                    ? const Value.absent()
                    : Value(errorMessage),
                videoId: videoId == null
                    ? const Value.absent()
                    : Value(videoId),
                tempRelativePath: tempRelativePath == null
                    ? const Value.absent()
                    : Value(tempRelativePath),
                tempSizeBytes: tempSizeBytes == null
                    ? const Value.absent()
                    : Value(tempSizeBytes),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
    if (changed != 1) {
      throw StateError('Import task changed before transition: $taskId');
    }

    return (_database.select(
      _database.importTasks,
    )..where((row) => row.id.equals(taskId))).getSingle();
  }

  Future<List<ImportTask>> listRecoverable() {
    return (_database.select(_database.importTasks)..where(
          (row) => row.status.isIn(<String>[
            ImportStatus.pending.name,
            ImportStatus.copying.name,
            ImportStatus.processing.name,
          ]),
        ))
        .get();
  }

  Future<ImportTask> checkpointProcessing(
    String taskId, {
    required String videoId,
    ImportErrorKind? errorKind,
    String? errorMessage,
  }) async {
    final changed =
        await (_database.update(_database.importTasks)..where(
              (row) =>
                  row.id.equals(taskId) &
                  row.status.equals(ImportStatus.processing.name),
            ))
            .write(
              ImportTasksCompanion(
                videoId: Value(videoId),
                errorKind: errorKind == null
                    ? const Value.absent()
                    : Value(errorKind.name),
                errorMessage: errorMessage == null
                    ? const Value.absent()
                    : Value(errorMessage),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
    if (changed != 1) {
      throw StateError('Import task is not processing: $taskId');
    }
    return getById(taskId).then((task) => task!);
  }

  Future<ImportTask> clearProcessingCheckpoint(String taskId) async {
    final changed =
        await (_database.update(_database.importTasks)..where(
              (row) =>
                  row.id.equals(taskId) &
                  row.status.equals(ImportStatus.processing.name),
            ))
            .write(
              ImportTasksCompanion(
                videoId: const Value(null),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
    if (changed != 1) {
      throw StateError('Import task is not processing: $taskId');
    }
    return getById(taskId).then((task) => task!);
  }

  bool _isLegalTransition(ImportStatus current, ImportStatus next) {
    return switch (current) {
      ImportStatus.pending =>
        next == ImportStatus.copying || next == ImportStatus.failed,
      ImportStatus.copying =>
        next == ImportStatus.processing || next == ImportStatus.failed,
      ImportStatus.processing =>
        next == ImportStatus.completed || next == ImportStatus.failed,
      ImportStatus.failed => next == ImportStatus.pending,
      ImportStatus.completed => false,
    };
  }
}
