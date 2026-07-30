# 练舞视频日记：基础设施与可靠导入实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立可运行的 Android Flutter 应用骨架、可迁移的本地数据库和可恢复的单/批量视频导入链路，为日历、时间线、播放器和备份功能提供稳定的数据与媒体基础。

**Architecture:** 使用 Flutter + Material 3 作为界面基础，Riverpod 注入数据库、文件系统和导入服务。Drift 管理 SQLite；导入协调器把每个来源 URI 作为独立持久化任务处理，依次执行空间预检、临时复制、SHA-256 校验、重复检测、元数据/缩略图提取、原子移动和事务写库。平台插件封装在窄接口之后，使核心状态机可以在纯 Dart/Flutter 测试中验证。

**Tech Stack:** Flutter stable（执行时安装的当前稳定版，需满足 Dart >= 3.10）、Material 3、flutter_riverpod 3.4.1、drift 2.34.3、drift_flutter 0.3.1、image_picker 1.2.3、video_thumbnail 0.5.6、crypto、path、path_provider、uuid、build_runner、drift_dev、flutter_test。

## Global Constraints

- 目标平台仅为 Android；首版界面语言为中文。
- 不申请账户、位置、通讯录或网络上传权限。
- 使用 Android 系统照片选择器读取用户主动选择的视频，不修改相册原文件。
- 导入副本只写入 App 私有目录；数据库仅保存相对路径。
- `recordedAt` 回退顺序固定为：原始拍摄时间、Android 媒体/文件修改时间、导入时间。
- 数据库时间统一保存 UTC；界面层负责转换设备时区。
- 重复视频由文件大小与 SHA-256 共同判定；不得创建第二份文件或第二条记录。
- 批量导入逐条提交；单项失败不得回滚已经成功的其他项。
- 文件复制、摘要、元数据读取和缩略图生成不得阻塞 UI isolate。
- 每段产品代码必须先有能因缺失行为而失败的测试，再写最小实现。
- 本计划只覆盖设计规格第 17 节的第 1 阶段；日历、详情编辑、时间线、标签管理、播放器、回收站与备份恢复分别另写计划。

---

## 文件结构

```text
lib/
  main.dart
  app.dart
  core/
    database/
      app_database.dart
      app_database.g.dart
      converters.dart
      tables.dart
      video_repository.dart
      import_task_repository.dart
    media/
      app_media_paths.dart
      file_gateway.dart
      hash_service.dart
      media_inspector.dart
      thumbnail_service.dart
  features/
    import/
      domain/
        import_models.dart
        import_source.dart
        recorded_at_resolver.dart
      application/
        import_coordinator.dart
        import_recovery_service.dart
        import_providers.dart
      presentation/
        import_progress_page.dart
        import_result_page.dart
    shell/
      app_shell.dart
test/
  core/database/
  core/media/
  features/import/
integration_test/
  import_flow_test.dart
```

边界约定：

- `core/database` 只负责持久化模型、查询与事务，不接触插件 URI。
- `core/media` 只负责私有目录、字节流、摘要、媒体探测和缩略图。
- `features/import/domain` 不依赖 Flutter Widget 或具体插件。
- `features/import/application` 编排接口，不直接调用静态插件 API。
- `features/import/presentation` 只观察 Riverpod 状态并发出用户意图。

---

### Task 1: 安装工具链并创建可测试的 Android 工程

**Files:**
- Create: `pubspec.yaml`
- Create: `analysis_options.yaml`
- Create: `lib/main.dart`
- Create: `lib/app.dart`
- Create: `lib/features/shell/app_shell.dart`
- Create: `test/app_smoke_test.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`

**Interfaces:**
- Produces: `DanceDiaryApp extends StatelessWidget`
- Produces: `AppShell extends StatelessWidget`
- Produces: Android 应用 ID `com.dancediary.app`

- [ ] **Step 1: 安装并验证工具链**

安装 Flutter 当前稳定版及其配套 Android SDK/JDK，把 `flutter` 和 `adb` 加入 PATH。执行：

```powershell
flutter --version
dart --version
java -version
adb version
flutter doctor -v
```

Expected: Flutter stable 可运行，Dart >= 3.10，Android toolchain 和至少一个模拟器或实机可用；`flutter doctor -v` 不得存在会阻止 Android 构建的错误。

