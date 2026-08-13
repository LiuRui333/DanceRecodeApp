import 'dart:async';

import 'package:dance_video_diary/features/import/application/import_providers.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:dance_video_diary/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts once, disables re-entry, and displays live progress', (
    tester,
  ) async {
    final boundary = _FakeBoundary(
      sources: [_source('one.mp4'), _source('two.mp4'), _source('three.mp4')],
    );
    await tester.pumpWidget(_app(boundary));

    await tester.tap(find.text('导入视频'));
    await tester.tap(find.text('导入视频'));
    await tester.pump();

    expect(boundary.pickCalls, 1);
    expect(find.text('导入视频'), findsNothing);

    boundary.progress.add(
      ImportProgress(
        status: ImportStatus.processing,
        total: 3,
        completed: 1,
        currentFileName: 'two.mp4',
      ),
    );
    await tester.pump();

    expect(find.text('3 个中的第 2 个'), findsOneWidget);
    expect(find.text('two.mp4'), findsOneWidget);
    expect(find.text('成功 1'), findsOneWidget);
    expect(find.text('重复 0'), findsOneWidget);
    expect(find.text('失败 0'), findsOneWidget);
  });

  testWidgets('cancellation stays on shell without showing an error', (
    tester,
  ) async {
    final boundary = _FakeBoundary(sources: const []);
    await tester.pumpWidget(_app(boundary));

    await tester.tap(find.text('导入视频'));
    await tester.pump();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('导入视频'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('app resume invokes the injected recovery boundary', (
    tester,
  ) async {
    final boundary = _FakeBoundary(sources: const []);
    await tester.pumpWidget(_app(boundary));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(boundary.restoreCalls, 1);
  });
}

Widget _app(_FakeBoundary boundary) => ProviderScope(
  overrides: [importWorkflowBoundaryProvider.overrideWithValue(boundary)],
  child: const MaterialApp(home: AppShell()),
);

ImportSource _source(String name) => ImportSource(
  uri: 'content://videos/$name',
  displayName: name,
  sizeBytes: 1,
  modifiedAt: DateTime.utc(2026, 8, 1),
);

final class _FakeBoundary implements ImportWorkflowBoundary {
  _FakeBoundary({required this.sources});

  final List<ImportSource> sources;
  final progress = StreamController<ImportProgress>();
  int pickCalls = 0;
  int restoreCalls = 0;

  @override
  Future<List<ImportSource>> pickVideos() async {
    pickCalls++;
    return sources;
  }

  @override
  Stream<ImportProgress> import(List<ImportSource> sources) => progress.stream;

  @override
  Future<ImportItemResult> retry(String taskId) => throw UnimplementedError();

  @override
  Future<void> restore() async {
    restoreCalls++;
  }
}
