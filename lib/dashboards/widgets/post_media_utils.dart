import 'package:my_app/dashboards/domain/models/post_attachment.dart';

bool postAttachmentIsImage(PostAttachment attachment) {
  return postAttachmentIsImageUrl(attachment.fileType, attachment.file);
}

bool postAttachmentIsVideo(PostAttachment attachment) {
  return postAttachmentIsVideoUrl(attachment.fileType, attachment.file);
}

bool postAttachmentIsImageUrl(String fileType, String url) {
  final ft = fileType.toLowerCase();
  if (ft.contains('image')) return true;
  final u = url.toLowerCase().split('?').first;
  return u.endsWith('.png') ||
      u.endsWith('.jpg') ||
      u.endsWith('.jpeg') ||
      u.endsWith('.webp') ||
      u.endsWith('.gif');
}

bool postAttachmentIsVideoUrl(String fileType, String url) {
  final ft = fileType.toLowerCase();
  if (ft.contains('video')) return true;
  final u = url.toLowerCase().split('?').first;
  return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.webm');
}

String resolvePostAttachmentUrl(String file, {String? baseUrl}) {
  final raw = file.trim();
  if (raw.isEmpty) return raw;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  if (baseUrl == null || baseUrl.isEmpty) return raw;
  final root = baseUrl.replaceAll(RegExp(r'/+$'), '');
  if (raw.startsWith('/')) return '$root$raw';
  return '$root/$raw';
}