- [ ] **Step 2: 创建工程并锁定依赖**

在仓库根目录执行：

```powershell
flutter create --platforms android --org com.dancediary --project-name dance_video_diary .
flutter pub add flutter_riverpod:3.4.1 drift:2.34.3 drift_flutter:0.3.1 image_picker:1.2.3 video_thumbnail:0.5.6 crypto path path_provider uuid
flutter pub add --dev build_runner drift_dev
```

保留 `pubspec.lock` 并提交，确保后续构建使用同一依赖解析结果。`minSdk` 使用 Flutter 当前模板默认值或插件要求的更高值，不手工降低。

- [ ] **Step 3: 写应用壳层失败测试**

创建 `test/app_smoke_test.dart`：

```dart
import 'package:dance_video_diary/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts on calendar shell with an import action', (tester) async {
    await tester.pumpWidget(const DanceDiaryApp());

    expect(find.text('练舞日记'), findsOneWidget);
    expect(find.text('日历'), findsOneWidget);
    expect(find.text('导入视频'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
```

- [ ] **Step 4: 运行测试并确认按预期失败**

Run:

```powershell
flutter test test/app_smoke_test.dart
```

Expected: FAIL，因为 `DanceDiaryApp` 尚不存在。

- [ ] **Step 5: 写最小 Material 3 壳层**

`lib/main.dart`：

```dart
import 'package:dance_video_diary/app.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DanceDiaryApp());
}
```

`lib/app.dart`：

```dart
import 'package:dance_video_diary/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DanceDiaryApp extends StatelessWidget {
  const DanceDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: '练舞日记',
        theme: ThemeData(useMaterial3: true),
        home: const AppShell(),
      ),
    );
  }
}
```

`lib/features/shell/app_shell.dart`：

```dart
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('练舞日记')),
      body: const Center(child: FilledButton(onPressed: null, child: Text('导入视频'))),
      bottomNavigationBar: const NavigationBar(
        selectedIndex: 0,
        destinations: [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: '日历'),
          NavigationDestination(icon: Icon(Icons.video_library), label: '记录'),
          NavigationDestination(icon: Icon(Icons.sell), label: '标签'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: 验证工程**

Run:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/app_smoke_test.dart
flutter build apk --debug
```

Expected: 全部成功，并生成 debug APK。

- [ ] **Step 7: 提交**

```powershell
git add pubspec.yaml pubspec.lock analysis_options.yaml lib test android
git commit -m "chore: scaffold Android dance diary app"
```

---

### Task 2: 定义导入领域模型和日期回退规则

**Files:**
- Create: `lib/features/import/domain/import_models.dart`
- Create: `lib/features/import/domain/import_source.dart`
- Create: `lib/features/import/domain/recorded_at_resolver.dart`
- Create: `test/features/import/recorded_at_resolver_test.dart`
- Create: `test/features/import/import_models_test.dart`

**Interfaces:**
- Produces: `enum ImportStatus { pending, copying, processing, completed, failed }`
- Produces: `enum ImportErrorKind { insufficientSpace, sourceUnavailable, unsupportedMedia, io, database, interrupted }`
- Produces: `ImportSource(uri, displayName, sizeBytes, mediaRecordedAt, modifiedAt)`
- Produces: `DateTime resolveRecordedAt({DateTime? metadataRecordedAt, DateTime? mediaRecordedAt, required DateTime importedAt})`
- Produces: `ImportItemResult.success`, `.duplicate`, `.failure`

- [ ] **Step 1: 写日期回退失败测试**

```dart
import 'package:dance_video_diary/features/import/domain/recorded_at_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final importedAt = DateTime.utc(2026, 7, 30, 8);
  final mediaAt = DateTime.utc(2026, 7, 29, 8);
  final metadataAt = DateTime.utc(2026, 7, 28, 8);

  test('prefers embedded metadata time', () {
    expect(
      resolveRecordedAt(
        metadataRecordedAt: metadataAt,
        mediaRecordedAt: mediaAt,
        importedAt: importedAt,
      ),
      metadataAt,
    );
  });

  test('falls back to media time then import time', () {
    expect(
      resolveRecordedAt(mediaRecordedAt: mediaAt, importedAt: importedAt),
      mediaAt,
    );
    expect(resolveRecordedAt(importedAt: importedAt), importedAt);
  });

  test('normalizes the selected value to UTC', () {
    final local = DateTime(2026, 7, 28, 16);
    expect(
      resolveRecordedAt(metadataRecordedAt: local, importedAt: importedAt).isUtc,
      isTrue,
    );
  });
}
```

