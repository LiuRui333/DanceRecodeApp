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

final class ImportResultEntry {
  factory ImportResultEntry({
    required String taskId,
    required String displayName,
    required ImportItemResult result,
  }) {
    if (taskId.trim().isEmpty) {
      throw ArgumentError.value(taskId, 'taskId', 'must not be blank');
    }
    if (displayName.trim().isEmpty) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'must not be blank',
      );
    }
    return ImportResultEntry._(
      taskId: taskId,
      displayName: displayName,
      result: result,
    );
  }

  const ImportResultEntry._({
    required this.taskId,
    required this.displayName,
    required this.result,
  });

  final String taskId;
  final String displayName;
  final ImportItemResult result;
}

final class ImportProgress {
  factory ImportProgress({
    required ImportStatus status,
    required int total,
    int completed = 0,
    int duplicate = 0,
    int failed = 0,
    String? currentFileName,
    List<ImportResultEntry> entries = const [],
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
    if (currentFileName != null && currentFileName.trim().isEmpty) {
      throw ArgumentError.value(
        currentFileName,
        'currentFileName',
        'must not be blank',
      );
    }
    if (entries.isNotEmpty) {
      final entryCompleted = entries
          .where((entry) => entry.result is ImportSuccess)
          .length;
      final entryDuplicate = entries
          .where((entry) => entry.result is ImportDuplicate)
          .length;
      final entryFailed = entries
          .where((entry) => entry.result is ImportFailure)
          .length;
      if (entryCompleted != completed ||
          entryDuplicate != duplicate ||
          entryFailed != failed) {
        throw ArgumentError('entries must agree with terminal counts');
      }
    }

    return ImportProgress._(
      status: status,
      total: total,
      completed: completed,
      duplicate: duplicate,
      failed: failed,
      currentFileName: currentFileName,
      entries: List.unmodifiable(entries),
    );
  }

  const ImportProgress._({
    required this.status,
    required this.total,
    required this.completed,
    required this.duplicate,
    required this.failed,
    required this.currentFileName,
    required this.entries,
  });

  final ImportStatus status;
  final int total;
  final int completed;
  final int duplicate;
  final int failed;
  final String? currentFileName;
  final List<ImportResultEntry> entries;
}
