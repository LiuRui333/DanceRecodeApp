# 练舞视频日记

个人自用、Android、本地优先的练舞视频日记。当前阶段实现视频导入基础设施和导入进度/结果 UI；月历、日期页、记录详情编辑和标签检索留待后续阶段。

## 工具链

- Flutter（项目当前 Dart SDK 约束见 `pubspec.yaml`，建议使用项目验证过的同一稳定版）
- JDK 17
- Android SDK，以及可用于 release 构建的对应 Build Tools/Platform
- Android 实机或模拟器（运行 Android 集成测试和完成人工验收时必需）

先确认工具链：

```powershell
flutter doctor -v
flutter devices --machine
```

## 初始化与代码生成

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

生成的 Drift 文件 `lib/core/database/app_database.g.dart` 属于交付内容，不应遗漏。

## 静态分析与测试

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
```

Android 集成测试使用注入的测试选择器绕过人工系统选择器，但保留真实 Drift、App 私有目录、SHA-256、Android 元数据和缩略图链路：

```powershell
$androidDevice = (flutter devices --machine | ConvertFrom-Json |
  Where-Object { $_.targetPlatform -like 'android*' } |
  Select-Object -First 1).id
flutter test integration_test/import_flow_test.dart -d $androidDevice
```

没有 Android 设备时不得将该测试记为通过，应记为 `NOT RUN`。实机验收记录在 `docs/testing/android-import-checklist.md`。

## 构建 release APK

```powershell
flutter build apk --release
```

默认产物位于 `build/app/outputs/flutter-apk/app-release.apk`。

## 数据与隐私

- 数据库、视频私有副本和缩略图仅保存在本机 App 私有目录。
- 导入流程读取并复制来源视频；不会修改或删除相册、微信等来源文件。
- 相同内容以文件大小和 SHA-256 去重，不创建第二条记录或第二份私有副本。
- 当前实现不包含云同步、网络上传或相册全量读取能力。
