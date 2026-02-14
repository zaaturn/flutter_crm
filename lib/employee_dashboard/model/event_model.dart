class EventModel {
  final String id;
  final String title;
  final String date; // YYYY-MM-DD or custom
  final String time;
  final String location;

  EventModel({required this.id, required this.title, required this.date, required this.time, this.location = ''});

  factory EventModel.fromMap(Map<String, dynamic> m) {
    return EventModel(
      id: m['id']?.toString() ?? '',
      title: m['title'] ?? '',
      date: m['date'] ?? '',
      time: m['time'] ?? '',
      location: m['location'] ?? '',
    );
  }
}
