import '../../../integration_test/import_flow_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'cleanup runs on failure without replacing the original error',
    () async {
      var cleanedUp = false;
      final original = StateError('original failure');

      await expectLater(
        runWithCleanup<void>(
          body: () => Future<void>.error(original),
          cleanup: () async {
            cleanedUp = true;
            throw StateError('cleanup failure');
          },
        ),
        throwsA(same(original)),
      );
      expect(cleanedUp, isTrue);
    },
  );
}
