DateTime resolveRecordedAt({
  DateTime? metadataRecordedAt,
  DateTime? mediaRecordedAt,
  required DateTime importedAt,
}) {
  return (metadataRecordedAt ?? mediaRecordedAt ?? importedAt).toUtc();
}
