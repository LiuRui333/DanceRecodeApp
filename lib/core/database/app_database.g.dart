// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PracticeVideosTable extends PracticeVideos
    with TableInfo<$PracticeVideosTable, PracticeVideo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeVideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('practice'),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalFileNameMeta = const VerificationMeta(
    'originalFileName',
  );
  @override
  late final GeneratedColumn<String> originalFileName = GeneratedColumn<String>(
    'original_file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileHashMeta = const VerificationMeta(
    'fileHash',
  );
  @override
  late final GeneratedColumn<String> fileHash = GeneratedColumn<String>(
    'file_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> recordedAt =
      GeneratedColumn<DateTime>(
        'recorded_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PracticeVideosTable.$converterrecordedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime>
  metadataRecordedAt =
      GeneratedColumn<DateTime>(
        'metadata_recorded_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $PracticeVideosTable.$convertermetadataRecordedAtn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> importedAt =
      GeneratedColumn<DateTime>(
        'imported_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PracticeVideosTable.$converterimportedAt);
  static const VerificationMeta _musicTitleMeta = const VerificationMeta(
    'musicTitle',
  );
  @override
  late final GeneratedColumn<String> musicTitle = GeneratedColumn<String>(
    'music_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _musicArtistMeta = const VerificationMeta(
    'musicArtist',
  );
  @override
  late final GeneratedColumn<String> musicArtist = GeneratedColumn<String>(
    'music_artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _musicBpmMeta = const VerificationMeta(
    'musicBpm',
  );
  @override
  late final GeneratedColumn<int> musicBpm = GeneratedColumn<int>(
    'music_bpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyRatingMeta = const VerificationMeta(
    'energyRating',
  );
  @override
  late final GeneratedColumn<int> energyRating = GeneratedColumn<int>(
    'energy_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime> deletedAt =
      GeneratedColumn<DateTime>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PracticeVideosTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAt =
      GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PracticeVideosTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAt =
      GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PracticeVideosTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    role,
    relativePath,
    thumbnailPath,
    originalFileName,
    fileHash,
    fileSizeBytes,
    durationMs,
    width,
    height,
    recordedAt,
    metadataRecordedAt,
    importedAt,
    musicTitle,
    musicArtist,
    musicBpm,
    notes,
    energyRating,
    isFavorite,
    deletedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_videos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeVideo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('original_file_name')) {
      context.handle(
        _originalFileNameMeta,
        originalFileName.isAcceptableOrUnknown(
          data['original_file_name']!,
          _originalFileNameMeta,
        ),
      );
    }
    if (data.containsKey('file_hash')) {
      context.handle(
        _fileHashMeta,
        fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta),
      );
    } else if (isInserting) {
      context.missing(_fileHashMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('music_title')) {
      context.handle(
        _musicTitleMeta,
        musicTitle.isAcceptableOrUnknown(data['music_title']!, _musicTitleMeta),
      );
    }
    if (data.containsKey('music_artist')) {
      context.handle(
        _musicArtistMeta,
        musicArtist.isAcceptableOrUnknown(
          data['music_artist']!,
          _musicArtistMeta,
        ),
      );
    }
    if (data.containsKey('music_bpm')) {
      context.handle(
        _musicBpmMeta,
        musicBpm.isAcceptableOrUnknown(data['music_bpm']!, _musicBpmMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('energy_rating')) {
      context.handle(
        _energyRatingMeta,
        energyRating.isAcceptableOrUnknown(
          data['energy_rating']!,
          _energyRatingMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeVideo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeVideo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      originalFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_file_name'],
      ),
      fileHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_hash'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      recordedAt: $PracticeVideosTable.$converterrecordedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}recorded_at'],
        )!,
      ),
      metadataRecordedAt: $PracticeVideosTable.$convertermetadataRecordedAtn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.dateTime,
              data['${effectivePrefix}metadata_recorded_at'],
            ),
          ),
      importedAt: $PracticeVideosTable.$converterimportedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}imported_at'],
        )!,
      ),
      musicTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}music_title'],
      ),
      musicArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}music_artist'],
      ),
      musicBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}music_bpm'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      energyRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy_rating'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      deletedAt: $PracticeVideosTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      createdAt: $PracticeVideosTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $PracticeVideosTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $PracticeVideosTable createAlias(String alias) {
    return $PracticeVideosTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $converterrecordedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $convertermetadataRecordedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, DateTime?> $convertermetadataRecordedAtn =
      NullAwareTypeConverter.wrap($convertermetadataRecordedAt);
  static TypeConverter<DateTime, DateTime> $converterimportedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, DateTime?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<DateTime, DateTime> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterupdatedAt =
      const UtcDateTimeConverter();
}

