import 'package:dance_video_diary/core/database/app_database.dart';
import 'package:drift/drift.dart';

final class ImportedVideoDraft {
  const ImportedVideoDraft({
    required this.id,
    required this.relativePath,
    this.originalFileName,
    required this.sha256,
    required this.sizeBytes,
    required this.recordedAt,
    this.metadataRecordedAt,
    required this.importedAt,
    this.thumbnailPath,
    this.durationMs,
    this.width,
    this.height,
    this.tagIds = const [],
  });

  final String id;
  final String relativePath;
  final String? originalFileName;
  final String sha256;
  final int sizeBytes;
  final DateTime recordedAt;
  final DateTime? metadataRecordedAt;
  final DateTime importedAt;
  final String? thumbnailPath;
  final int? durationMs;
  final int? width;
  final int? height;
  final List<String> tagIds;
}

final class VideoRepository {
  const VideoRepository(this._database);

  final AppDatabase _database;

  Future<PracticeVideo?> findById(String videoId) {
    return (_database.select(
      _database.practiceVideos,
    )..where((video) => video.id.equals(videoId))).getSingleOrNull();
  }

  Future<PracticeVideo?> findDuplicate({
    required int sizeBytes,
    required String sha256,
  }) {
    return (_database.select(_database.practiceVideos)..where(
          (video) =>
              video.fileSizeBytes.equals(sizeBytes) &
              video.fileHash.equals(sha256),
        ))
        .getSingleOrNull();
  }

  Future<void> insertImportedVideo(ImportedVideoDraft draft) {
    return _database.transaction(() async {
      await _database
          .into(_database.practiceVideos)
          .insert(
            PracticeVideosCompanion.insert(
              id: draft.id,
              relativePath: draft.relativePath,
              originalFileName: Value(draft.originalFileName),
              thumbnailPath: Value(draft.thumbnailPath),
              fileHash: draft.sha256,
              fileSizeBytes: draft.sizeBytes,
              recordedAt: draft.recordedAt.toUtc(),
              metadataRecordedAt: Value(draft.metadataRecordedAt?.toUtc()),
              importedAt: draft.importedAt.toUtc(),
              durationMs: Value(draft.durationMs),
              width: Value(draft.width),
              height: Value(draft.height),
              isFavorite: false,
              createdAt: draft.importedAt.toUtc(),
              updatedAt: draft.importedAt.toUtc(),
            ),
          );

      for (final tagId in draft.tagIds) {
        await _database
            .into(_database.videoTags)
            .insert(VideoTagsCompanion.insert(videoId: draft.id, tagId: tagId));
      }
    });
  }
}
