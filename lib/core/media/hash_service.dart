import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;

final class HashService {
  Future<String> sha256File(File file) async {
    final digest = await crypto.sha256.bind(file.openRead()).first;
    return digest.toString();
  }
}