class PracticeVideo extends DataClass implements Insertable<PracticeVideo> {
  final String id;
  final String role;
  final String relativePath;
  final String? thumbnailPath;
  final String? originalFileName;
  final String fileHash;
  final int fileSizeBytes;
  final int? durationMs;
  final int? width;
  final int? height;
  final DateTime recordedAt;
  final DateTime? metadataRecordedAt;
  final DateTime importedAt;
  final String? musicTitle;
  final String? musicArtist;
  final int? musicBpm;
  final String? notes;
  final int? energyRating;
  final bool isFavorite;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PracticeVideo({
    required this.id,
    required this.role,
    required this.relativePath,
    this.thumbnailPath,
    this.originalFileName,
    required this.fileHash,
    required this.fileSizeBytes,
    this.durationMs,
    this.width,
    this.height,
    required this.recordedAt,
    this.metadataRecordedAt,
    required this.importedAt,
    this.musicTitle,
    this.musicArtist,
    this.musicBpm,
    this.notes,
    this.energyRating,
    required this.isFavorite,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['role'] = Variable<String>(role);
    map['relative_path'] = Variable<String>(relativePath);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || originalFileName != null) {
      map['original_file_name'] = Variable<String>(originalFileName);
    }
    map['file_hash'] = Variable<String>(fileHash);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    {
      map['recorded_at'] = Variable<DateTime>(
        $PracticeVideosTable.$converterrecordedAt.toSql(recordedAt),
      );
    }
    if (!nullToAbsent || metadataRecordedAt != null) {
      map['metadata_recorded_at'] = Variable<DateTime>(
        $PracticeVideosTable.$convertermetadataRecordedAtn.toSql(
          metadataRecordedAt,
        ),
      );
    }
    {
      map['imported_at'] = Variable<DateTime>(
        $PracticeVideosTable.$converterimportedAt.toSql(importedAt),
      );
    }
    if (!nullToAbsent || musicTitle != null) {
      map['music_title'] = Variable<String>(musicTitle);
    }
    if (!nullToAbsent || musicArtist != null) {
      map['music_artist'] = Variable<String>(musicArtist);
    }
    if (!nullToAbsent || musicBpm != null) {
      map['music_bpm'] = Variable<int>(musicBpm);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || energyRating != null) {
      map['energy_rating'] = Variable<int>(energyRating);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(
        $PracticeVideosTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['created_at'] = Variable<DateTime>(
        $PracticeVideosTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<DateTime>(
        $PracticeVideosTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  PracticeVideosCompanion toCompanion(bool nullToAbsent) {
    return PracticeVideosCompanion(
      id: Value(id),
      role: Value(role),
      relativePath: Value(relativePath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      originalFileName: originalFileName == null && nullToAbsent
          ? const Value.absent()
          : Value(originalFileName),
      fileHash: Value(fileHash),
      fileSizeBytes: Value(fileSizeBytes),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      recordedAt: Value(recordedAt),
      metadataRecordedAt: metadataRecordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataRecordedAt),
      importedAt: Value(importedAt),
      musicTitle: musicTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(musicTitle),
      musicArtist: musicArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(musicArtist),
      musicBpm: musicBpm == null && nullToAbsent
          ? const Value.absent()
          : Value(musicBpm),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      energyRating: energyRating == null && nullToAbsent
          ? const Value.absent()
          : Value(energyRating),
      isFavorite: Value(isFavorite),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PracticeVideo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeVideo(
      id: serializer.fromJson<String>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      originalFileName: serializer.fromJson<String?>(json['originalFileName']),
      fileHash: serializer.fromJson<String>(json['fileHash']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      metadataRecordedAt: serializer.fromJson<DateTime?>(
        json['metadataRecordedAt'],
      ),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      musicTitle: serializer.fromJson<String?>(json['musicTitle']),
      musicArtist: serializer.fromJson<String?>(json['musicArtist']),
      musicBpm: serializer.fromJson<int?>(json['musicBpm']),
      notes: serializer.fromJson<String?>(json['notes']),
      energyRating: serializer.fromJson<int?>(json['energyRating']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'role': serializer.toJson<String>(role),
      'relativePath': serializer.toJson<String>(relativePath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'originalFileName': serializer.toJson<String?>(originalFileName),
      'fileHash': serializer.toJson<String>(fileHash),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'durationMs': serializer.toJson<int?>(durationMs),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'metadataRecordedAt': serializer.toJson<DateTime?>(metadataRecordedAt),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'musicTitle': serializer.toJson<String?>(musicTitle),
      'musicArtist': serializer.toJson<String?>(musicArtist),
      'musicBpm': serializer.toJson<int?>(musicBpm),
      'notes': serializer.toJson<String?>(notes),
      'energyRating': serializer.toJson<int?>(energyRating),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PracticeVideo copyWith({
    String? id,
    String? role,
    String? relativePath,
    Value<String?> thumbnailPath = const Value.absent(),
    Value<String?> originalFileName = const Value.absent(),
    String? fileHash,
    int? fileSizeBytes,
    Value<int?> durationMs = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    DateTime? recordedAt,
    Value<DateTime?> metadataRecordedAt = const Value.absent(),
    DateTime? importedAt,
    Value<String?> musicTitle = const Value.absent(),
    Value<String?> musicArtist = const Value.absent(),
    Value<int?> musicBpm = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> energyRating = const Value.absent(),
    bool? isFavorite,
    Value<DateTime?> deletedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PracticeVideo(
    id: id ?? this.id,
    role: role ?? this.role,
    relativePath: relativePath ?? this.relativePath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    originalFileName: originalFileName.present
        ? originalFileName.value
        : this.originalFileName,
    fileHash: fileHash ?? this.fileHash,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    recordedAt: recordedAt ?? this.recordedAt,
    metadataRecordedAt: metadataRecordedAt.present
        ? metadataRecordedAt.value
        : this.metadataRecordedAt,
    importedAt: importedAt ?? this.importedAt,
    musicTitle: musicTitle.present ? musicTitle.value : this.musicTitle,
    musicArtist: musicArtist.present ? musicArtist.value : this.musicArtist,
    musicBpm: musicBpm.present ? musicBpm.value : this.musicBpm,
    notes: notes.present ? notes.value : this.notes,
    energyRating: energyRating.present ? energyRating.value : this.energyRating,
    isFavorite: isFavorite ?? this.isFavorite,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PracticeVideo copyWithCompanion(PracticeVideosCompanion data) {
    return PracticeVideo(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      originalFileName: data.originalFileName.present
          ? data.originalFileName.value
          : this.originalFileName,
      fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      metadataRecordedAt: data.metadataRecordedAt.present
          ? data.metadataRecordedAt.value
          : this.metadataRecordedAt,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      musicTitle: data.musicTitle.present
          ? data.musicTitle.value
          : this.musicTitle,
      musicArtist: data.musicArtist.present
          ? data.musicArtist.value
          : this.musicArtist,
      musicBpm: data.musicBpm.present ? data.musicBpm.value : this.musicBpm,
      notes: data.notes.present ? data.notes.value : this.notes,
      energyRating: data.energyRating.present
          ? data.energyRating.value
          : this.energyRating,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeVideo(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('relativePath: $relativePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('fileHash: $fileHash, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('metadataRecordedAt: $metadataRecordedAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('musicTitle: $musicTitle, ')
          ..write('musicArtist: $musicArtist, ')
          ..write('musicBpm: $musicBpm, ')
          ..write('notes: $notes, ')
          ..write('energyRating: $energyRating, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    role,
    relativePath,
    thumbnailPath,
    originalFileName,
    fileHash,
    fileSizeBytes,
    durationMs,
    width,
    height,
    recordedAt,
    metadataRecordedAt,
    importedAt,
    musicTitle,
    musicArtist,
    musicBpm,
    notes,
    energyRating,
    isFavorite,
    deletedAt,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeVideo &&
          other.id == this.id &&
          other.role == this.role &&
          other.relativePath == this.relativePath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.originalFileName == this.originalFileName &&
          other.fileHash == this.fileHash &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.durationMs == this.durationMs &&
          other.width == this.width &&
          other.height == this.height &&
          other.recordedAt == this.recordedAt &&
          other.metadataRecordedAt == this.metadataRecordedAt &&
          other.importedAt == this.importedAt &&
          other.musicTitle == this.musicTitle &&
          other.musicArtist == this.musicArtist &&
          other.musicBpm == this.musicBpm &&
          other.notes == this.notes &&
          other.energyRating == this.energyRating &&
          other.isFavorite == this.isFavorite &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PracticeVideosCompanion extends UpdateCompanion<PracticeVideo> {
  final Value<String> id;
  final Value<String> role;
  final Value<String> relativePath;
  final Value<String?> thumbnailPath;
  final Value<String?> originalFileName;
  final Value<String> fileHash;
  final Value<int> fileSizeBytes;
  final Value<int?> durationMs;
  final Value<int?> width;
  final Value<int?> height;
  final Value<DateTime> recordedAt;
  final Value<DateTime?> metadataRecordedAt;
  final Value<DateTime> importedAt;
  final Value<String?> musicTitle;
  final Value<String?> musicArtist;
  final Value<int?> musicBpm;
  final Value<String?> notes;
  final Value<int?> energyRating;
  final Value<bool> isFavorite;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PracticeVideosCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.originalFileName = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.metadataRecordedAt = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.musicTitle = const Value.absent(),
    this.musicArtist = const Value.absent(),
    this.musicBpm = const Value.absent(),
    this.notes = const Value.absent(),
    this.energyRating = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeVideosCompanion.insert({
    required String id,
    this.role = const Value.absent(),
    required String relativePath,
    this.thumbnailPath = const Value.absent(),
    this.originalFileName = const Value.absent(),
    required String fileHash,
    required int fileSizeBytes,
    this.durationMs = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required DateTime recordedAt,
    this.metadataRecordedAt = const Value.absent(),
    required DateTime importedAt,
    this.musicTitle = const Value.absent(),
    this.musicArtist = const Value.absent(),
    this.musicBpm = const Value.absent(),
    this.notes = const Value.absent(),
    this.energyRating = const Value.absent(),
    required bool isFavorite,
    this.deletedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       relativePath = Value(relativePath),
       fileHash = Value(fileHash),
       fileSizeBytes = Value(fileSizeBytes),
       recordedAt = Value(recordedAt),
       importedAt = Value(importedAt),
       isFavorite = Value(isFavorite),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PracticeVideo> custom({
    Expression<String>? id,
    Expression<String>? role,
    Expression<String>? relativePath,
    Expression<String>? thumbnailPath,
    Expression<String>? originalFileName,
    Expression<String>? fileHash,
    Expression<int>? fileSizeBytes,
    Expression<int>? durationMs,
    Expression<int>? width,
    Expression<int>? height,
    Expression<DateTime>? recordedAt,
    Expression<DateTime>? metadataRecordedAt,
    Expression<DateTime>? importedAt,
    Expression<String>? musicTitle,
    Expression<String>? musicArtist,
    Expression<int>? musicBpm,
    Expression<String>? notes,
    Expression<int>? energyRating,
    Expression<bool>? isFavorite,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (relativePath != null) 'relative_path': relativePath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (originalFileName != null) 'original_file_name': originalFileName,
      if (fileHash != null) 'file_hash': fileHash,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (durationMs != null) 'duration_ms': durationMs,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (metadataRecordedAt != null)
        'metadata_recorded_at': metadataRecordedAt,
      if (importedAt != null) 'imported_at': importedAt,
      if (musicTitle != null) 'music_title': musicTitle,
      if (musicArtist != null) 'music_artist': musicArtist,
      if (musicBpm != null) 'music_bpm': musicBpm,
      if (notes != null) 'notes': notes,
      if (energyRating != null) 'energy_rating': energyRating,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeVideosCompanion copyWith({
    Value<String>? id,
    Value<String>? role,
    Value<String>? relativePath,
    Value<String?>? thumbnailPath,
    Value<String?>? originalFileName,
    Value<String>? fileHash,
    Value<int>? fileSizeBytes,
    Value<int?>? durationMs,
    Value<int?>? width,
    Value<int?>? height,
    Value<DateTime>? recordedAt,
    Value<DateTime?>? metadataRecordedAt,
    Value<DateTime>? importedAt,
    Value<String?>? musicTitle,
    Value<String?>? musicArtist,
    Value<int?>? musicBpm,
    Value<String?>? notes,
    Value<int?>? energyRating,
    Value<bool>? isFavorite,
    Value<DateTime?>? deletedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PracticeVideosCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      relativePath: relativePath ?? this.relativePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      originalFileName: originalFileName ?? this.originalFileName,
      fileHash: fileHash ?? this.fileHash,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      durationMs: durationMs ?? this.durationMs,
      width: width ?? this.width,
      height: height ?? this.height,
      recordedAt: recordedAt ?? this.recordedAt,
      metadataRecordedAt: metadataRecordedAt ?? this.metadataRecordedAt,
      importedAt: importedAt ?? this.importedAt,
      musicTitle: musicTitle ?? this.musicTitle,
      musicArtist: musicArtist ?? this.musicArtist,
      musicBpm: musicBpm ?? this.musicBpm,
      notes: notes ?? this.notes,
      energyRating: energyRating ?? this.energyRating,
      isFavorite: isFavorite ?? this.isFavorite,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (originalFileName.present) {
      map['original_file_name'] = Variable<String>(originalFileName.value);
    }
    if (fileHash.present) {
      map['file_hash'] = Variable<String>(fileHash.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(
        $PracticeVideosTable.$converterrecordedAt.toSql(recordedAt.value),
      );
    }
    if (metadataRecordedAt.present) {
      map['metadata_recorded_at'] = Variable<DateTime>(
        $PracticeVideosTable.$convertermetadataRecordedAtn.toSql(
          metadataRecordedAt.value,
        ),
      );
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(
        $PracticeVideosTable.$converterimportedAt.toSql(importedAt.value),
      );
    }
    if (musicTitle.present) {
      map['music_title'] = Variable<String>(musicTitle.value);
    }
    if (musicArtist.present) {
      map['music_artist'] = Variable<String>(musicArtist.value);
    }
    if (musicBpm.present) {
      map['music_bpm'] = Variable<int>(musicBpm.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (energyRating.present) {
      map['energy_rating'] = Variable<int>(energyRating.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(
        $PracticeVideosTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(
        $PracticeVideosTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(
        $PracticeVideosTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeVideosCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('relativePath: $relativePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('fileHash: $fileHash, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('metadataRecordedAt: $metadataRecordedAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('musicTitle: $musicTitle, ')
          ..write('musicArtist: $musicArtist, ')
          ..write('musicBpm: $musicBpm, ')
          ..write('notes: $notes, ')
          ..write('energyRating: $energyRating, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAt =
      GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TagsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAt =
      GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TagsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    normalizedName,
    type,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: $TagsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $TagsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterupdatedAt =
      const UtcDateTimeConverter();
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String normalizedName;
  final String type;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tag({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.type,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['type'] = Variable<String>(type);
    map['sort_order'] = Variable<int>(sortOrder);
    {
      map['created_at'] = Variable<DateTime>(
        $TagsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<DateTime>(
        $TagsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      type: Value(type),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      type: serializer.fromJson<String>(json['type']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'type': serializer.toJson<String>(type),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    String? normalizedName,
    String? type,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    type: type ?? this.type,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      type: data.type.present ? data.type.value : this.type,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('type: $type, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    normalizedName,
    type,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.type == this.type &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> type;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.type = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required String normalizedName,
    required String type,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       normalizedName = Value(normalizedName),
       type = Value(type),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? type,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (type != null) 'type': type,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? type,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(
        $TagsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(
        $TagsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('type: $type, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VideoTagsTable extends VideoTags
    with TableInfo<$VideoTagsTable, VideoTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_videos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [videoId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideoTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {videoId, tagId};
  @override
  VideoTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoTag(
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $VideoTagsTable createAlias(String alias) {
    return $VideoTagsTable(attachedDatabase, alias);
  }
}

class VideoTag extends DataClass implements Insertable<VideoTag> {
  final String videoId;
  final String tagId;
  const VideoTag({required this.videoId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['video_id'] = Variable<String>(videoId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  VideoTagsCompanion toCompanion(bool nullToAbsent) {
    return VideoTagsCompanion(videoId: Value(videoId), tagId: Value(tagId));
  }

  factory VideoTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoTag(
      videoId: serializer.fromJson<String>(json['videoId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'videoId': serializer.toJson<String>(videoId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  VideoTag copyWith({String? videoId, String? tagId}) =>
      VideoTag(videoId: videoId ?? this.videoId, tagId: tagId ?? this.tagId);
  VideoTag copyWithCompanion(VideoTagsCompanion data) {
    return VideoTag(
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoTag(')
          ..write('videoId: $videoId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(videoId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoTag &&
          other.videoId == this.videoId &&
          other.tagId == this.tagId);
}

class VideoTagsCompanion extends UpdateCompanion<VideoTag> {
  final Value<String> videoId;
  final Value<String> tagId;
  final Value<int> rowid;
  const VideoTagsCompanion({
    this.videoId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideoTagsCompanion.insert({
    required String videoId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : videoId = Value(videoId),
       tagId = Value(tagId);
  static Insertable<VideoTag> custom({
    Expression<String>? videoId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (videoId != null) 'video_id': videoId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideoTagsCompanion copyWith({
    Value<String>? videoId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return VideoTagsCompanion(
      videoId: videoId ?? this.videoId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoTagsCompanion(')
          ..write('videoId: $videoId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  @override
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, valueType, schemaVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_valueTypeMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final String valueType;
  final int schemaVersion;
  const AppSetting({
    required this.key,
    required this.value,
    required this.valueType,
    required this.schemaVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['value_type'] = Variable<String>(valueType);
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      valueType: Value(valueType),
      schemaVersion: Value(schemaVersion),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      valueType: serializer.fromJson<String>(json['valueType']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'valueType': serializer.toJson<String>(valueType),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  AppSetting copyWith({
    String? key,
    String? value,
    String? valueType,
    int? schemaVersion,
  }) => AppSetting(
    key: key ?? this.key,
    value: value ?? this.value,
    valueType: valueType ?? this.valueType,
    schemaVersion: schemaVersion ?? this.schemaVersion,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('valueType: $valueType, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, valueType, schemaVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.valueType == this.valueType &&
          other.schemaVersion == this.schemaVersion);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<String> valueType;
  final Value<int> schemaVersion;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.valueType = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required String valueType,
    required int schemaVersion,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       valueType = Value(valueType),
       schemaVersion = Value(schemaVersion);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? valueType,
    Expression<int>? schemaVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (valueType != null) 'value_type': valueType,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<String>? valueType,
    Value<int>? schemaVersion,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('valueType: $valueType, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportTasksTable extends ImportTasks
    with TableInfo<$ImportTasksTable, ImportTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUriMeta = const VerificationMeta(
    'sourceUri',
  );
  @override
  late final GeneratedColumn<String> sourceUri = GeneratedColumn<String>(
    'source_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempRelativePathMeta = const VerificationMeta(
    'tempRelativePath',
  );
  @override
  late final GeneratedColumn<String> tempRelativePath = GeneratedColumn<String>(
    'temp_relative_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorKindMeta = const VerificationMeta(
    'errorKind',
  );
  @override
  late final GeneratedColumn<String> errorKind = GeneratedColumn<String>(
    'error_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAt =
      GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ImportTasksTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAt =
      GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ImportTasksTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceUri,
    displayName,
    tempRelativePath,
    status,
    progress,
    errorKind,
    errorMessage,
    videoId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_uri')) {
      context.handle(
        _sourceUriMeta,
        sourceUri.isAcceptableOrUnknown(data['source_uri']!, _sourceUriMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUriMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('temp_relative_path')) {
      context.handle(
        _tempRelativePathMeta,
        tempRelativePath.isAcceptableOrUnknown(
          data['temp_relative_path']!,
          _tempRelativePathMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('error_kind')) {
      context.handle(
        _errorKindMeta,
        errorKind.isAcceptableOrUnknown(data['error_kind']!, _errorKindMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_uri'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      tempRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temp_relative_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      errorKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_kind'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      ),
      createdAt: $ImportTasksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ImportTasksTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $ImportTasksTable createAlias(String alias) {
    return $ImportTasksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterupdatedAt =
      const UtcDateTimeConverter();
}

class ImportTask extends DataClass implements Insertable<ImportTask> {
  final String id;
  final String sourceUri;
  final String displayName;
  final String? tempRelativePath;
  final String status;
  final double progress;
  final String? errorKind;
  final String? errorMessage;
  final String? videoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ImportTask({
    required this.id,
    required this.sourceUri,
    required this.displayName,
    this.tempRelativePath,
    required this.status,
    required this.progress,
    this.errorKind,
    this.errorMessage,
    this.videoId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_uri'] = Variable<String>(sourceUri);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || tempRelativePath != null) {
      map['temp_relative_path'] = Variable<String>(tempRelativePath);
    }
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || errorKind != null) {
      map['error_kind'] = Variable<String>(errorKind);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || videoId != null) {
      map['video_id'] = Variable<String>(videoId);
    }
    {
      map['created_at'] = Variable<DateTime>(
        $ImportTasksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<DateTime>(
        $ImportTasksTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  ImportTasksCompanion toCompanion(bool nullToAbsent) {
    return ImportTasksCompanion(
      id: Value(id),
      sourceUri: Value(sourceUri),
      displayName: Value(displayName),
      tempRelativePath: tempRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(tempRelativePath),
      status: Value(status),
      progress: Value(progress),
      errorKind: errorKind == null && nullToAbsent
          ? const Value.absent()
          : Value(errorKind),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      videoId: videoId == null && nullToAbsent
          ? const Value.absent()
          : Value(videoId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ImportTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportTask(
      id: serializer.fromJson<String>(json['id']),
      sourceUri: serializer.fromJson<String>(json['sourceUri']),
      displayName: serializer.fromJson<String>(json['displayName']),
      tempRelativePath: serializer.fromJson<String?>(json['tempRelativePath']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      errorKind: serializer.fromJson<String?>(json['errorKind']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      videoId: serializer.fromJson<String?>(json['videoId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceUri': serializer.toJson<String>(sourceUri),
      'displayName': serializer.toJson<String>(displayName),
      'tempRelativePath': serializer.toJson<String?>(tempRelativePath),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'errorKind': serializer.toJson<String?>(errorKind),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'videoId': serializer.toJson<String?>(videoId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ImportTask copyWith({
    String? id,
    String? sourceUri,
    String? displayName,
    Value<String?> tempRelativePath = const Value.absent(),
    String? status,
    double? progress,
    Value<String?> errorKind = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> videoId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ImportTask(
    id: id ?? this.id,
    sourceUri: sourceUri ?? this.sourceUri,
    displayName: displayName ?? this.displayName,
    tempRelativePath: tempRelativePath.present
        ? tempRelativePath.value
        : this.tempRelativePath,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    errorKind: errorKind.present ? errorKind.value : this.errorKind,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    videoId: videoId.present ? videoId.value : this.videoId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ImportTask copyWithCompanion(ImportTasksCompanion data) {
    return ImportTask(
      id: data.id.present ? data.id.value : this.id,
      sourceUri: data.sourceUri.present ? data.sourceUri.value : this.sourceUri,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      tempRelativePath: data.tempRelativePath.present
          ? data.tempRelativePath.value
          : this.tempRelativePath,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      errorKind: data.errorKind.present ? data.errorKind.value : this.errorKind,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportTask(')
          ..write('id: $id, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('displayName: $displayName, ')
          ..write('tempRelativePath: $tempRelativePath, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('errorKind: $errorKind, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('videoId: $videoId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceUri,
    displayName,
    tempRelativePath,
    status,
    progress,
    errorKind,
    errorMessage,
    videoId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportTask &&
          other.id == this.id &&
          other.sourceUri == this.sourceUri &&
          other.displayName == this.displayName &&
          other.tempRelativePath == this.tempRelativePath &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.errorKind == this.errorKind &&
          other.errorMessage == this.errorMessage &&
          other.videoId == this.videoId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ImportTasksCompanion extends UpdateCompanion<ImportTask> {
  final Value<String> id;
  final Value<String> sourceUri;
  final Value<String> displayName;
  final Value<String?> tempRelativePath;
  final Value<String> status;
  final Value<double> progress;
  final Value<String?> errorKind;
  final Value<String?> errorMessage;
  final Value<String?> videoId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ImportTasksCompanion({
    this.id = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.displayName = const Value.absent(),
    this.tempRelativePath = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.errorKind = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.videoId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportTasksCompanion.insert({
    required String id,
    required String sourceUri,
    required String displayName,
    this.tempRelativePath = const Value.absent(),
    required String status,
    this.progress = const Value.absent(),
    this.errorKind = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.videoId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceUri = Value(sourceUri),
       displayName = Value(displayName),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ImportTask> custom({
    Expression<String>? id,
    Expression<String>? sourceUri,
    Expression<String>? displayName,
    Expression<String>? tempRelativePath,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<String>? errorKind,
    Expression<String>? errorMessage,
    Expression<String>? videoId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceUri != null) 'source_uri': sourceUri,
      if (displayName != null) 'display_name': displayName,
      if (tempRelativePath != null) 'temp_relative_path': tempRelativePath,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (errorKind != null) 'error_kind': errorKind,
      if (errorMessage != null) 'error_message': errorMessage,
      if (videoId != null) 'video_id': videoId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceUri,
    Value<String>? displayName,
    Value<String?>? tempRelativePath,
    Value<String>? status,
    Value<double>? progress,
    Value<String?>? errorKind,
    Value<String?>? errorMessage,
    Value<String?>? videoId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ImportTasksCompanion(
      id: id ?? this.id,
      sourceUri: sourceUri ?? this.sourceUri,
      displayName: displayName ?? this.displayName,
      tempRelativePath: tempRelativePath ?? this.tempRelativePath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorKind: errorKind ?? this.errorKind,
      errorMessage: errorMessage ?? this.errorMessage,
      videoId: videoId ?? this.videoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceUri.present) {
      map['source_uri'] = Variable<String>(sourceUri.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (tempRelativePath.present) {
      map['temp_relative_path'] = Variable<String>(tempRelativePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (errorKind.present) {
      map['error_kind'] = Variable<String>(errorKind.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(
        $ImportTasksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(
        $ImportTasksTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportTasksCompanion(')
          ..write('id: $id, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('displayName: $displayName, ')
          ..write('tempRelativePath: $tempRelativePath, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('errorKind: $errorKind, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('videoId: $videoId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PracticeVideosTable practiceVideos = $PracticeVideosTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $VideoTagsTable videoTags = $VideoTagsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ImportTasksTable importTasks = $ImportTasksTable(this);
  late final Index practiceVideosRecordedAtIdx = Index(
    'practice_videos_recorded_at_idx',
    'CREATE INDEX practice_videos_recorded_at_idx ON practice_videos (recorded_at)',
  );
  late final Index practiceVideosFileHashIdx = Index(
    'practice_videos_file_hash_idx',
    'CREATE INDEX practice_videos_file_hash_idx ON practice_videos (file_hash)',
  );
  late final Index practiceVideosIsFavoriteIdx = Index(
    'practice_videos_is_favorite_idx',
    'CREATE INDEX practice_videos_is_favorite_idx ON practice_videos (is_favorite)',
  );
  late final Index practiceVideosDeletedAtIdx = Index(
    'practice_videos_deleted_at_idx',
    'CREATE INDEX practice_videos_deleted_at_idx ON practice_videos (deleted_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    practiceVideos,
    tags,
    videoTags,
    appSettings,
    importTasks,
    practiceVideosRecordedAtIdx,
    practiceVideosFileHashIdx,
    practiceVideosIsFavoriteIdx,
    practiceVideosDeletedAtIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'practice_videos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('video_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('video_tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PracticeVideosTableCreateCompanionBuilder =
    PracticeVideosCompanion Function({
      required String id,
      Value<String> role,
      required String relativePath,
      Value<String?> thumbnailPath,
      Value<String?> originalFileName,
      required String fileHash,
      required int fileSizeBytes,
      Value<int?> durationMs,
      Value<int?> width,
      Value<int?> height,
      required DateTime recordedAt,
      Value<DateTime?> metadataRecordedAt,
      required DateTime importedAt,
      Value<String?> musicTitle,
      Value<String?> musicArtist,
      Value<int?> musicBpm,
      Value<String?> notes,
      Value<int?> energyRating,
      required bool isFavorite,
      Value<DateTime?> deletedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PracticeVideosTableUpdateCompanionBuilder =
    PracticeVideosCompanion Function({
      Value<String> id,
      Value<String> role,
      Value<String> relativePath,
      Value<String?> thumbnailPath,
      Value<String?> originalFileName,
      Value<String> fileHash,
      Value<int> fileSizeBytes,
      Value<int?> durationMs,
      Value<int?> width,
      Value<int?> height,
      Value<DateTime> recordedAt,
      Value<DateTime?> metadataRecordedAt,
      Value<DateTime> importedAt,
      Value<String?> musicTitle,
      Value<String?> musicArtist,
      Value<int?> musicBpm,
      Value<String?> notes,
      Value<int?> energyRating,
      Value<bool> isFavorite,
      Value<DateTime?> deletedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PracticeVideosTableReferences
    extends BaseReferences<_$AppDatabase, $PracticeVideosTable, PracticeVideo> {
  $$PracticeVideosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$VideoTagsTable, List<VideoTag>>
  _videoTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.videoTags,
    aliasName: 'practice_videos__id__video_tags__video_id',
  );

  $$VideoTagsTableProcessedTableManager get videoTagsRefs {
    final manager = $$VideoTagsTableTableManager(
      $_db,
      $_db.videoTags,
    ).filter((f) => f.videoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_videoTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PracticeVideosTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeVideosTable> {
  $$PracticeVideosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFileName => $composableBuilder(
    column: $table.originalFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get recordedAt =>
      $composableBuilder(
        column: $table.recordedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, DateTime>
  get metadataRecordedAt => $composableBuilder(
    column: $table.metadataRecordedAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get importedAt =>
      $composableBuilder(
        column: $table.importedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get musicTitle => $composableBuilder(
    column: $table.musicTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get musicArtist => $composableBuilder(
    column: $table.musicArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get musicBpm => $composableBuilder(
    column: $table.musicBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energyRating => $composableBuilder(
    column: $table.energyRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, DateTime> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> videoTagsRefs(
    Expression<bool> Function($$VideoTagsTableFilterComposer f) f,
  ) {
    final $$VideoTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.videoTags,
      getReferencedColumn: (t) => t.videoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideoTagsTableFilterComposer(
            $db: $db,
            $table: $db.videoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeVideosTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeVideosTable> {
  $$PracticeVideosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFileName => $composableBuilder(
    column: $table.originalFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get metadataRecordedAt => $composableBuilder(
    column: $table.metadataRecordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get musicTitle => $composableBuilder(
    column: $table.musicTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get musicArtist => $composableBuilder(
    column: $table.musicArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get musicBpm => $composableBuilder(
    column: $table.musicBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energyRating => $composableBuilder(
    column: $table.energyRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeVideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeVideosTable> {
  $$PracticeVideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalFileName => $composableBuilder(
    column: $table.originalFileName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileHash =>
      $composableBuilder(column: $table.fileHash, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get recordedAt =>
      $composableBuilder(
        column: $table.recordedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, DateTime>
  get metadataRecordedAt => $composableBuilder(
    column: $table.metadataRecordedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get importedAt =>
      $composableBuilder(
        column: $table.importedAt,
        builder: (column) => column,
      );

  GeneratedColumn<String> get musicTitle => $composableBuilder(
    column: $table.musicTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get musicArtist => $composableBuilder(
    column: $table.musicArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get musicBpm =>
      $composableBuilder(column: $table.musicBpm, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get energyRating => $composableBuilder(
    column: $table.energyRating,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> videoTagsRefs<T extends Object>(
    Expression<T> Function($$VideoTagsTableAnnotationComposer a) f,
  ) {
    final $$VideoTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.videoTags,
      getReferencedColumn: (t) => t.videoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideoTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.videoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeVideosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeVideosTable,
          PracticeVideo,
          $$PracticeVideosTableFilterComposer,
          $$PracticeVideosTableOrderingComposer,
          $$PracticeVideosTableAnnotationComposer,
          $$PracticeVideosTableCreateCompanionBuilder,
          $$PracticeVideosTableUpdateCompanionBuilder,
          (PracticeVideo, $$PracticeVideosTableReferences),
          PracticeVideo,
          PrefetchHooks Function({bool videoTagsRefs})
        > {
  $$PracticeVideosTableTableManager(
    _$AppDatabase db,
    $PracticeVideosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeVideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeVideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeVideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> originalFileName = const Value.absent(),
                Value<String> fileHash = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<DateTime?> metadataRecordedAt = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<String?> musicTitle = const Value.absent(),
                Value<String?> musicArtist = const Value.absent(),
                Value<int?> musicBpm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> energyRating = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeVideosCompanion(
                id: id,
                role: role,
                relativePath: relativePath,
                thumbnailPath: thumbnailPath,
                originalFileName: originalFileName,
                fileHash: fileHash,
                fileSizeBytes: fileSizeBytes,
                durationMs: durationMs,
                width: width,
                height: height,
                recordedAt: recordedAt,
                metadataRecordedAt: metadataRecordedAt,
                importedAt: importedAt,
                musicTitle: musicTitle,
                musicArtist: musicArtist,
                musicBpm: musicBpm,
                notes: notes,
                energyRating: energyRating,
                isFavorite: isFavorite,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> role = const Value.absent(),
                required String relativePath,
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> originalFileName = const Value.absent(),
                required String fileHash,
                required int fileSizeBytes,
                Value<int?> durationMs = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required DateTime recordedAt,
                Value<DateTime?> metadataRecordedAt = const Value.absent(),
                required DateTime importedAt,
                Value<String?> musicTitle = const Value.absent(),
                Value<String?> musicArtist = const Value.absent(),
                Value<int?> musicBpm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> energyRating = const Value.absent(),
                required bool isFavorite,
                Value<DateTime?> deletedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PracticeVideosCompanion.insert(
                id: id,
                role: role,
                relativePath: relativePath,
                thumbnailPath: thumbnailPath,
                originalFileName: originalFileName,
                fileHash: fileHash,
                fileSizeBytes: fileSizeBytes,
                durationMs: durationMs,
                width: width,
                height: height,
                recordedAt: recordedAt,
                metadataRecordedAt: metadataRecordedAt,
                importedAt: importedAt,
                musicTitle: musicTitle,
                musicArtist: musicArtist,
                musicBpm: musicBpm,
                notes: notes,
                energyRating: energyRating,
                isFavorite: isFavorite,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PracticeVideosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({videoTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (videoTagsRefs) db.videoTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (videoTagsRefs)
                    await $_getPrefetchedData<
                      PracticeVideo,
                      $PracticeVideosTable,
                      VideoTag
                    >(
                      currentTable: table,
                      referencedTable: $$PracticeVideosTableReferences
                          ._videoTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PracticeVideosTableReferences(
                            db,
                            table,
                            p0,
                          ).videoTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.videoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PracticeVideosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeVideosTable,
      PracticeVideo,
      $$PracticeVideosTableFilterComposer,
      $$PracticeVideosTableOrderingComposer,
      $$PracticeVideosTableAnnotationComposer,
      $$PracticeVideosTableCreateCompanionBuilder,
      $$PracticeVideosTableUpdateCompanionBuilder,
      (PracticeVideo, $$PracticeVideosTableReferences),
      PracticeVideo,
      PrefetchHooks Function({bool videoTagsRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      required String normalizedName,
      required String type,
      required int sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> type,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VideoTagsTable, List<VideoTag>>
  _videoTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.videoTags,
    aliasName: 'tags__id__video_tags__tag_id',
  );

  $$VideoTagsTableProcessedTableManager get videoTagsRefs {
    final manager = $$VideoTagsTableTableManager(
      $_db,
      $_db.videoTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_videoTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> videoTagsRefs(
    Expression<bool> Function($$VideoTagsTableFilterComposer f) f,
  ) {
    final $$VideoTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.videoTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideoTagsTableFilterComposer(
            $db: $db,
            $table: $db.videoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> videoTagsRefs<T extends Object>(
    Expression<T> Function($$VideoTagsTableAnnotationComposer a) f,
  ) {
    final $$VideoTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.videoTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideoTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.videoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool videoTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                normalizedName: normalizedName,
                type: type,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String normalizedName,
                required String type,
                required int sortOrder,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                normalizedName: normalizedName,
                type: type,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({videoTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (videoTagsRefs) db.videoTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (videoTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, VideoTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._videoTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).videoTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool videoTagsRefs})
    >;
typedef $$VideoTagsTableCreateCompanionBuilder =
    VideoTagsCompanion Function({
      required String videoId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$VideoTagsTableUpdateCompanionBuilder =
    VideoTagsCompanion Function({
      Value<String> videoId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$VideoTagsTableReferences
    extends BaseReferences<_$AppDatabase, $VideoTagsTable, VideoTag> {
  $$VideoTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PracticeVideosTable _videoIdTable(_$AppDatabase db) => db
      .practiceVideos
      .createAlias('video_tags__video_id__practice_videos__id');

  $$PracticeVideosTableProcessedTableManager get videoId {
    final $_column = $_itemColumn<String>('video_id')!;

    final manager = $$PracticeVideosTableTableManager(
      $_db,
      $_db.practiceVideos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_videoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('video_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VideoTagsTableFilterComposer
    extends Composer<_$AppDatabase, $VideoTagsTable> {
  $$VideoTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PracticeVideosTableFilterComposer get videoId {
    final $$PracticeVideosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.videoId,
      referencedTable: $db.practiceVideos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeVideosTableFilterComposer(
            $db: $db,
            $table: $db.practiceVideos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VideoTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoTagsTable> {
  $$VideoTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PracticeVideosTableOrderingComposer get videoId {
    final $$PracticeVideosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.videoId,
      referencedTable: $db.practiceVideos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeVideosTableOrderingComposer(
            $db: $db,
            $table: $db.practiceVideos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VideoTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoTagsTable> {
  $$VideoTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PracticeVideosTableAnnotationComposer get videoId {
    final $$PracticeVideosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.videoId,
      referencedTable: $db.practiceVideos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeVideosTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceVideos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VideoTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideoTagsTable,
          VideoTag,
          $$VideoTagsTableFilterComposer,
          $$VideoTagsTableOrderingComposer,
          $$VideoTagsTableAnnotationComposer,
          $$VideoTagsTableCreateCompanionBuilder,
          $$VideoTagsTableUpdateCompanionBuilder,
          (VideoTag, $$VideoTagsTableReferences),
          VideoTag,
          PrefetchHooks Function({bool videoId, bool tagId})
        > {
  $$VideoTagsTableTableManager(_$AppDatabase db, $VideoTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> videoId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideoTagsCompanion(
                videoId: videoId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String videoId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => VideoTagsCompanion.insert(
                videoId: videoId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VideoTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({videoId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (videoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.videoId,
                                referencedTable: $$VideoTagsTableReferences
                                    ._videoIdTable(db),
                                referencedColumn: $$VideoTagsTableReferences
                                    ._videoIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$VideoTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$VideoTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VideoTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideoTagsTable,
      VideoTag,
      $$VideoTagsTableFilterComposer,
      $$VideoTagsTableOrderingComposer,
      $$VideoTagsTableAnnotationComposer,
      $$VideoTagsTableCreateCompanionBuilder,
      $$VideoTagsTableUpdateCompanionBuilder,
      (VideoTag, $$VideoTagsTableReferences),
      VideoTag,
      PrefetchHooks Function({bool videoId, bool tagId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required String valueType,
      required int schemaVersion,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<String> valueType,
      Value<int> schemaVersion,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> valueType = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                valueType: valueType,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required String valueType,
                required int schemaVersion,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                valueType: valueType,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ImportTasksTableCreateCompanionBuilder =
    ImportTasksCompanion Function({
      required String id,
      required String sourceUri,
      required String displayName,
      Value<String?> tempRelativePath,
      required String status,
      Value<double> progress,
      Value<String?> errorKind,
      Value<String?> errorMessage,
      Value<String?> videoId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ImportTasksTableUpdateCompanionBuilder =
    ImportTasksCompanion Function({
      Value<String> id,
      Value<String> sourceUri,
      Value<String> displayName,
      Value<String?> tempRelativePath,
      Value<String> status,
      Value<double> progress,
      Value<String?> errorKind,
      Value<String?> errorMessage,
      Value<String?> videoId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ImportTasksTableFilterComposer
    extends Composer<_$AppDatabase, $ImportTasksTable> {
  $$ImportTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tempRelativePath => $composableBuilder(
    column: $table.tempRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorKind => $composableBuilder(
    column: $table.errorKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ImportTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportTasksTable> {
  $$ImportTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tempRelativePath => $composableBuilder(
    column: $table.tempRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorKind => $composableBuilder(
    column: $table.errorKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportTasksTable> {
  $$ImportTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceUri =>
      $composableBuilder(column: $table.sourceUri, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tempRelativePath => $composableBuilder(
    column: $table.tempRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get errorKind =>
      $composableBuilder(column: $table.errorKind, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ImportTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportTasksTable,
          ImportTask,
          $$ImportTasksTableFilterComposer,
          $$ImportTasksTableOrderingComposer,
          $$ImportTasksTableAnnotationComposer,
          $$ImportTasksTableCreateCompanionBuilder,
          $$ImportTasksTableUpdateCompanionBuilder,
          (
            ImportTask,
            BaseReferences<_$AppDatabase, $ImportTasksTable, ImportTask>,
          ),
          ImportTask,
          PrefetchHooks Function()
        > {
  $$ImportTasksTableTableManager(_$AppDatabase db, $ImportTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceUri = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> tempRelativePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> errorKind = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> videoId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportTasksCompanion(
                id: id,
                sourceUri: sourceUri,
                displayName: displayName,
                tempRelativePath: tempRelativePath,
                status: status,
                progress: progress,
                errorKind: errorKind,
                errorMessage: errorMessage,
                videoId: videoId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceUri,
                required String displayName,
                Value<String?> tempRelativePath = const Value.absent(),
                required String status,
                Value<double> progress = const Value.absent(),
                Value<String?> errorKind = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> videoId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImportTasksCompanion.insert(
                id: id,
                sourceUri: sourceUri,
                displayName: displayName,
                tempRelativePath: tempRelativePath,
                status: status,
                progress: progress,
                errorKind: errorKind,
                errorMessage: errorMessage,
                videoId: videoId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportTasksTable,
      ImportTask,
      $$ImportTasksTableFilterComposer,
      $$ImportTasksTableOrderingComposer,
      $$ImportTasksTableAnnotationComposer,
      $$ImportTasksTableCreateCompanionBuilder,
      $$ImportTasksTableUpdateCompanionBuilder,
      (
        ImportTask,
        BaseReferences<_$AppDatabase, $ImportTasksTable, ImportTask>,
      ),
      ImportTask,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PracticeVideosTableTableManager get practiceVideos =>
      $$PracticeVideosTableTableManager(_db, _db.practiceVideos);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$VideoTagsTableTableManager get videoTags =>
      $$VideoTagsTableTableManager(_db, _db.videoTags);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ImportTasksTableTableManager get importTasks =>
      $$ImportTasksTableTableManager(_db, _db.importTasks);
}
