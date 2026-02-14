class PublicHoliday {
  final DateTime date;
  final String name;
  final String localName;

  PublicHoliday({
    required this.date,
    required this.name,
    required this.localName,
  });

  factory PublicHoliday.fromJson(Map<String, dynamic> json) {
    return PublicHoliday(
      date: DateTime.parse(json['date']),
      name: json['name'],
      localName: json['local_name'] ?? "",
    );
  }
}