- [ ] **Step 2: 运行并确认失败**

Run:

```powershell
flutter test test/features/import/recorded_at_resolver_test.dart
```

Expected: FAIL，因为 resolver 和模型尚不存在。

- [ ] **Step 3: 写最小领域实现**

`recorded_at_resolver.dart`：

```dart
DateTime resolveRecordedAt({
  DateTime? metadataRecordedAt,
  DateTime? mediaRecordedAt,
  required DateTime importedAt,
}) {
  return (metadataRecordedAt ?? mediaRecordedAt ?? importedAt).toUtc();
}
```

在 `import_models.dart` 中定义上述枚举、不可变结果类型和 `ImportProgress`；在 `import_source.dart` 中定义不可变 `ImportSource`，URI 保存为字符串，不把平台 `Uri`/`XFile` 类型泄漏到领域层。

- [ ] **Step 4: 添加状态不变量测试**

验证：

- 成功结果必须包含 `videoId`。
- 重复结果必须包含已有 `videoId` 和 `recordedAt`。
- 失败结果必须包含 `ImportErrorKind` 与可展示消息。
- `ImportProgress.completed + duplicate + failed <= total`。

Run:

```powershell
flutter test test/features/import
```

Expected: PASS。

- [ ] **Step 5: 格式化、分析并提交**

```powershell
dart format lib/features/import/domain test/features/import
flutter analyze
flutter test test/features/import
git add lib/features/import/domain test/features/import
git commit -m "feat: define video import domain"
```

---

### Task 3: 建立 Drift 数据库、约束与仓储

**Files:**
- Create: `lib/core/database/converters.dart`
- Create: `lib/core/database/tables.dart`
- Create: `lib/core/database/app_database.dart`
- Generate: `lib/core/database/app_database.g.dart`
- Create: `lib/core/database/video_repository.dart`
- Create: `lib/core/database/import_task_repository.dart`
- Create: `test/core/database/app_database_test.dart`
- Create: `test/core/database/repositories_test.dart`

**Interfaces:**
- Produces: `AppDatabase(QueryExecutor executor)` 与 `AppDatabase.defaults()`
- Produces: `VideoRepository.findDuplicate({required int sizeBytes, required String sha256})`
- Produces: `VideoRepository.insertImportedVideo(ImportedVideoDraft draft)`
- Produces: `ImportTaskRepository.createPending(ImportSource source)`
- Produces: `ImportTaskRepository.transition(String taskId, ImportStatus next, {double? progress, ImportErrorKind? errorKind, String? errorMessage, String? videoId, String? tempRelativePath})`
- Produces: `ImportTaskRepository.listRecoverable()`

- [ ] **Step 1: 写数据库结构失败测试**

使用 `NativeDatabase.memory()` 创建测试库，断言：

```dart
test('stores one practice video and rejects duplicate relative paths', () async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);

  await db.into(db.practiceVideos).insert(testVideo(id: 'v1', path: 'media/videos/v1.mp4'));

  expect(
    () => db.into(db.practiceVideos).insert(testVideo(id: 'v2', path: 'media/videos/v1.mp4')),
    throwsA(isA<SqliteException>()),
  );
});
```

另写测试验证：

- `role` 默认为 `practice`。
- `relative_path` 唯一。
- `video_id + tag_id` 联合主键阻止重复关联。
- `normalized_name` 唯一。
- 删除标签级联删除关联但不删除视频。
- `recorded_at`、`file_hash`、`is_favorite`、`deleted_at` 存在索引。
- `schemaVersion == 1`。

- [ ] **Step 2: 运行并确认失败**

Run:

```powershell
flutter test test/core/database/app_database_test.dart
```

Expected: FAIL，因为数据库类不存在。

- [ ] **Step 3: 实现表结构**

在 `tables.dart` 定义：

