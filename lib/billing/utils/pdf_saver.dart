import 'dart:typed_data';

// Conditional import: web implementation uses `dart:html`.
import 'pdf_saver_stub.dart'
    if (dart.library.html) 'pdf_saver_web.dart';

/// Save/open a PDF represented by [bytes].
///
/// - On Web: triggers a browser download.
/// - On Mobile/Desktop: saves to temp/documents and returns a local path.
Future<String?> savePdfBytes({
  required Uint8List bytes,
  required String filename,
}) {
  return savePdfBytesImpl(bytes: bytes, filename: filename);
}

