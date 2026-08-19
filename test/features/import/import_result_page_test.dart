import 'dart:async';

import 'package:dance_video_diary/features/import/application/import_providers.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:dance_video_diary/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lists outcomes, opens duplicates, and retries failed items', (
    tester,
  ) async {
    final boundary = _ResultBoundary();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [importWorkflowBoundaryProvider.overrideWithValue(boundary)],
        child: const MaterialApp(home: AppShell()),
      ),
    );

    await tester.tap(find.text('导入视频'));
    await tester.pump();
    boundary.complete();
    await tester.pump();

    expect(find.text('success.mp4'), findsOneWidget);
    expect(find.text('duplicate.mp4'), findsOneWidget);
    expect(find.text('failed.mp4'), findsOneWidget);
    expect(_ResultBoundary.duplicateRecordedAt.toLocal().day, 1);
    expect(find.text('2026-08-01'), findsOneWidget);
    expect(find.text('存储空间不足'), findsOneWidget);

    await tester.ensureVisible(find.text('打开记录'));
    await tester.tap(find.text('打开记录'));
    await tester.pumpAndSettle();
    expect(find.text('记录详情'), findsOneWidget);
    expect(find.text('记录 ID：existing-video'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('重试'));
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(boundary.retriedTaskId, 'task-failed');
    expect(find.text('failed.mp4'), findsOneWidget);
    expect(find.text('存储空间不足'), findsNothing);
  });

  testWidgets('localizes each failure without revealing private paths', (
    tester,
  ) async {
    final entries = <ImportResultEntry>[];
    for (final pair in <(ImportErrorKind, String)>[
      (ImportErrorKind.insufficientSpace, '存储空间不足'),
      (ImportErrorKind.sourceUnavailable, '视频来源已失效'),
      (ImportErrorKind.unsupportedMedia, '视频不受支持或已损坏'),
      (ImportErrorKind.io, '存储失败'),
      (ImportErrorKind.database, '数据库保存失败'),
      (ImportErrorKind.interrupted, '上次导入被中断'),
    ]) {
      entries.add(
        ImportResultEntry(
          taskId: 'task-${pair.$1.name}',
          displayName: '${pair.$1.name}.mp4',
          result: ImportItemResult.failure(
            errorKind: pair.$1,
            message: r'C:\private\secret.mp4',
          ),
        ),
      );
    }
    final boundary = _ResultBoundary(entries: entries);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [importWorkflowBoundaryProvider.overrideWithValue(boundary)],
        child: const MaterialApp(home: AppShell()),
      ),
    );

    await tester.tap(find.text('导入视频'));
    await tester.pump();
    boundary.complete();
    await tester.pump();

    for (final copy in <String>[
      '存储空间不足',
      '视频来源已失效',
      '视频不受支持或已损坏',
      '存储失败',
      '数据库保存失败',
      '上次导入被中断',
    ]) {
      await tester.scrollUntilVisible(
        find.text(copy),
        120,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text(copy), findsOneWidget);
    }
    expect(find.textContaining(r'C:\private'), findsNothing);
  });
}

final class _ResultBoundary implements ImportWorkflowBoundary {
  _ResultBoundary({List<ImportResultEntry>? entries})
    : entries = entries ?? _defaultEntries;

  static final duplicateRecordedAt = DateTime.utc(2026, 7, 31, 18, 30);

  static final _defaultEntries = <ImportResultEntry>[
    ImportResultEntry(
      taskId: 'task-success',
      displayName: 'success.mp4',
      result: ImportItemResult.success(videoId: 'new-video'),
    ),
    ImportResultEntry(
      taskId: 'task-duplicate',
      displayName: 'duplicate.mp4',
      result: ImportItemResult.duplicate(
        videoId: 'existing-video',
        recordedAt: duplicateRecordedAt,
      ),
    ),
    ImportResultEntry(
      taskId: 'task-failed',
      displayName: 'failed.mp4',
      result: ImportItemResult.failure(
        errorKind: ImportErrorKind.insufficientSpace,
        message: r'C:\private\secret.mp4',
      ),
    ),
  ];

  final List<ImportResultEntry> entries;
  final progress = StreamController<ImportProgress>();
  String? retriedTaskId;

  @override
  Future<void> close() async {}

  void complete() {
    final successes = entries
        .where((entry) => entry.result is ImportSuccess)
        .length;
    final duplicates = entries
        .where((entry) => entry.result is ImportDuplicate)
        .length;
    final failures = entries
        .where((entry) => entry.result is ImportFailure)
        .length;
    progress.add(
      ImportProgress(
        status: ImportStatus.completed,
        total: entries.length,
        completed: successes,
        duplicate: duplicates,
        failed: failures,
        entries: entries,
      ),
    );
    unawaited(progress.close());
  }

  @override
  Future<List<ImportSource>> pickVideos() async => [
    ImportSource(
      uri: 'content://videos/source.mp4',
      displayName: 'source.mp4',
      sizeBytes: 1,
      modifiedAt: DateTime.utc(2026, 8, 1),
    ),
  ];

  @override
  Stream<ImportProgress> import(List<ImportSource> sources) => progress.stream;

  @override
  Future<ImportItemResult> retry(String taskId) async {
    retriedTaskId = taskId;
    return ImportItemResult.success(videoId: 'retried-video');
  }

  @override
  Future<ImportProgress?> restore() async => null;
}
