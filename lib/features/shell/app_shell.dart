import 'package:dance_video_diary/features/import/application/import_providers.dart';
import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:dance_video_diary/features/import/presentation/import_progress_page.dart';
import 'package:dance_video_diary/features/import/presentation/import_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(importControllerProvider.notifier).restore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('练舞日记')),
      body: _body(importState),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: '日历'),
          NavigationDestination(icon: Icon(Icons.video_library), label: '记录'),
          NavigationDestination(icon: Icon(Icons.sell), label: '标签'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  Widget _body(AsyncValue<ImportProgress?> state) {
    final progress = state.value;
    if (state.hasError) {
      return const Center(child: Text('导入失败，请重试'));
    }
    if (progress?.status == ImportStatus.completed) {
      return ImportResultPage(
        progress: progress!,
        onRetry: ref.read(importControllerProvider.notifier).retry,
        onOpenRecord: ref.read(openImportedRecordProvider),
      );
    }
    if (state.isLoading || progress != null) {
      return progress == null
          ? const Center(child: CircularProgressIndicator())
          : ImportProgressPage(progress: progress);
    }
    return Center(
      child: FilledButton(
        onPressed: ref.read(importControllerProvider.notifier).pickAndImport,
        child: const Text('导入视频'),
      ),
    );
  }
}
