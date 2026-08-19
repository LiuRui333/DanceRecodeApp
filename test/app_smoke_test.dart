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
