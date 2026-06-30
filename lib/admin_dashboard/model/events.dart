class DashboardEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;

  const DashboardEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  static DashboardEvent? tryFromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) {
      final s = v?.toString();
      if (s == null || s.isEmpty) return null;
      return DateTime.tryParse(s)?.toLocal();
    }

    final start =
        parseDt(json['start_time']) ?? parseDt(json['start']);
    if (start == null) return null;

    final end = parseDt(json['end_time']) ??
        parseDt(json['end']) ??
        start;

    return DashboardEvent(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      start: start,
      end: end,
    );
  }

  factory DashboardEvent.fromJson(Map<String, dynamic> json) {
    final event = tryFromJson(json);
    if (event == null) {
      throw FormatException('Event missing valid start time: ${json['id']}');
    }
    return event;
  }
}