- `PracticeVideos`：完整实现规格第 7.1 节全部字段。
- `Tags`：完整实现规格第 7.2 节全部字段。
- `VideoTags`：联合主键与两个级联外键。
- `AppSettings`：`key`、`value`、`valueType`、`schemaVersion`。
- `ImportTasks`：`id`、来源 URI、显示名、临时相对路径、状态、进度、错误类型/消息、视频 ID、创建/更新时间。

`app_database.dart` 明确声明 `schemaVersion => 1`，默认连接通过 `driftDatabase(name: 'dance_diary')` 打开。测试构造函数必须允许注入内存 executor。

- [ ] **Step 4: 生成代码并通过结构测试**

Run:

```powershell
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/database/app_database_test.dart
```

Expected: PASS。

- [ ] **Step 5: 写仓储失败测试**

测试真实数据库行为：

```dart
test('findDuplicate requires matching size and hash', () async {
  await videos.insertImportedVideo(testDraft(id: 'v1', sizeBytes: 10, sha256: 'abc'));

  expect(await videos.findDuplicate(sizeBytes: 10, sha256: 'abc'), isNotNull);
  expect(await videos.findDuplicate(sizeBytes: 11, sha256: 'abc'), isNull);
  expect(await videos.findDuplicate(sizeBytes: 10, sha256: 'def'), isNull);
});
```

另验证导入任务只允许：

```text
pending -> copying -> processing -> completed
pending/copying/processing -> failed
failed -> pending
```

非法跃迁抛出 `StateError`，`listRecoverable()` 只返回 `pending/copying/processing`。

- [ ] **Step 6: 实现仓储并运行全部数据库测试**

使用数据库事务实现 `insertImportedVideo`；同时插入视频记录和初始标签关联时必须全成或全败。

Run:

```powershell
dart format lib/core/database test/core/database
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test test/core/database
```

Expected: PASS。

- [ ] **Step 7: 提交**

```powershell
git add lib/core/database test/core/database
git commit -m "feat: add local video database"
```

---

### Task 4: 实现私有媒体目录、流式摘要和原子文件提交

**Files:**
- Create: `lib/core/media/app_media_paths.dart`
- Create: `lib/core/media/file_gateway.dart`
- Create: `lib/core/media/hash_service.dart`
- Create: `test/core/media/app_media_paths_test.dart`
- Create: `test/core/media/file_gateway_test.dart`
- Create: `test/core/media/hash_service_test.dart`

**Interfaces:**
- Produces: `AppMediaPaths(rootDirectory)`
- Produces: `String videoRelativePath(String videoId, String? safeExtension)`
- Produces: `String thumbnailRelativePath(String videoId)`
- Produces: `Future<CopyResult> FileGateway.copySourceToTemp({required Stream<List<int>> source, required int? expectedBytes, required File destination, required void Function(int copiedBytes) onProgress})`
- Produces: `Future<void> FileGateway.commitTempFile({required File temporaryFile, required File destination})`
- Produces: `Future<String> HashService.sha256File(File file)`

- [ ] **Step 1: 写路径与安全扩展名失败测试**

验证固定布局：

```dart
expect(paths.videoRelativePath('abc', '.MP4'), 'media/videos/abc.mp4');
expect(paths.videoRelativePath('abc', '../mp4'), 'media/videos/abc');
expect(paths.thumbnailRelativePath('abc'), 'media/thumbnails/abc.jpg');
expect(paths.importTempRelativePath('task-1'), 'temp/imports/task-1/source');
```

所有绝对路径必须经 `path.isWithin(root, resolved)` 验证，任何逃逸根目录的输入抛出 `ArgumentError`。

- [ ] **Step 2: 运行并确认失败**

Run:

```powershell
flutter test test/core/media/app_media_paths_test.dart
```

Expected: FAIL，因为路径服务不存在。

- [ ] **Step 3: 实现路径服务**

`AppMediaPaths` 负责创建 `media/videos`、`media/thumbnails`、`temp/imports`、`database`；只向数据库消费者返回 POSIX 风格相对路径，文件访问时再解析为当前平台绝对路径。

- [ ] **Step 4: 写摘要与复制失败测试**

使用临时目录和确定字节：

```dart
test('hashes file content with sha256', () async {
  final file = File(p.join(temp.path, 'sample.bin'));
  await file.writeAsBytes([97, 98, 99]);
  expect(await HashService().sha256File(file),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
});
```

复制测试必须验证：

