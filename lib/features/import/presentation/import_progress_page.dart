import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:flutter/material.dart';

class ImportProgressPage extends StatelessWidget {
  const ImportProgressPage({super.key, required this.progress});

  final ImportProgress progress;

  @override
  Widget build(BuildContext context) {
    final terminal = progress.completed + progress.duplicate + progress.failed;
    final current = (terminal + 1).clamp(1, progress.total);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('${progress.total} 个中的第 $current 个'),
            if (progress.currentFileName != null)
              Text(progress.currentFileName!),
            const SizedBox(height: 16),
            Text('成功 ${progress.completed}'),
            Text('重复 ${progress.duplicate}'),
            Text('失败 ${progress.failed}'),
          ],
        ),
      ),
    );
  }
}
