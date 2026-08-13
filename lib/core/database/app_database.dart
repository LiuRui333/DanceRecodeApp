import 'package:dance_video_diary/core/database/converters.dart';
import 'package:dance_video_diary/core/database/tables.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [PracticeVideos, Tags, VideoTags, AppSettings, ImportTasks],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults() : this(driftDatabase(name: 'dance_diary'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(importTasks, importTasks.sourceSizeBytes);
        await migrator.addColumn(importTasks, importTasks.sourceModifiedAt);
        await migrator.addColumn(importTasks, importTasks.mediaRecordedAt);
        await migrator.addColumn(importTasks, importTasks.tempSizeBytes);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
