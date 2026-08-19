import 'package:image_picker/image_picker.dart';

import '../domain/import_source.dart';

abstract interface class VideoPickerGateway {
  Future<List<ImportSource>> pickVideos();
}

enum VideoPickerFailureCode { lostDataRecoveryFailed }

final class VideoPickerException implements Exception {
  const VideoPickerException(this.code);

  final VideoPickerFailureCode code;
}

final class PickerFile {
  const PickerFile({
    required this.path,
    required this.name,
    this.mimeType,
    this.sizeBytes,
    this.mediaRecordedAt,
    this.modifiedAt,
  });

  final String path;
  final String name;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime? mediaRecordedAt;
  final DateTime? modifiedAt;
}

final class PickerRecovery {
  const PickerRecovery({this.files = const [], this.failed = false});

  final List<PickerFile> files;
  final bool failed;
}

abstract interface class VideoPickerClient {
  Future<PickerRecovery> recoverLostData();

  Future<List<PickerFile>> pickMultipleMedia();
}

final class ImagePickerVideoPickerGateway implements VideoPickerGateway {
  ImagePickerVideoPickerGateway({
    VideoPickerClient? client,
    DateTime Function()? now,
  }) : _client = client ?? ImagePickerVideoPickerClient(),
       _now = now ?? DateTime.now;

  static const _videoExtensions = {'3gp', 'm4v', 'mkv', 'mov', 'mp4', 'webm'};

  final VideoPickerClient _client;
  final DateTime Function() _now;

  @override
  Future<List<ImportSource>> pickVideos() async {
    final recovery = await _client.recoverLostData();
    if (recovery.failed) {
      throw const VideoPickerException(
        VideoPickerFailureCode.lostDataRecoveryFailed,
      );
    }

    final recoveredVideos = _mapVideos(recovery.files);
    if (recoveredVideos.isNotEmpty) {
      return recoveredVideos;
    }

    return _mapVideos(await _client.pickMultipleMedia());
  }

  List<ImportSource> _mapVideos(List<PickerFile> files) {
    final fallbackTime = _now().toUtc();
    return files
        .where(_isVideo)
        .map(
          (file) => ImportSource(
            uri: file.path,
            displayName: file.name,
            sizeBytes: file.sizeBytes ?? -1,
            mediaRecordedAt: file.mediaRecordedAt?.toUtc(),
            modifiedAt: file.modifiedAt?.toUtc() ?? fallbackTime,
          ),
        )
        .toList(growable: false);
  }

  bool _isVideo(PickerFile file) {
    final mimeType = file.mimeType?.trim().toLowerCase();
    if (mimeType != null && mimeType.isNotEmpty) {
      return mimeType.startsWith('video/');
    }

    final dotIndex = file.name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == file.name.length - 1) {
      return false;
    }
    return _videoExtensions.contains(
      file.name.substring(dotIndex + 1).toLowerCase(),
    );
  }
}

final class ImagePickerVideoPickerClient implements VideoPickerClient {
  ImagePickerVideoPickerClient({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<List<PickerFile>> pickMultipleMedia() async {
    final files = await _picker.pickMultipleMedia(requestFullMetadata: false);
    return Future.wait(files.map(_toPickerFile));
  }

  @override
  Future<PickerRecovery> recoverLostData() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.exception != null) {
        return const PickerRecovery(failed: true);
      }

      final files =
          response.files ?? [if (response.file != null) response.file!];
      return PickerRecovery(files: await Future.wait(files.map(_toPickerFile)));
    } catch (_) {
      return const PickerRecovery(failed: true);
    }
  }

  Future<PickerFile> _toPickerFile(XFile file) async {
    int? sizeBytes;
    DateTime? modifiedAt;
    try {
      sizeBytes = await file.length();
    } catch (_) {
      sizeBytes = null;
    }
    try {
      modifiedAt = await file.lastModified();
    } catch (_) {
      modifiedAt = null;
    }

    return PickerFile(
      path: file.path,
      name: file.name,
      mimeType: file.mimeType,
      sizeBytes: sizeBytes,
      modifiedAt: modifiedAt,
    );
  }
}
