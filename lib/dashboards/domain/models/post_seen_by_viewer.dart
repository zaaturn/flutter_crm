class PostSeenByViewer {
  final String fullName;
  final String? phone;
  final DateTime? readAt;

  const PostSeenByViewer({
    required this.fullName,
    this.phone,
    this.readAt,
  });

  factory PostSeenByViewer.fromJson(Map<String, dynamic> json) {
    final name = (json['full_name'] ??
            json['viewer_full_name'] ??
            json['user_full_name'] ??
            json['name'] ??
            json['username'] ??
            'User')
        .toString()
        .trim();
    final phone = (json['phone'] ??
            json['phone_number'] ??
            json['mobile'] ??
            json['contact_number'])
        ?.toString()
        .trim();
    final raw = (json['read_at'] ??
            json['seen_at'] ??
            json['viewed_at'] ??
            json['created_at'])
        ?.toString();
    return PostSeenByViewer(
      fullName: name.isEmpty ? 'User' : name,
      phone: phone != null && phone.isNotEmpty ? phone : null,
      readAt: raw == null || raw.isEmpty ? null : DateTime.tryParse(raw),
    );
  }
}

Map<String, dynamic> flattenSeenByRow(Map<dynamic, dynamic> raw) {
  final m = Map<String, dynamic>.from(raw);
  final nested = m['user'] ?? m['employee'] ?? m['viewer'] ?? m['profile'];
  if (nested is Map) {
    final u = Map<String, dynamic>.from(nested);
    m.putIfAbsent('full_name', () => u['full_name'] ?? u['name']);
    m.putIfAbsent('username', () => u['username']);
    m.putIfAbsent('phone', () => u['phone'] ?? u['phone_number'] ?? u['mobile']);
  }
  return m;
}

List<dynamic> extractSeenByRows(dynamic data) {
  if (data is List) return data;
  if (data is! Map) return [];

  final map = Map<String, dynamic>.from(data);
  for (final key in [
    'results',
    'seen_by',
    'viewers',
    'users',
    'data',
    'items',
  ]) {
    final value = map[key];
    if (value is List) return value;
  }
  return [];
}

List<PostSeenByViewer> parsePostSeenByResponse(dynamic data) {
  return extractSeenByRows(data)
      .whereType<Map>()
      .map((e) => PostSeenByViewer.fromJson(flattenSeenByRow(e)))
      .toList();
}

String formatPostViewTimeAgo(DateTime? at) {
  if (at == null) return '';
  final d = DateTime.now().difference(at.toLocal());
  if (d.inMinutes < 1) return 'Just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  return '${at.toLocal().day}/${at.toLocal().month}/${at.toLocal().year}';
}
