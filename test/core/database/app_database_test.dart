import 'dart:io';

import 'package:dance_video_diary/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
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
        expect(db.schemaVersion, 2);
      },
    );
  });

  test('upgrades a real v1 database and defaults legacy import fields', () async {
    final directory = await Directory.systemTemp.createTemp('database_v1_');
    final file = File(
      '${directory.path}${Platform.pathSeparator}legacy.sqlite',
    );
    addTearDown(() => directory.delete(recursive: true));
    final legacy = AppDatabase(NativeDatabase(file));
    await legacy.customStatement('DROP TABLE import_tasks');
    await legacy.customStatement('''
      CREATE TABLE import_tasks (
        id TEXT NOT NULL PRIMARY KEY,
        source_uri TEXT NOT NULL,
        display_name TEXT NOT NULL,
        temp_relative_path TEXT,
        status TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0,
        error_kind TEXT,
        error_message TEXT,
        video_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await legacy.customStatement(
      "INSERT INTO import_tasks (id, source_uri, display_name, status, created_at, updated_at) VALUES ('legacy', 'content://legacy', 'legacy.mp4', 'pending', 0, 0)",
    );
    await legacy.customStatement('PRAGMA user_version = 1');
    await legacy.close();

    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);
    final legacyTask = await (migrated.select(
      migrated.importTasks,
    )..where((row) => row.id.equals('legacy'))).getSingle();

    expect(legacyTask.sourceSizeBytes, -1);
    expect(legacyTask.sourceModifiedAt, isNull);
    expect(legacyTask.mediaRecordedAt, isNull);
    expect(legacyTask.tempSizeBytes, isNull);
    await migrated
        .into(migrated.importTasks)
        .insert(
          ImportTasksCompanion.insert(
            id: 'new',
            sourceUri: 'content://new',
            displayName: 'new.mp4',
            sourceSizeBytes: const Value(42),
            sourceModifiedAt: Value(DateTime.utc(2026)),
            tempSizeBytes: const Value(42),
            status: 'processing',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
    expect(
      (await migrated.select(migrated.importTasks).get()).last.sourceSizeBytes,
      42,
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
