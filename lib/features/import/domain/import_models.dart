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

  const factory ImportItemResult.success({required String videoId}) =
      ImportSuccess;

  const factory ImportItemResult.duplicate({
    required String videoId,
    required DateTime recordedAt,
  }) = ImportDuplicate;

  const factory ImportItemResult.failure({
    required ImportErrorKind errorKind,
    required String message,
  }) = ImportFailure;
}

final class ImportSuccess extends ImportItemResult {
  const ImportSuccess({required this.videoId}) : super._();

  final String videoId;
}

final class ImportDuplicate extends ImportItemResult {
  const ImportDuplicate({required this.videoId, required this.recordedAt})
    : super._();

  final String videoId;
  final DateTime recordedAt;
}

final class ImportFailure extends ImportItemResult {
  const ImportFailure({required this.errorKind, required this.message})
    : super._();

  final ImportErrorKind errorKind;
  final String message;
}

final class ImportProgress {
  const ImportProgress({
    required this.status,
    required this.total,
    this.completed = 0,
    this.duplicate = 0,
    this.failed = 0,
  }) : assert(total >= 0),
       assert(completed >= 0),
       assert(duplicate >= 0),
       assert(failed >= 0),
       assert(completed + duplicate + failed <= total);

  final ImportStatus status;
  final int total;
  final int completed;
  final int duplicate;
  final int failed;
}
