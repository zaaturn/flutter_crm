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

  factory DashboardEvent.fromJson(Map<String, dynamic> json) {
    DateTime parseDt(dynamic v) {
      final s = v?.toString();
      if (s == null || s.isEmpty) return DateTime.now();
      return DateTime.tryParse(s)?.toLocal() ?? DateTime.now();
    }
    return DashboardEvent(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      start: parseDt(json['start']),
      end: parseDt(json['end']),
    );
  }
}
