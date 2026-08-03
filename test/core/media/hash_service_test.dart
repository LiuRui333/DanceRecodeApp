import 'dart:io';

import 'package:dance_video_diary/core/media/hash_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HashService', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('dance-video-hash-service-');
    });

    tearDown(() async {
      await root.delete(recursive: true);
    });

    test(
      'returns the SHA-256 digest of a file without changing the file',
      () async {
        final file = File('${root.path}${Platform.pathSeparator}source.bin');
        await file.writeAsBytes(const <int>[97, 98, 99]);

        final digest = await HashService().sha256File(file);

        expect(
          digest,
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
        );
        expect(await file.readAsBytes(), <int>[97, 98, 99]);
      },
    );
  });
}
