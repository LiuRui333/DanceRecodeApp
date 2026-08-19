import 'package:dance_video_diary/features/import/domain/recorded_at_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses embedded metadata time and converts it to UTC', () {
    final importedAt = DateTime.utc(2026, 7, 30, 12);
    final mediaRecordedAt = DateTime.utc(2026, 7, 29, 8);
    final metadataRecordedAt = DateTime(2026, 7, 28, 9, 30);

    final resolvedAt = resolveRecordedAt(
      metadataRecordedAt: metadataRecordedAt,
      mediaRecordedAt: mediaRecordedAt,
      importedAt: importedAt,
    );

    expect(resolvedAt, metadataRecordedAt.toUtc());
    expect(resolvedAt.isUtc, isTrue);
  });

  test('uses media time when embedded metadata time is unavailable', () {
    final importedAt = DateTime.utc(2026, 7, 30, 12);
    final mediaRecordedAt = DateTime(2026, 7, 29, 8);

    final resolvedAt = resolveRecordedAt(
      mediaRecordedAt: mediaRecordedAt,
      importedAt: importedAt,
    );

    expect(resolvedAt, mediaRecordedAt.toUtc());
    expect(resolvedAt.isUtc, isTrue);
  });

  test('uses import time when no media timestamps are available', () {
    final importedAt = DateTime(2026, 7, 30, 12);

    final resolvedAt = resolveRecordedAt(importedAt: importedAt);

    expect(resolvedAt, importedAt.toUtc());
    expect(resolvedAt.isUtc, isTrue);
  });
}