- 以 stream 分块读取，而不是一次载入全部字节。
- 报告已复制字节数。
- 目标临时文件大小与来源一致。
- 来源读取异常时删除不完整临时文件。
- `commitTempFile` 只允许从 `temp/imports` 移动到 `media/videos`，目标已存在时失败且不覆盖。

- [ ] **Step 5: 实现并验证媒体基础服务**

摘要计算使用 `crypto.sha256.bind(file.openRead())`。可能消耗 CPU 的大文件处理通过独立 isolate 或异步流执行，不在 UI build 回调中运行。

Run:

```powershell
dart format lib/core/media test/core/media
flutter analyze
flutter test test/core/media
```

Expected: PASS。

- [ ] **Step 6: 提交**

```powershell
git add lib/core/media test/core/media
git commit -m "feat: add private media storage services"
```

---

### Task 5: 封装系统视频选择、元数据和缩略图适配器

**Files:**
- Create: `lib/features/import/domain/import_source.dart`
- Create: `lib/features/import/application/video_picker_gateway.dart`
- Create: `lib/core/media/media_inspector.dart`
- Create: `lib/core/media/thumbnail_service.dart`
- Create: `test/features/import/video_picker_gateway_test.dart`
- Create: `test/core/media/media_inspector_test.dart`
- Create: `test/core/media/thumbnail_service_test.dart`

**Interfaces:**
- Produces: `abstract interface class VideoPickerGateway { Future<List<ImportSource>> pickVideos(); }`
- Produces: `ImagePickerVideoPickerGateway`
- Produces: `abstract interface class MediaInspector { Future<MediaMetadata> inspect(String absolutePath); }`
- Produces: `MediaMetadata(durationMs, width, height, metadataRecordedAt)`
- Produces: `abstract interface class ThumbnailService { Future<String?> generate({required String videoAbsolutePath, required String outputAbsolutePath, int maxWidth = 512}); }`

- [ ] **Step 1: 写选择器映射失败测试**

把插件调用隔离在可注入函数之后，测试：

- 用户取消返回空列表，不视为错误。
- `pickMultipleMedia()` 结果只保留视频 MIME/扩展名。
- 每个结果映射显示名、来源 URI/路径和可用文件大小。
- Android Activity 被系统回收后，通过插件的 lost-data 恢复入口重新构造来源列表。

Run:

```powershell
flutter test test/features/import/video_picker_gateway_test.dart
```

Expected: FAIL，因为 gateway 尚不存在。

- [ ] **Step 2: 实现系统选择器适配器**

使用 `image_picker` 的多媒体系统选择能力，界面入口文案仍为“选择视频”。不申请广泛相册读取权限；只读取选择器返回的项目。若插件不能对特定 Android 版本提供多选视频，则保留 `VideoPickerGateway` 接口并在该实现内使用 Android SAF MethodChannel，不改变应用层。

- [ ] **Step 3: 写媒体探测与缩略图失败测试**

测试接口级行为：

- 探测成功返回时长、宽高和可选拍摄时间。
- 探测器抛出不支持错误时协调器仍可保留已安全复制的文件。
- 缩略图固定输出 JPEG 相对路径，最长边不超过 512 px。
- 生成失败返回 `null` 并保留可重试信息，不删除视频。

原生插件用 fake adapter 测应用契约；实际插件行为留给 Task 8 的 Android 集成测试。

- [ ] **Step 4: 实现适配器并验证**

`video_thumbnail` 调用只存在于 `ThumbnailService` 的 Android 实现中。元数据提取若 `image_picker` 不提供时长/宽高/拍摄时间，新增最小 Android MethodChannel，使用 `MediaMetadataRetriever`，并为 channel handler 写 Android 单元测试。

Run:

```powershell
dart format lib test
flutter analyze
flutter test test/features/import/video_picker_gateway_test.dart test/core/media
```

Expected: PASS。

- [ ] **Step 5: 提交**

```powershell
git add lib android test
git commit -m "feat: adapt Android video media services"
```

---

### Task 6: 用持久化状态机实现可靠导入协调器

**Files:**
- Create: `lib/features/import/application/import_coordinator.dart`
- Create: `lib/features/import/application/import_recovery_service.dart`
- Create: `test/features/import/import_coordinator_test.dart`
- Create: `test/features/import/import_recovery_service_test.dart`

