import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String?> savePdfBytesImpl({
  required Uint8List bytes,
  required String filename,
}) async {
  final safeName = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

  // Prefer a user-visible, persistent location on Android (app-specific external).
  // This avoids runtime storage permission prompts and works with scoped storage.
  final Directory dir;
  if (Platform.isAndroid) {
    final ext = await getExternalStorageDirectory();
    dir = ext ?? await getApplicationDocumentsDirectory();
  } else {
    dir = await getApplicationDocumentsDirectory();
  }

  final invoicesDir = Directory('${dir.path}/invoices');
  if (!await invoicesDir.exists()) {
    await invoicesDir.create(recursive: true);
  }

  final file = File('${invoicesDir.path}/$safeName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

