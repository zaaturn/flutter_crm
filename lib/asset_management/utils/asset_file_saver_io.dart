import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String> saveAssetBytesIo({
  required Uint8List bytes,
  required String filename,
}) async {
  final safeName = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

  Directory base;
  if (Platform.isAndroid) {
    base = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
  } else {
    base = await getApplicationDocumentsDirectory();
  }

  final dir = Directory('${base.path}/assets');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final file = File('${dir.path}/$safeName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