**Interfaces:**
- Consumes: Task 2 的领域模型
- Consumes: Task 3 的 `VideoRepository`、`ImportTaskRepository`
- Consumes: Task 4 的 `FileGateway`、`HashService`、`AppMediaPaths`
- Consumes: Task 5 的 `MediaInspector`、`ThumbnailService`
- Produces: `Stream<ImportProgress> ImportCoordinator.import(List<ImportSource> sources)`
- Produces: `Future<ImportItemResult> ImportCoordinator.retry(String taskId)`
- Produces: `Future<RecoverySummary> ImportRecoveryService.recoverInterrupted()`

- [ ] **Step 1: 写成功导入失败测试**

用内存数据库、临时目录和 fake 平台适配器执行真实协调器，断言顺序：

```text
create pending task
check available bytes
transition copying
copy to task temp directory
verify byte count and calculate SHA-256
transition processing
check duplicate
inspect metadata
generate thumbnail
atomically move video
transactionally insert video
transition completed
```

最终断言正式媒体文件、视频记录和 completed 任务都存在，临时目录不存在。

- [ ] **Step 2: 运行并确认失败**

Run:

```powershell
flutter test test/features/import/import_coordinator_test.dart
```

Expected: FAIL，因为协调器不存在。

- [ ] **Step 3: 实现最小成功路径**

视频 ID 和任务 ID 使用 UUID v4。空间预检至少要求 `sourceSize + max(64 MiB, sourceSize * 5%)` 可用；来源无法报告大小时先复制到临时目录，并在到达安全上限或写入失败时返回明确错误。

数据库写入失败时：

- 不留下正式媒体文件。
- 回滚数据库事务。
- 清理该任务临时文件。
- 任务标记为 `failed/database`。

- [ ] **Step 4: 写重复和部分失败测试**

测试：

- 同大小同摘要：不调用元数据、缩略图和正式移动；返回已有视频 ID/日期。
- 同文件名不同摘要：创建独立记录。
- 批量三项中第二项失败：第一、第三项成功，结果为 2 成功、1 失败。
- 缩略图失败：视频仍导入成功，`thumbnailPath == null`。
- 不支持的媒体：文件可安全复制时保留记录并标记媒体检查错误；无法安全复制时失败。

- [ ] **Step 5: 写恢复失败测试**

重启恢复规则：

- `pending`：重新入队。
- `copying` 且临时文件不完整：删除临时文件并重新入队。
- `processing` 且临时文件完整：从摘要/重复检测继续。
- 任务已有 `videoId` 且记录存在：幂等地标记 completed。
- 任务与临时目录均无法继续：标记 `failed/interrupted`。
- 清理不属于任何活跃任务且超过 24 小时的临时目录。

- [ ] **Step 6: 实现错误路径、恢复和完整测试**

每种失败映射到稳定的 `ImportErrorKind`，日志可以保存技术信息，但中文 UI 消息不得包含绝对私有路径。

Run:

```powershell
dart format lib/features/import/application test/features/import
flutter analyze
flutter test test/features/import
flutter test test/core
```

Expected: PASS。

- [ ] **Step 7: 提交**

```powershell
git add lib/features/import/application test/features/import
git commit -m "feat: implement recoverable video imports"
```

---

### Task 7: 接入 Riverpod 导入进度与结果界面

**Files:**
- Create: `lib/features/import/application/import_providers.dart`
- Create: `lib/features/import/presentation/import_progress_page.dart`
- Create: `lib/features/import/presentation/import_result_page.dart`
- Modify: `lib/features/shell/app_shell.dart`
- Modify: `lib/app.dart`
- Create: `test/features/import/import_progress_page_test.dart`
- Create: `test/features/import/import_result_page_test.dart`

**Interfaces:**
- Produces: `importControllerProvider`
- Produces: `ImportController.pickAndImport()`
- Consumes: `VideoPickerGateway`, `ImportCoordinator`

- [ ] **Step 1: 写界面失败测试**

覆盖：

- 点击“导入视频”调用一次选择器。
- 取消选择保持当前页且不显示错误。
- 进度页显示“3 个中的第 2 个”、当前文件名、成功/重复/失败计数。
- 导入期间禁用重复启动按钮。
- 完成页分别列出成功、重复、失败项目。
- 重复项显示已有记录日期和“打开记录”动作。
- 失败项显示原因和“重试”动作。

