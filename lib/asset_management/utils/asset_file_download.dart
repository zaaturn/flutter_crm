import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import 'asset_file_saver_io.dart'
    if (dart.library.html) 'asset_file_saver_io_stub.dart';
import 'asset_file_saver_stub.dart'
    if (dart.library.html) 'asset_file_saver_web.dart';

/// Saves asset QR PNGs / label PDFs where the user can actually find them.
///
/// - Web: browser download with the correct MIME type
/// - Mobile/desktop: write under Documents/assets, then Share so the user can
///   Save Image / Save to Files / Downloads
Future<void> downloadAssetFile(
  BuildContext context, {
  required Uint8List bytes,
  required String filename,
}) async {
  if (bytes.isEmpty) {
    throw Exception('Empty file from server — nothing to save');
  }

  final safeName = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  final lower = safeName.toLowerCase();
  final isPng = lower.endsWith('.png');
  final isPdf = lower.endsWith('.pdf');

  if (isPng && !_looksLikePng(bytes)) {
    throw Exception(
      'Server did not return a QR image. Try again or open the asset detail.',
    );
  }
  if (isPdf && !_looksLikePdf(bytes)) {
    throw Exception(
      'Server did not return a PDF label. Try again later.',
    );
  }

  final mime = isPng
      ? 'image/png'
      : isPdf
          ? 'application/pdf'
          : 'application/octet-stream';

  if (kIsWeb) {
    await saveAssetBytesWeb(bytes: bytes, filename: safeName, mimeType: mime);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download started · $safeName'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final path = await saveAssetBytesIo(bytes: bytes, filename: safeName);
  if (!context.mounted) return;

  try {
    await Share.shareXFiles(
      [XFile(path, mimeType: mime, name: safeName)],
      text: isPng ? 'Asset QR · $safeName' : 'Asset label · $safeName',
    );
  } catch (_) {
    final res = await OpenFilex.open(path);
    if (res.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to: $path')),
      );
      return;
    }
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isPng
            ? 'Use the share sheet → Save Image / Files to keep the QR'
            : 'Use the share sheet to save the label PDF',
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

bool _looksLikePng(Uint8List bytes) {
  if (bytes.length < 8) return false;
  return bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47;
}

bool _looksLikePdf(Uint8List bytes) {
  if (bytes.length < 4) return false;
  return bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46;
}
