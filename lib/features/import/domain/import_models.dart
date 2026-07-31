enum ImportStatus { pending, copying, processing, completed, failed }

enum ImportErrorKind {
  insufficientSpace,
  sourceUnavailable,
  unsupportedMedia,
  io,
  database,
  interrupted,
}

sealed class ImportItemResult {
  const ImportItemResult._();

  factory ImportItemResult.success({required String videoId}) {
    if (videoId.trim().isEmpty) {
      throw ArgumentError.value(videoId, 'videoId', 'must not be blank');
    }

    return ImportSuccess._(videoId: videoId);
  }

  factory ImportItemResult.duplicate({
    required String videoId,
    required DateTime recordedAt,
  }) {
    if (videoId.trim().isEmpty) {
      throw ArgumentError.value(videoId, 'videoId', 'must not be blank');
    }

    return ImportDuplicate._(videoId: videoId, recordedAt: recordedAt);
  }

  factory ImportItemResult.failure({
    required ImportErrorKind errorKind,
    required String message,
  }) {
    if (message.trim().isEmpty) {
      throw ArgumentError.value(message, 'message', 'must not be blank');
    }

    return ImportFailure._(errorKind: errorKind, message: message);
  }
}

final class ImportSuccess extends ImportItemResult {
  const ImportSuccess._({required this.videoId}) : super._();

  final String videoId;
}

final class ImportDuplicate extends ImportItemResult {
  const ImportDuplicate._({required this.videoId, required this.recordedAt})
    : super._();

  final String videoId;
  final DateTime recordedAt;
}

final class ImportFailure extends ImportItemResult {
  const ImportFailure._({required this.errorKind, required this.message})
    : super._();

  final ImportErrorKind errorKind;
  final String message;
}

final class ImportProgress {
  factory ImportProgress({
    required ImportStatus status,
    required int total,
    int completed = 0,
    int duplicate = 0,
    int failed = 0,
  }) {
    if (total < 0) {
      throw ArgumentError.value(total, 'total', 'must not be negative');
    }
    if (completed < 0) {
      throw ArgumentError.value(completed, 'completed', 'must not be negative');
    }
    if (duplicate < 0) {
      throw ArgumentError.value(duplicate, 'duplicate', 'must not be negative');
    }
    if (failed < 0) {
      throw ArgumentError.value(failed, 'failed', 'must not be negative');
    }
    if (completed + duplicate + failed > total) {
      throw ArgumentError(
        'completed, duplicate, and failed must not exceed total',
      );
    }

    return ImportProgress._(
      status: status,
      total: total,
      completed: completed,
      duplicate: duplicate,
      failed: failed,
    );
  }

  const ImportProgress._({
    required this.status,
    required this.total,
    required this.completed,
    required this.duplicate,
    required this.failed,
  });

  final ImportStatus status;
  final int total;
  final int completed;
  final int duplicate;
  final int failed;
}
