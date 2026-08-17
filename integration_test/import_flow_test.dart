import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dance_video_diary/core/database/app_database.dart';
import 'package:dance_video_diary/core/database/import_task_repository.dart';
import 'package:dance_video_diary/core/media/app_media_paths.dart';
import 'package:dance_video_diary/features/import/application/import_providers.dart';
import 'package:dance_video_diary/features/import/application/video_picker_gateway.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/domain/import_source.dart';
import 'package:dance_video_diary/features/shell/app_shell.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('imports, deduplicates, batches, and recovers real media', (
    tester,
  ) async {
    final runId = DateTime.now().microsecondsSinceEpoch.toString();
    final appSupport = await getApplicationSupportDirectory();
    final supportRoot = Directory(
      path.join(appSupport.path, 'integration_test', runId),
    );
    final temporaryRoot = await getTemporaryDirectory();
    final sourceRoot = Directory(
      path.join(temporaryRoot.path, 'dance_diary_integration_test', runId),
    );
    await supportRoot.create(recursive: true);
    await sourceRoot.create(recursive: true);
    addTearDown(() async {
      if (await supportRoot.exists()) {
        await supportRoot.delete(recursive: true);
      }
      if (await sourceRoot.exists()) {
        await sourceRoot.delete(recursive: true);
      }
    });

    final fixtureA = await _writeAsset(
      'integration_test/fixtures/video_a.mp4',
      File(path.join(sourceRoot.path, 'video_a.mp4')),
    );
    final fixtureB = await _writeAsset(
      'integration_test/fixtures/video_b.mp4',
      File(path.join(sourceRoot.path, 'video_b.mp4')),
    );
    final fixtureC = await _writeVariant(
      fixtureB,
      File(path.join(sourceRoot.path, 'video_c.mp4')),
      0x43,
    );
    final recoveryFixture = await _writeVariant(
      fixtureA,
      File(path.join(sourceRoot.path, 'video_recovery.mp4')),
      0x52,
    );
    final sourceFiles = [fixtureA, fixtureB, fixtureC, recoveryFixture];
    final sourceHashesBefore = await Future.wait(sourceFiles.map(_sha256File));

    final picker = _QueuedVideoPickerGateway([
      [_source(fixtureA)],
      [_source(fixtureA)],
      [_source(fixtureB), _source(fixtureC)],
    ]);

    final first = await _runPickerImport(tester, picker, supportRoot);
    expect(first.completed, 1);
    expect(first.duplicate, 0);
    expect(first.failed, 0);
    final firstVideos = await _readVideos(supportRoot);
    expect(firstVideos, hasLength(1));
    expect(firstVideos.single.fileHash, sourceHashesBefore[0]);
    expect(firstVideos.single.durationMs, greaterThan(0));
    expect(firstVideos.single.width, greaterThan(0));
    expect(firstVideos.single.height, greaterThan(0));
    expect(
      File(
        _absolute(supportRoot, firstVideos.single.relativePath),
      ).existsSync(),
      isTrue,
    );
    expect(firstVideos.single.thumbnailPath, isNotNull);
    expect(
      File(
        _absolute(supportRoot, firstVideos.single.thumbnailPath!),
      ).existsSync(),
      isTrue,
    );

    final duplicate = await _runPickerImport(tester, picker, supportRoot);
    expect(duplicate.completed, 0);
    expect(duplicate.duplicate, 1);
    expect(duplicate.failed, 0);
    expect(await _readVideos(supportRoot), hasLength(1));
    expect(await AppMediaPaths(supportRoot).videosDirectory.list().length, 1);

    final batch = await _runPickerImport(tester, picker, supportRoot);
    expect(batch.completed, 2);
    expect(batch.duplicate, 0);
    expect(batch.failed, 0);
    expect(await _readVideos(supportRoot), hasLength(3));

    final taskId = await _seedProcessingTask(supportRoot, recoveryFixture);
    final recovered = await _runRecovery(tester, picker, supportRoot);
    expect(recovered.entries, hasLength(1));
    expect(recovered.entries.single.taskId, taskId);
    expect(recovered.entries.single.result, isA<ImportSuccess>());
    expect(await _readVideos(supportRoot), hasLength(4));

    final sourceHashesAfter = await Future.wait(sourceFiles.map(_sha256File));
    expect(sourceHashesAfter, sourceHashesBefore);
  });
}

