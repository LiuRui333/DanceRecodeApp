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

  Future<ImportProgress?> restore();

  Future<void> close();
}

typedef ImportWorkflowBoundaryFactory = ImportWorkflowBoundary Function();
typedef ImportSupportDirectoryLoader = Future<Directory> Function();
typedef ImportDatabaseFactory = AppDatabase Function(Directory supportRoot);

/// Creates the real import workflow while allowing an isolated app-private
/// support root in integration tests. The returned boundary owns and closes
/// the database returned by [databaseFactory].
ImportWorkflowBoundary createDefaultImportWorkflowBoundary({
  required VideoPickerGateway picker,
  ImportSupportDirectoryLoader? supportDirectoryLoader,
  ImportDatabaseFactory? databaseFactory,
}) => _DefaultImportWorkflowBoundary(
  picker: picker,
  supportDirectoryLoader:
      supportDirectoryLoader ?? getApplicationSupportDirectory,
  databaseFactory: databaseFactory ?? (_) => AppDatabase.defaults(),
);

final importWorkflowBoundaryFactoryProvider =
    Provider<ImportWorkflowBoundaryFactory>(
      (ref) =>
          () => createDefaultImportWorkflowBoundary(
            picker: ref.read(videoPickerGatewayProvider),
          ),
    );

final videoPickerGatewayProvider = Provider<VideoPickerGateway>(
  (ref) => ImagePickerVideoPickerGateway(),
);

final importWorkflowBoundaryProvider = Provider<ImportWorkflowBoundary>((ref) {
  final boundary = ref.read(importWorkflowBoundaryFactoryProvider)();
  ref.onDispose(boundary.close);
  return boundary;
});

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

  Future<void> restore() async {
    if (_running) return;
    _running = true;
    try {
      final progress = await ref.read(importWorkflowBoundaryProvider).restore();
      if (progress != null) state = AsyncData(progress);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _running = false;
    }
  }

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
  _DefaultImportWorkflowBoundary({
    required this.picker,
    required this.supportDirectoryLoader,
    required this.databaseFactory,
  });

  final VideoPickerGateway picker;
  final ImportSupportDirectoryLoader supportDirectoryLoader;
  final ImportDatabaseFactory databaseFactory;
  Future<_ImportServices>? _services;
  bool _closed = false;

  @override
  Future<List<ImportSource>> pickVideos() => picker.pickVideos();

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
  Future<ImportProgress?> restore() async {
    final services = await _loadServices();
    final summary = await services.recovery.recoverInterrupted();
    if (summary.entries.isEmpty) return null;
    return ImportProgress(
      status: ImportStatus.completed,
      total: summary.entries.length,
      completed: summary.entries
          .where((entry) => entry.result is ImportSuccess)
          .length,
      duplicate: summary.entries
          .where((entry) => entry.result is ImportDuplicate)
          .length,
      failed: summary.entries
          .where((entry) => entry.result is ImportFailure)
          .length,
      entries: summary.entries,
    );
  }

  Future<_ImportServices> _loadServices() {
    if (_closed) return Future.error(StateError('Import workflow is closed'));
    return _services ??= _createServices();
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final services = _services;
    if (services != null) await (await services).close();
  }

  Future<_ImportServices> _createServices() async {
    final supportRoot = await supportDirectoryLoader();
    final paths = AppMediaPaths(supportRoot);
    final database = databaseFactory(supportRoot);
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
      database,
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
  _ImportServices(this.database, this.coordinator, this.recovery);

  final AppDatabase database;
  final ImportCoordinator coordinator;
  final ImportRecoveryService recovery;
  bool _closed = false;

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await database.close();
  }
}
