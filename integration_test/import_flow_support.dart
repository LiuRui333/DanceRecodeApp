Future<T> runWithCleanup<T>({
  required Future<T> Function() body,
  required Future<void> Function() cleanup,
}) async {
  Object? primaryError;
  try {
    return await body();
  } catch (error) {
    primaryError = error;
    rethrow;
  } finally {
    try {
      await cleanup();
    } catch (_) {
      if (primaryError == null) rethrow;
    }
  }
}
