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
