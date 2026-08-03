import 'package:dance_video_diary/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDatabase schema', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test(
      'stores UTC practice videos and rejects duplicate relative paths',
      () async {
        await db
            .into(db.practiceVideos)
            .insert(_video(id: 'v1', path: 'media/videos/v1.mp4'));

        final stored = await (db.select(
          db.practiceVideos,
        )..where((video) => video.id.equals('v1'))).getSingle();
        expect(stored.role, 'practice');
        expect(stored.recordedAt.isUtc, isTrue);

        await expectLater(
          db
              .into(db.practiceVideos)
              .insert(_video(id: 'v2', path: 'media/videos/v1.mp4')),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test('enforces unique tag names and video tag associations', () async {
      await db
          .into(db.practiceVideos)
          .insert(_video(id: 'v1', path: 'media/videos/v1.mp4'));
      await db.into(db.tags).insert(_tag(id: 't1', normalizedName: 'hiphop'));
      await db
          .into(db.videoTags)
          .insert(
            const VideoTagsCompanion(videoId: Value('v1'), tagId: Value('t1')),
          );

      await expectLater(
        db.into(db.tags).insert(_tag(id: 't2', normalizedName: 'hiphop')),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        db
            .into(db.videoTags)
            .insert(
              const VideoTagsCompanion(
                videoId: Value('v1'),
                tagId: Value('t1'),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('rejects invalid energy ratings and tag types', () async {
      await expectLater(
        db
            .into(db.practiceVideos)
            .insert(
              _video(
                id: 'v1',
                path: 'media/videos/v1.mp4',
              ).copyWith(energyRating: const Value(6)),
            ),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        db
            .into(db.tags)
            .insert(
              _tag(
                id: 't1',
                normalizedName: 'hiphop',
              ).copyWith(type: const Value('invalid')),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
      'rejects absolute and parent-traversal paths in persisted path fields',
      () async {
        const invalidPaths = <String>[
          '/media/videos/v1.mp4',
          r'C:\media\videos\v1.mp4',
          'C:/media/videos/v1.mp4',
          r'\\server\share\v1.mp4',
          'media/../videos/v1.mp4',
          r'media\..\videos\v1.mp4',
        ];
        final timestamp = DateTime(2026, 8, 3, 12).toUtc();

        for (var index = 0; index < invalidPaths.length; index++) {
          final path = invalidPaths[index];
          await expectLater(
            db
                .into(db.practiceVideos)
                .insert(_video(id: 'relative-$index', path: path)),
            throwsA(isA<SqliteException>()),
          );
          await expectLater(
            db
                .into(db.practiceVideos)
                .insert(
                  _video(
                    id: 'thumbnail-$index',
                    path: 'media/videos/thumbnail-$index.mp4',
                  ).copyWith(thumbnailPath: Value(path)),
                ),
            throwsA(isA<SqliteException>()),
          );
          await expectLater(
            db
                .into(db.importTasks)
                .insert(
                  ImportTasksCompanion.insert(
                    id: 'task-$index',
                    sourceUri: 'content://media/external/video/$index',
                    displayName: '$index.mp4',
                    tempRelativePath: Value(path),
                    status: 'pending',
                    createdAt: timestamp,
                    updatedAt: timestamp,
                  ),
                ),
            throwsA(isA<SqliteException>()),
          );
        }
      },
    );

    test(
      'deleting a tag removes associations without deleting its video',
      () async {
        await db
            .into(db.practiceVideos)
            .insert(_video(id: 'v1', path: 'media/videos/v1.mp4'));
        await db.into(db.tags).insert(_tag(id: 't1', normalizedName: 'hiphop'));
        await db
            .into(db.videoTags)
            .insert(
              const VideoTagsCompanion(
                videoId: Value('v1'),
                tagId: Value('t1'),
              ),
            );

        await (db.delete(db.tags)..where((tag) => tag.id.equals('t1'))).go();

        expect(await db.select(db.practiceVideos).get(), hasLength(1));
        expect(await db.select(db.videoTags).get(), isEmpty);
      },
    );

    test(
      'creates the required practice video indexes at schema version one',
      () async {
        final indexes = await db
            .customSelect("PRAGMA index_list('practice_videos')")
            .get();
        final names = indexes.map((row) => row.read<String>('name')).toSet();

        expect(
          names,
          containsAll(<String>{
            'practice_videos_recorded_at_idx',
            'practice_videos_file_hash_idx',
            'practice_videos_is_favorite_idx',
            'practice_videos_deleted_at_idx',
          }),
        );
        expect(db.schemaVersion, 1);
      },
    );
  });
}

PracticeVideosCompanion _video({required String id, required String path}) {
  final timestamp = DateTime(2026, 8, 3, 12).toUtc();
  return PracticeVideosCompanion.insert(
    id: id,
    relativePath: path,
    fileHash: 'hash-$id',
    fileSizeBytes: 10,
    recordedAt: timestamp,
    importedAt: timestamp,
    isFavorite: false,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

TagsCompanion _tag({required String id, required String normalizedName}) {
  final timestamp = DateTime(2026, 8, 3, 12).toUtc();
  return TagsCompanion.insert(
    id: id,
    name: normalizedName,
    normalizedName: normalizedName,
    type: 'custom',
    sortOrder: 0,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
