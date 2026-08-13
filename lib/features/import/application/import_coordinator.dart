import 'dart:io';

import 'package:dance_video_diary/core/database/import_task_repository.dart';
import 'package:dance_video_diary/core/database/video_repository.dart';
import 'package:dance_video_diary/core/media/app_media_paths.dart';
import 'package:dance_video_diary/core/media/file_gateway.dart';
import 'package:dance_video_diary/core/media/hash_service.dart';
import 'package:dance_video_diary/core/media/media_inspector.dart';
import 'package:dance_video_diary/core/media/thumbnail_service.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:dance_video_diary/features/import/domain/recorded_at_resolver.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

typedef SourceOpener = Stream<List<int>> Function(String uri);
typedef AvailableBytesReader = Future<int> Function(Directory directory);

final class ImportCoordinator {
  ImportCoordinator({
    required ImportTaskRepository taskRepository,
    required VideoRepository videoRepository,
    required this.paths,
    required FileGateway fileGateway,
    required HashService hashService,
    required MediaInspector mediaInspector,
    required ThumbnailService thumbnailService,
    required this.openSource,
    required this.availableBytes,
    this.unknownSizeCapBytes = 4 * 1024 * 1024 * 1024,
  }) : _tasks = taskRepository,
       _videos = videoRepository,
       _files = fileGateway,
       _hashes = hashService,
       _inspector = mediaInspector,
       _thumbnails = thumbnailService;

  final ImportTaskRepository _tasks;
  final VideoRepository _videos;
  final AppMediaPaths paths;
  final FileGateway _files;
  final HashService _hashes;
  final MediaInspector _inspector;
  final ThumbnailService _thumbnails;
  final SourceOpener openSource;
  final AvailableBytesReader availableBytes;
  final int unknownSizeCapBytes;

  Stream<ImportProgress> import(List<ImportSource> sources) async* {
    var completed = 0;
    var duplicate = 0;
    var failed = 0;
    yield ImportProgress(status: ImportStatus.pending, total: sources.length);
    for (final source in sources) {
      final task = await _tasks.createPending(source);
      final result = await _run(task.id, source);
      switch (result) {
        case ImportSuccess():
          completed++;
        case ImportDuplicate():
          duplicate++;
        case ImportFailure():
          failed++;
      }
      yield ImportProgress(
        status: completed + duplicate + failed == sources.length
            ? ImportStatus.completed
            : ImportStatus.processing,
        total: sources.length,
        completed: completed,
        duplicate: duplicate,
        failed: failed,
      );
    }
  }

  Future<ImportItemResult> retry(String taskId) async {
    final task = await _tasks.getById(taskId);
    if (task == null || task.status != ImportStatus.failed.name) {
      return ImportItemResult.failure(
        errorKind: ImportErrorKind.interrupted,
        message: 'Import task cannot be retried.',
      );
    }
    await _tasks.transition(taskId, ImportStatus.pending);
    return _run(
      taskId,
      ImportSource(
        uri: task.sourceUri,
        displayName: task.displayName,
        sizeBytes: -1,
        modifiedAt: task.updatedAt,
      ),
    );
  }

