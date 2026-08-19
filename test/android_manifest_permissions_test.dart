import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const manifestPaths = [
    'android/app/src/main/AndroidManifest.xml',
    'android/app/src/debug/AndroidManifest.xml',
    'android/app/src/profile/AndroidManifest.xml',
  ];
  const prohibitedPermissions = [
    'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE',
    'android.permission.ACCESS_WIFI_STATE',
    'android.permission.CHANGE_NETWORK_STATE',
    'android.permission.CHANGE_WIFI_STATE',
  ];

  test('Android manifests declare no network permissions', () {
    for (final manifestPath in manifestPaths) {
      final manifest = File(manifestPath).readAsStringSync();

      for (final permission in prohibitedPermissions) {
        expect(
          manifest,
          isNot(contains(permission)),
          reason: '$manifestPath must not declare $permission',
        );
      }
    }
  });
}
