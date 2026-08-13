import 'dart:async';
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
import 'package:dance_video_diary/features/import/application/import_recovery_service.dart';
import 'package:dance_video_diary/features/import/application/video_picker_gateway.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class ImportWorkflowBoundary {
  Future<List<ImportSource>> pickVideos();

  Stream<ImportProgress> import(List<ImportSource> sources);

  Future<ImportItemResult> retry(String taskId);

  Future<void> restore();
}

typedef OpenImportedRecord = Future<void> Function(String videoId);

final importWorkflowBoundaryProvider = Provider<ImportWorkflowBoundary>(
  (ref) => _DefaultImportWorkflowBoundary(),
);

final openImportedRecordProvider = Provider<OpenImportedRecord>(
  (ref) => (_) async {},
);

final importControllerProvider =
    AsyncNotifierProvider<ImportController, ImportProgress?>(
      ImportController.new,
    );

final class ImportController extends AsyncNotifier<ImportProgress?> {
  bool _running = false;

  @override
  FutureOr<ImportProgress?> build() => null;

  Future<void> pickAndImport() async {
    if (_running) return;
    _running = true;
    try {
      final boundary = ref.read(importWorkflowBoundaryProvider);
      final sources = await boundary.pickVideos();
      if (sources.isEmpty) return;
      state = const AsyncLoading();
      await for (final progress in boundary.import(sources)) {
        state = AsyncData(progress);
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _running = false;
    }
  }

  Future<void> retry(String taskId) async {
    final progress = state.value;
    if (_running || progress == null) return;
    final index = progress.entries.indexWhere(
      (entry) => entry.taskId == taskId,
    );
    if (index < 0) return;
    _running = true;
    try {
      final result = await ref
          .read(importWorkflowBoundaryProvider)
          .retry(taskId);
      final entries = progress.entries.toList();
      final previous = entries[index];
      entries[index] = ImportResultEntry(
        taskId: previous.taskId,
        displayName: previous.displayName,
        result: result,
      );
      state = AsyncData(_completedProgress(entries));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _running = false;
    }
  }

  Future<void> restore() => ref.read(importWorkflowBoundaryProvider).restore();

  ImportProgress _completedProgress(
    List<ImportResultEntry> entries,
  ) => ImportProgress(
    status: ImportStatus.completed,
    total: entries.length,
    completed: entries.where((entry) => entry.result is ImportSuccess).length,
    duplicate: entries.where((entry) => entry.result is ImportDuplicate).length,
    failed: entries.where((entry) => entry.result is ImportFailure).length,
    entries: entries,
  );
}

final class _DefaultImportWorkflowBoundary implements ImportWorkflowBoundary {
  final VideoPickerGateway _picker = ImagePickerVideoPickerGateway();
  Future<_ImportServices>? _services;

  @override
  Future<List<ImportSource>> pickVideos() => _picker.pickVideos();

  @override
  Stream<ImportProgress> import(List<ImportSource> sources) async* {
    final services = await _loadServices();
    yield* services.coordinator.import(sources);
  }

  @override
  Future<ImportItemResult> retry(String taskId) async {
    final services = await _loadServices();
    return services.coordinator.retry(taskId);
  }

  @override
  Future<void> restore() async {
    final services = await _loadServices();
    await services.recovery.recoverInterrupted();
  }

  Future<_ImportServices> _loadServices() => _services ??= _createServices();

  Future<_ImportServices> _createServices() async {
    final paths = AppMediaPaths(await getApplicationSupportDirectory());
    final database = AppDatabase.defaults();
    final tasks = ImportTaskRepository(database);
    final videos = VideoRepository(database);
    final mediaBridge = MethodChannelMediaBridge();
    final coordinator = ImportCoordinator(
      taskRepository: tasks,
      videoRepository: videos,
      paths: paths,
      fileGateway: FileGateway(paths),
      hashService: HashService(),
      mediaInspector: MethodChannelMediaInspector(bridge: mediaBridge),
      thumbnailService: MethodChannelThumbnailService(bridge: mediaBridge),
      openSource: openFileSource,
      availableBytes: (Directory directory) =>
          mediaBridge.availableBytes(directory.path),
    );
    return _ImportServices(
      coordinator,
      ImportRecoveryService(
        taskRepository: tasks,
        videoRepository: videos,
        paths: paths,
        runner: coordinator,
        now: DateTime.now,
      ),
    );
  }
}

final class _ImportServices {
  const _ImportServices(this.coordinator, this.recovery);

  final ImportCoordinator coordinator;
  final ImportRecoveryService recovery;
}
