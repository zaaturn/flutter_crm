import 'package:my_app/dashboards/widgets/post_media_utils.dart';
import 'package:my_app/services/api_client.dart';

class PostAttachment {
  final int id;
  final String file;
  final String fileType;

  PostAttachment({
    required this.id,
    required this.file,
    required this.fileType,
  });

  String get resolvedUrl => resolvePostAttachmentUrl(
        file,
        baseUrl: ApiClient().dio.options.baseUrl,
      );

  factory PostAttachment.fromJson(Map<String, dynamic> json) {
    final rawFile = (json['file'] ??
            json['file_url'] ??
            json['url'] ??
            json['attachment'] ??
            '')
        .toString();
    final rawType = (json['file_type'] ??
            json['fileType'] ??
            json['mime_type'] ??
            json['content_type'] ??
            '')
        .toString();

    return PostAttachment(
      id: _parseId(json['id']),
      file: rawFile,
      fileType: rawType.isNotEmpty ? rawType : _inferFileType(rawFile),
    );
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}

String _inferFileType(String file) {
  final u = file.toLowerCase().split('?').first;
  if (u.endsWith('.png') ||
      u.endsWith('.jpg') ||
      u.endsWith('.jpeg') ||
      u.endsWith('.webp') ||
      u.endsWith('.gif')) {
    return 'image';
  }
  if (u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.webm')) {
    return 'video';
  }
  if (u.endsWith('.pdf')) return 'application/pdf';
  return 'file';
}

List<PostAttachment> parsePostAttachments(dynamic raw) {
  if (raw is! List) return const [];
  final out = <PostAttachment>[];
  for (final item in raw) {
    if (item is! Map) continue;
    try {
      out.add(
        PostAttachment.fromJson(
          Map<String, dynamic>.from(item),
        ),
      );
    } catch (_) {}
  }
  return out;
}
