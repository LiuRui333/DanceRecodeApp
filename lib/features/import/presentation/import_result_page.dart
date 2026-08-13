import 'package:dance_video_diary/features/import/domain/import_models.dart';
import 'package:flutter/material.dart';

class ImportResultPage extends StatelessWidget {
  const ImportResultPage({
    super.key,
    required this.progress,
    required this.onRetry,
    required this.onOpenRecord,
  });

  final ImportProgress progress;
  final Future<void> Function(String taskId) onRetry;
  final Future<void> Function(String videoId) onOpenRecord;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _heading('成功'),
        ..._entries<ImportSuccess>().map(
          (entry) => ListTile(title: Text(entry.displayName)),
        ),
        _heading('重复'),
        ..._entries<ImportDuplicate>().map((entry) {
          final result = entry.result as ImportDuplicate;
          return ListTile(
            title: Text(entry.displayName),
            subtitle: Text(_date(result.recordedAt)),
            trailing: TextButton(
              onPressed: () => onOpenRecord(result.videoId),
              child: const Text('打开记录'),
            ),
          );
        }),
        _heading('失败'),
        ..._entries<ImportFailure>().map((entry) {
          final result = entry.result as ImportFailure;
          return ListTile(
            title: Text(entry.displayName),
            subtitle: Text(localizedImportError(result.errorKind)),
            trailing: TextButton(
              onPressed: () => onRetry(entry.taskId),
              child: const Text('重试'),
            ),
          );
        }),
      ],
    );
  }

  Iterable<ImportResultEntry> _entries<T extends ImportItemResult>() =>
      progress.entries.where((entry) => entry.result is T);

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String localizedImportError(ImportErrorKind kind) => switch (kind) {
  ImportErrorKind.insufficientSpace => '存储空间不足',
  ImportErrorKind.sourceUnavailable => '视频来源已失效',
  ImportErrorKind.unsupportedMedia => '视频不受支持或已损坏',
  ImportErrorKind.io => '存储失败',
  ImportErrorKind.database => '数据库保存失败',
  ImportErrorKind.interrupted => '上次导入被中断',
};
