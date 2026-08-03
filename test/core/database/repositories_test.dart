import 'package:dance_video_diary/core/database/app_database.dart';
import 'package:dance_video_diary/core/database/import_task_repository.dart';
import 'package:dance_video_diary/core/database/video_repository.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoRepository', () {
    late AppDatabase db;
    late VideoRepository videos;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      videos = VideoRepository(db);
    });

    tearDown(() => db.close());

    test('findDuplicate requires both matching size and hash', () async {
      await videos.insertImportedVideo(
        _draft(id: 'v1', sizeBytes: 10, sha256: 'abc'),
      );

      expect(
        await videos.findDuplicate(sizeBytes: 10, sha256: 'abc'),
        isNotNull,
      );
      expect(await videos.findDuplicate(sizeBytes: 11, sha256: 'abc'), isNull);
      expect(await videos.findDuplicate(sizeBytes: 10, sha256: 'def'), isNull);
    });

    test(
      'insertImportedVideo rolls back the video when an initial tag is missing',
      () async {
        await expectLater(
          videos.insertImportedVideo(
            _draft(id: 'v1', tagIds: const ['missing-tag']),
          ),
          throwsA(isA<Exception>()),
        );

        expect(await db.select(db.practiceVideos).get(), isEmpty);
      },
    );
  });

  group('ImportTaskRepository', () {
    late AppDatabase db;
    late ImportTaskRepository tasks;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      tasks = ImportTaskRepository(db);
    });

    tearDown(() => db.close());

    test('permits the ordered completion transition path', () async {
      final pending = await tasks.createPending(_source('one.mp4'));
      final copying = await tasks.transition(
        pending.id,
        ImportStatus.copying,
        progress: 0.25,
        tempRelativePath: 'temp/imports/${pending.id}/one.mp4',
      );
      final processing = await tasks.transition(
        copying.id,
        ImportStatus.processing,
        progress: 0.75,
      );
      final completed = await tasks.transition(
        processing.id,
        ImportStatus.completed,
        progress: 1,
        videoId: 'v1',
      );

      expect(copying.status, 'copying');
      expect(copying.tempRelativePath, 'temp/imports/${pending.id}/one.mp4');
      expect(processing.status, 'processing');
      expect(completed.status, 'completed');
      expect(completed.progress, 1);
      expect(completed.videoId, 'v1');
    });

    test('permits failure from active states and retry from failed', () async {
      final pending = await tasks.createPending(_source('one.mp4'));
      final failed = await tasks.transition(
        pending.id,
        ImportStatus.failed,
        errorKind: ImportErrorKind.io,
        errorMessage: 'copy failed',
      );
      final retried = await tasks.transition(failed.id, ImportStatus.pending);

      expect(failed.status, 'failed');
      expect(failed.errorKind, 'io');
      expect(failed.errorMessage, 'copy failed');
      expect(retried.status, 'pending');
    });

    test('rejects illegal import task transitions', () async {
      final pending = await tasks.createPending(_source('one.mp4'));

      await expectLater(
        tasks.transition(pending.id, ImportStatus.completed),
        throwsA(isA<StateError>()),
      );
    });

    test('lists only active import tasks as recoverable', () async {
      final pending = await tasks.createPending(_source('pending.mp4'));
      final copying = await tasks.createPending(_source('copying.mp4'));
      final failed = await tasks.createPending(_source('failed.mp4'));
      await tasks.transition(copying.id, ImportStatus.copying);
      await tasks.transition(failed.id, ImportStatus.failed);

      final recoverable = await tasks.listRecoverable();

      expect(
        recoverable.map((task) => task.id),
        containsAll(<String>[pending.id, copying.id]),
      );
      expect(recoverable.map((task) => task.id), isNot(contains(failed.id)));
    });
  });
}

ImportedVideoDraft _draft({
  required String id,
  int sizeBytes = 10,
  String sha256 = 'hash',
  List<String> tagIds = const [],
}) {
  final timestamp = DateTime(2026, 8, 3, 12).toUtc();
  return ImportedVideoDraft(
    id: id,
    relativePath: 'media/videos/$id.mp4',
    originalFileName: '$id.mp4',
    sha256: sha256,
    sizeBytes: sizeBytes,
    recordedAt: timestamp,
    importedAt: timestamp,
    tagIds: tagIds,
  );
}

ImportSource _source(String name) => ImportSource(
  uri: 'content://media/external/video/$name',
  displayName: name,
  sizeBytes: 10,
  modifiedAt: DateTime(2026, 8, 3, 12).toUtc(),
);
