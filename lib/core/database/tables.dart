import 'package:dance_video_diary/core/database/converters.dart';
import 'package:drift/drift.dart';

@TableIndex(name: 'practice_videos_recorded_at_idx', columns: {#recordedAt})
@TableIndex(name: 'practice_videos_file_hash_idx', columns: {#fileHash})
@TableIndex(name: 'practice_videos_is_favorite_idx', columns: {#isFavorite})
@TableIndex(name: 'practice_videos_deleted_at_idx', columns: {#deletedAt})
class PracticeVideos extends Table {
  TextColumn get id => text()();
  TextColumn get role => text().withDefault(const Constant('practice'))();
  TextColumn get relativePath => text().unique()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get originalFileName => text().nullable()();
  TextColumn get fileHash => text()();
  IntColumn get fileSizeBytes => integer()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  DateTimeColumn get recordedAt =>
      dateTime().map(const UtcDateTimeConverter())();
  DateTimeColumn get metadataRecordedAt =>
      dateTime().map(const UtcDateTimeConverter()).nullable()();
  DateTimeColumn get importedAt =>
      dateTime().map(const UtcDateTimeConverter())();
  TextColumn get musicTitle => text().nullable()();
  TextColumn get musicArtist => text().nullable()();
  IntColumn get musicBpm => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get energyRating => integer().nullable()();
  BoolColumn get isFavorite => boolean()();
  DateTimeColumn get deletedAt =>
      dateTime().map(const UtcDateTimeConverter()).nullable()();
  DateTimeColumn get createdAt =>
      dateTime().map(const UtcDateTimeConverter())();
  DateTimeColumn get updatedAt =>
      dateTime().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (energy_rating IS NULL OR energy_rating BETWEEN 1 AND 5)',
  ];
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text().unique()();
  TextColumn get type => text()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt =>
      dateTime().map(const UtcDateTimeConverter())();
  DateTimeColumn get updatedAt =>
      dateTime().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (type IN ('built_in', 'custom'))",
  ];
}

class VideoTags extends Table {
  TextColumn get videoId =>
      text().references(PracticeVideos, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {videoId, tagId};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get valueType => text()();
  IntColumn get schemaVersion => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

class ImportTasks extends Table {
  TextColumn get id => text()();
  TextColumn get sourceUri => text()();
  TextColumn get displayName => text()();
  TextColumn get tempRelativePath => text().nullable()();
  TextColumn get status => text()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  TextColumn get errorKind => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get videoId => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().map(const UtcDateTimeConverter())();
  DateTimeColumn get updatedAt =>
      dateTime().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