  Future<ImportItemResult> _run(String taskId, ImportSource source) async {
    final tempRelativePath = paths.importTempRelativePath(taskId);
    final tempFile = File(_absolute(tempRelativePath));
    try {
      if (source.sizeBytes >= 0) {
        final reserve =
            source.sizeBytes +
            _max(64 * 1024 * 1024, (source.sizeBytes * .05).ceil());
        if (await availableBytes(paths.rootDirectory) < reserve) {
          return _fail(
            taskId,
            ImportErrorKind.insufficientSpace,
            'Not enough space to import this video.',
          );
        }
      }
      await _tasks.transition(
        taskId,
        ImportStatus.copying,
        tempRelativePath: tempRelativePath,
      );
      final sourceStream = source.sizeBytes >= 0
          ? openSource(source.uri)
          : _capped(openSource(source.uri));
      final copy = await _files.copySourceToTemp(
        source: sourceStream,
        expectedBytes: source.sizeBytes >= 0 ? source.sizeBytes : null,
        destination: tempFile,
        onProgress: (_) {},
      );
      await _tasks.transition(taskId, ImportStatus.processing);
      final digest = await _hashes.sha256File(tempFile);
      final existing = await _videos.findDuplicate(
        sizeBytes: copy.copiedBytes,
        sha256: digest,
      );
      if (existing != null) {
        await _deleteTaskTemp(tempFile);
        await _tasks.transition(
          taskId,
          ImportStatus.completed,
          progress: 1,
          videoId: existing.id,
        );
        return ImportItemResult.duplicate(
          videoId: existing.id,
          recordedAt: existing.recordedAt,
        );
      }

      final metadata = await _inspector.inspect(tempFile.path);
      final videoId = const Uuid().v4();
      final extension = path.extension(source.displayName);
      final videoRelativePath = paths.videoRelativePath(videoId, extension);
      final thumbnailRelativePath = paths.thumbnailRelativePath(videoId);
      final thumbnailFile = File(_absolute(thumbnailRelativePath));
      String? storedThumbnailPath;
      try {
        final generated = await _thumbnails.generate(
          videoAbsolutePath: tempFile.path,
          outputAbsolutePath: thumbnailFile.path,
        );
        if (generated != null) storedThumbnailPath = thumbnailRelativePath;
      } catch (_) {
        storedThumbnailPath = null;
      }
      final destination = File(_absolute(videoRelativePath));
      await _files.commitTempFile(
        temporaryFile: tempFile,
        destination: destination,
      );
      final importedAt = DateTime.now().toUtc();
      try {
        await _videos.insertImportedVideo(
          ImportedVideoDraft(
            id: videoId,
            relativePath: videoRelativePath,
            originalFileName: source.displayName,
            sha256: digest,
            sizeBytes: copy.copiedBytes,
            recordedAt: resolveRecordedAt(
              metadataRecordedAt: metadata.metadataRecordedAt,
              mediaRecordedAt: source.mediaRecordedAt,
              importedAt: importedAt,
            ),
            metadataRecordedAt: metadata.metadataRecordedAt,
            importedAt: importedAt,
            thumbnailPath: storedThumbnailPath,
            durationMs: metadata.durationMs,
            width: metadata.width,
            height: metadata.height,
          ),
        );
      } catch (_) {
        await _deleteIfExists(destination);
        await _deleteIfExists(thumbnailFile);
        await _deleteTaskTemp(tempFile);
        return _fail(
          taskId,
          ImportErrorKind.database,
          'Could not save the imported video.',
        );
      }
      await _deleteTaskTemp(tempFile);
      await _tasks.transition(
        taskId,
        ImportStatus.completed,
        progress: 1,
        videoId: videoId,
      );
      return ImportItemResult.success(videoId: videoId);
    } on MediaInspectionException {
      return _fail(
        taskId,
        ImportErrorKind.unsupportedMedia,
        'This video format is unsupported or corrupt.',
      );
    } catch (_) {
      await _deleteTaskTemp(tempFile);
      return _fail(taskId, ImportErrorKind.io, 'Could not import this video.');
    }
  }

  Future<ImportItemResult> _fail(
    String taskId,
    ImportErrorKind kind,
    String message,
  ) async {
    final task = await _tasks.getById(taskId);
    if (task != null && task.status != ImportStatus.failed.name) {
      await _tasks.transition(
        taskId,
        ImportStatus.failed,
        errorKind: kind,
        errorMessage: message,
      );
    }
    return ImportItemResult.failure(errorKind: kind, message: message);
  }

  String _absolute(String relativePath) => path.join(
    paths.rootDirectory.path,
    relativePath.replaceAll('/', Platform.pathSeparator),
  );

  Future<void> _deleteTaskTemp(File file) async {
    final directory = file.parent;
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) await file.delete();
  }

  int _max(int left, int right) => left > right ? left : right;

  Stream<List<int>> _capped(Stream<List<int>> source) async* {
    var copied = 0;
    await for (final chunk in source) {
      copied += chunk.length;
      if (copied > unknownSizeCapBytes) {
        throw StateError('Unknown source exceeds safe copy limit');
      }
      yield chunk;
    }
  }
}
