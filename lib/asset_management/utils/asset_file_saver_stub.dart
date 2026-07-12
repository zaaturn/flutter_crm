import 'dart:typed_data';

/// Non-web stub — unused; IO path uses [savePdfBytes] instead.
Future<void> saveAssetBytesWeb({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) async {
  throw UnsupportedError('Web download is only available on web');
}
