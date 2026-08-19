final class ImportSource {
  const ImportSource({
    required this.uri,
    required this.displayName,
    required this.sizeBytes,
    this.mediaRecordedAt,
    required this.modifiedAt,
  });

  final String uri;
  final String displayName;
  final int sizeBytes;
  final DateTime? mediaRecordedAt;
  final DateTime modifiedAt;
}