Run:

```powershell
flutter test test/features/import/import_progress_page_test.dart test/features/import/import_result_page_test.dart
```

Expected: FAIL，因为 provider 和页面不存在。

- [ ] **Step 2: 实现最小 Riverpod 控制器**

使用 `AsyncNotifier` 管理选择、导入和重试；平台服务通过 provider 注入，Widget 测试覆盖 fake。页面不得直接访问 SQLite、文件路径或静态插件 API。

- [ ] **Step 3: 实现进度与结果页面**

离开进度页面不取消持久化任务；应用回前台时从任务仓储恢复当前状态。错误文案至少区分：

- 空间不足
- 来源已失效
- 视频不受支持或损坏
- 存储失败
- 数据库失败
- 上次导入被中断

- [ ] **Step 4: 验证界面和回归**

Run:

```powershell
dart format lib test
flutter analyze
flutter test
```

Expected: 全部 PASS，且无 analyzer warning。

- [ ] **Step 5: 提交**

```powershell
git add lib test
git commit -m "feat: add video import workflow UI"
```

---

### Task 8: Android 集成验证与阶段交付

**Files:**
- Create: `integration_test/import_flow_test.dart`
- Create: `docs/testing/android-import-checklist.md`
- Modify: `README.md`

**Interfaces:**
- Validates: 从系统照片选择器到私有媒体、SQLite 和结果页的完整链路

- [ ] **Step 1: 写集成测试**

在可控测试 fixture 下验证：

1. 导入单个短 MP4。
2. 再次导入相同文件得到 duplicate。
3. 批量导入两个不同文件。
4. 强制终止并重启后恢复 processing 任务。
5. 确认原始 fixture 文件未修改。

集成测试通过注入测试选择器绕过人工系统 UI，但使用真实 Drift 数据库、真实私有目录、真实摘要、真实元数据和缩略图插件。

- [ ] **Step 2: 运行自动化验证**

Run:

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
$taskAndroidDevice = (flutter devices --machine | ConvertFrom-Json | Where-Object { $_.targetPlatform -like 'android*' } | Select-Object -First 1).id
flutter test integration_test/import_flow_test.dart -d $taskAndroidDevice
flutter build apk --release
```

Expected: `$taskAndroidDevice` 非空，所有测试通过并生成 release APK。

- [ ] **Step 3: 完成实机人工验收**

在 `docs/testing/android-import-checklist.md` 逐项记录设备型号、Android 版本、结果和证据：

- 相机拍摄视频、微信保存视频各至少 1 个。
- 横屏、竖屏和不同分辨率视频。
- 一次选择 20 个以上视频，App 无崩溃，进度持续更新。
- 重复文件不产生第二份 App 私有副本。
- 导入中途强制停止 App，重启后恢复或明确失败。
- 模拟空间不足时在复制前拦截。
- 冷启动后数据库记录和媒体文件一致。
- App 不申请相册全量读取、位置、联系人或网络上传权限。

- [ ] **Step 4: 更新 README**

写明：

- 工具链要求。
- `flutter pub get`、代码生成、测试和 APK 构建命令。
- 数据只存本机、原相册文件不受影响。
- 当前完成范围仅为基础设施与导入；其余页面按后续计划实现。

- [ ] **Step 5: 最终验证并提交**

```powershell
flutter doctor -v
flutter analyze
flutter test
flutter build apk --release
git status --short
git add integration_test docs/testing README.md
git commit -m "test: verify Android import foundation"
```

Expected: doctor 无阻塞 Android 构建的问题，静态分析和测试全绿，release APK 构建成功，提交后工作树干净。

---

## 第一阶段完成定义

只有同时满足以下条件，才可开始“月历、日期页和基础详情编辑”计划：

- release APK 可在目标 Android 实机安装和冷启动。
- 单个与批量导入能够生成持久化记录和 App 私有媒体副本。
- 同内容重复导入不会创建重复记录或文件。
- 导入中断后能够恢复或以明确、可重试的状态结束。
- 数据库 schema v1、约束、索引和仓储测试全部通过。
- 自动化测试、20+ 视频实机导入和隐私权限检查通过。
- Git 工作树干净，`pubspec.lock`、生成的 Drift 文件和验收记录均已提交。
