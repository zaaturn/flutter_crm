import 'package:dio/dio.dart';
import 'download_and_open_io.dart' if (dart.library.html) 'download_and_open_web.dart'
    as impl;

/// Download a remote file and open it with the OS.
///
/// - On IO platforms (Android/iOS/Windows/macOS/Linux): downloads to temp dir and opens locally.
/// - On Web: triggers a browser download (cannot "open locally" automatically).
Future<void> downloadAndOpenUrl(
  Dio dio,
  String url, {
  String? fileNameHint,
}) {
  return impl.downloadAndOpenUrl(dio, url, fileNameHint: fileNameHint);
}

