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
    return DashboardEvent(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      start: DateTime.parse(json['start']).toLocal(),
      end: DateTime.parse(json['end']).toLocal(),
    );
  }
}
