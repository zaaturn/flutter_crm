import 'dart:typed_data';

Future<String> saveAssetBytesIo({
  required Uint8List bytes,
  required String filename,
}) async {
  throw UnsupportedError('IO save is not available on web');
}
