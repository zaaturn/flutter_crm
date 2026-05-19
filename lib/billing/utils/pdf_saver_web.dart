import 'dart:typed_data';
import 'dart:html' as html;

Future<String?> savePdfBytesImpl({
  required Uint8List bytes,
  required String filename,
}) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final a = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';

  html.document.body?.children.add(a);
  a.click();
  a.remove();
  html.Url.revokeObjectUrl(url);
  return null; // no local filesystem path on Web
}

