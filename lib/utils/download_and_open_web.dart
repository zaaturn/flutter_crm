// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:dio/dio.dart';

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
  // On web, path_provider/open_file aren't available. We download in-browser.
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  final resp = await dio.get<List<int>>(
    uri.toString(),
    options: Options(responseType: ResponseType.bytes),
  );

  final bytes = resp.data;
  if (bytes == null) return;

  final name = (fileNameHint?.trim().isNotEmpty == true)
      ? fileNameHint!.trim()
      : _fileNameFromUrl(url);

  final blob = html.Blob([bytes]);
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);
  final a = html.AnchorElement(href: blobUrl)
    ..download = name
    ..style.display = 'none';
  html.document.body?.append(a);
  a.click();
  a.remove();
  html.Url.revokeObjectUrl(blobUrl);
}

