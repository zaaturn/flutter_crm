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
    final dateRaw = json['date'] ?? json['holiday_date'];
    DateTime parsedDate;
    if (dateRaw is String && dateRaw.isNotEmpty) {
      parsedDate = DateTime.parse(dateRaw.split('T').first);
    } else if (dateRaw is DateTime) {
      parsedDate = dateRaw;
    } else {
      throw FormatException('Missing holiday date in $json');
    }

    final name = (json['name'] ?? json['title'] ?? 'Holiday').toString();
    final localName = (json['local_name'] ?? json['localName'] ?? '').toString();

    return PublicHoliday(
      date: parsedDate,
      name: name,
      localName: localName,
    );
  }
}

List<PublicHoliday> parsePublicHolidayList(dynamic data) {
  final raw = _extractHolidayRows(data);
  return raw
      .map((e) => PublicHoliday.fromJson(Map<String, dynamic>.from(e)))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

List<Map<String, dynamic>> _extractHolidayRows(dynamic data) {
  if (data is List) {
    return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  if (data is! Map) return [];

  final map = Map<String, dynamic>.from(data);

  for (final key in ['holidays', 'results', 'data', 'items']) {
    final value = map[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }

  return [];
}
