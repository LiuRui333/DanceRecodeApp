import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps an import source as domain-safe primitive data', () {
    final mediaRecordedAt = DateTime.utc(2026, 7, 28, 9);
    final modifiedAt = DateTime.utc(2026, 7, 29, 10);
    const uri = 'content://media/external/video/media/42';

    final source = ImportSource(
      uri: uri,
      displayName: 'practice.mp4',
      sizeBytes: 1024,
      mediaRecordedAt: mediaRecordedAt,
      modifiedAt: modifiedAt,
    );

    expect(source.uri, uri);
    expect(source.displayName, 'practice.mp4');
    expect(source.sizeBytes, 1024);
    expect(source.mediaRecordedAt, mediaRecordedAt);
    expect(source.modifiedAt, modifiedAt);
  });

  test('success result contains the created video identifier', () {
    final result = ImportItemResult.success(videoId: 'video-1');

    expect(
      result,
      isA<ImportSuccess>().having(
        (value) => value.videoId,
        'videoId',
        'video-1',
      ),
    );
  });

  test('success result rejects empty or whitespace video identifiers', () {
    for (final videoId in ['', '   ']) {
      expect(
        () => ImportItemResult.success(videoId: videoId),
        throwsA(isA<ArgumentError>()),
      );
    }
  });

  test('duplicate result contains the existing video and recorded time', () {
    final recordedAt = DateTime.utc(2026, 7, 28, 9);
    final result = ImportItemResult.duplicate(
      videoId: 'existing-video',
      recordedAt: recordedAt,
    );

    expect(
      result,
      isA<ImportDuplicate>()
          .having((value) => value.videoId, 'videoId', 'existing-video')
          .having((value) => value.recordedAt, 'recordedAt', recordedAt),
    );
  });

  test('duplicate result rejects empty or whitespace video identifiers', () {
    for (final videoId in ['', '   ']) {
      expect(
        () => ImportItemResult.duplicate(
          videoId: videoId,
          recordedAt: DateTime.utc(2026, 7, 28, 9),
        ),
        throwsA(isA<ArgumentError>()),
      );
    }
  });

  test('failure result contains an error kind and displayable message', () {
    final result = ImportItemResult.failure(
      errorKind: ImportErrorKind.insufficientSpace,
      message: '存储空间不足',
    );

    expect(
      result,
      isA<ImportFailure>()
          .having(
            (value) => value.errorKind,
            'errorKind',
            ImportErrorKind.insufficientSpace,
          )
          .having((value) => value.message, 'message', '存储空间不足'),
    );
  });

  test('failure result rejects empty or whitespace messages', () {
    for (final message in ['', '   ']) {
      expect(
        () => ImportItemResult.failure(
          errorKind: ImportErrorKind.insufficientSpace,
          message: message,
        ),
        throwsA(isA<ArgumentError>()),
      );
    }
  });

  test('progress rejects counts that exceed the total number of items', () {
    expect(
      () => ImportProgress(
        status: ImportStatus.processing,
        total: 3,
        completed: 1,
        duplicate: 1,
        failed: 2,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('progress rejects a negative total', () {
    expect(
      () => ImportProgress(status: ImportStatus.pending, total: -1),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('progress rejects negative terminal counts', () {
    for (final counts in [
      (completed: -1, duplicate: 0, failed: 0),
      (completed: 0, duplicate: -1, failed: 0),
      (completed: 0, duplicate: 0, failed: -1),
    ]) {
      expect(
        () => ImportProgress(
          status: ImportStatus.pending,
          total: 0,
          completed: counts.completed,
          duplicate: counts.duplicate,
          failed: counts.failed,
        ),
        throwsA(isA<ArgumentError>()),
      );
    }
  });

  test('progress tracks terminal item counts within its total', () {
    final progress = ImportProgress(
      status: ImportStatus.processing,
      total: 5,
      completed: 2,
      duplicate: 1,
      failed: 1,
    );

    expect(progress.completed + progress.duplicate + progress.failed, 4);
    expect(progress.total, 5);
  });
}
