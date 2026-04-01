import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

String _fileNameFromUrl(String raw) {
  final u = raw.split('?').first;
  final parts = u.split('/');
  final last = parts.isEmpty ? '' : parts.last;
  return last.isEmpty ? 'document' : last;
}

Future<void> downloadAndOpenUrl(
  Dio dio,
  String url, {
  String? fileNameHint,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  final dir = await getTemporaryDirectory();
  final fileName = (fileNameHint?.trim().isNotEmpty == true)
      ? fileNameHint!.trim()
      : _fileNameFromUrl(url);
  final path = '${dir.path}${Platform.pathSeparator}$fileName';

  await dio.download(
    uri.toString(),
    path,
    options: Options(responseType: ResponseType.bytes),
  );

  await OpenFilex.open(path);
}

