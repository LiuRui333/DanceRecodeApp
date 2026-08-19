import 'package:dance_video_diary/features/import/application/import_providers.dart';
import 'package:dance_video_diary/features/import/application/video_picker_gateway.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default workflow reads the overridden video picker gateway', () async {
    final picked = ImportSource(
      uri: '/fixtures/video_a.mp4',
      displayName: 'video_a.mp4',
      sizeBytes: 123,
      modifiedAt: DateTime.utc(2026, 7, 30),
    );
    final picker = _TestVideoPickerGateway([picked]);
    final container = ProviderContainer(
      overrides: [videoPickerGatewayProvider.overrideWithValue(picker)],
    );
    addTearDown(container.dispose);

    final workflow = container.read(importWorkflowBoundaryProvider);
    addTearDown(workflow.close);

    expect(await workflow.pickVideos(), same(picker.sources));
  });

  test(
    'public factory uses the supplied picker without loading services',
    () async {
      final picker = _TestVideoPickerGateway([
        ImportSource(
          uri: '/fixtures/video_b.mp4',
          displayName: 'video_b.mp4',
          sizeBytes: 456,
          modifiedAt: DateTime.utc(2026, 7, 31),
        ),
      ]);

      final workflow = createDefaultImportWorkflowBoundary(picker: picker);
      addTearDown(workflow.close);

      expect(await workflow.pickVideos(), same(picker.sources));
    },
  );
}

final class _TestVideoPickerGateway implements VideoPickerGateway {
  const _TestVideoPickerGateway(this.sources);

  final List<ImportSource> sources;

  @override
  Future<List<ImportSource>> pickVideos() async => sources;
}