Future<ImportProgress> _runPickerImport(
  WidgetTester tester,
  VideoPickerGateway picker,
  Directory supportRoot,
) async {
  final container = _container(picker, supportRoot);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AppShell()),
    ),
  );
  expect(find.text('导入视频'), findsOneWidget);
  await tester.tap(find.text('导入视频'));
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(minutes: 1),
  );
  final progress = container.read(importControllerProvider).value;
  expect(progress?.status, ImportStatus.completed);
  expect(find.text('成功'), findsOneWidget);
  await _closeContainer(tester, container);
  return progress!;
}

Future<ImportProgress> _runRecovery(
  WidgetTester tester,
  VideoPickerGateway picker,
  Directory supportRoot,
) async {
  final container = _container(picker, supportRoot);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AppShell()),
    ),
  );
  await container.read(importControllerProvider.notifier).restore();
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(minutes: 1),
  );
  final progress = container.read(importControllerProvider).value;
  expect(progress?.status, ImportStatus.completed);
  await _closeContainer(tester, container);
  return progress!;
}

ProviderContainer _container(
  VideoPickerGateway picker,
  Directory supportRoot,
) => ProviderContainer(
  overrides: [
    videoPickerGatewayProvider.overrideWithValue(picker),
    importWorkflowBoundaryFactoryProvider.overrideWith((ref) {
      return () => createDefaultImportWorkflowBoundary(
        picker: ref.read(videoPickerGatewayProvider),
        supportDirectoryLoader: () async => supportRoot,
        databaseFactory: _openDatabase,
      );
    }),
  ],
);

Future<void> _closeContainer(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await container.read(importWorkflowBoundaryProvider).close();
  container.dispose();
  await tester.pumpWidget(const SizedBox.shrink());
}

AppDatabase _openDatabase(Directory supportRoot) {
  final databasePath = path.join(
    supportRoot.path,
    'database',
    'task8_import.sqlite',
  );
  return AppDatabase(
    driftDatabase(
      name: 'task8_import',
      native: DriftNativeOptions(databasePath: () async => databasePath),
    ),
  );
}

Future<List<PracticeVideo>> _readVideos(Directory supportRoot) async {
  AppMediaPaths(supportRoot);
  final database = _openDatabase(supportRoot);
  try {
    return database.select(database.practiceVideos).get();
  } finally {
    await database.close();
  }
}

Future<String> _seedProcessingTask(Directory supportRoot, File source) async {
  final paths = AppMediaPaths(supportRoot);
  final database = _openDatabase(supportRoot);
  try {
    final tasks = ImportTaskRepository(database);
    final task = await tasks.createPending(_source(source));
    final tempRelativePath = paths.importTempRelativePath(task.id);
    await tasks.transition(
      task.id,
      ImportStatus.copying,
      tempRelativePath: tempRelativePath,
    );
    final temp = File(_absolute(supportRoot, tempRelativePath));
    await temp.parent.create(recursive: true);
    await source.copy(temp.path);
    await tasks.transition(
      task.id,
      ImportStatus.processing,
      tempSizeBytes: await temp.length(),
    );
    return task.id;
  } finally {
    await database.close();
  }
}

Future<File> _writeAsset(String assetPath, File destination) async {
  final data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await destination.writeAsBytes(bytes, flush: true);
  return destination;
}

Future<File> _writeVariant(File source, File destination, int marker) async {
  final bytes = await source.readAsBytes();
  final freeBox = Uint8List.fromList([
    0,
    0,
    0,
    12,
    0x66,
    0x72,
    0x65,
    0x65,
    marker,
    marker,
    marker,
    marker,
  ]);
  await destination.writeAsBytes([...bytes, ...freeBox], flush: true);
  return destination;
}

ImportSource _source(File file) => ImportSource(
  uri: file.path,
  displayName: path.basename(file.path),
  sizeBytes: file.lengthSync(),
  modifiedAt: file.lastModifiedSync().toUtc(),
);

Future<String> _sha256File(File file) async =>
    sha256.bind(file.openRead()).first.then((digest) => digest.toString());

String _absolute(Directory root, String relativePath) =>
    path.join(root.path, relativePath.replaceAll('/', Platform.pathSeparator));

final class _QueuedVideoPickerGateway implements VideoPickerGateway {
  _QueuedVideoPickerGateway(this._batches);

  final List<List<ImportSource>> _batches;
  var _index = 0;

  @override
  Future<List<ImportSource>> pickVideos() async {
    if (_index >= _batches.length) return const [];
    return _batches[_index++];
  }
}
