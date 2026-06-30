import 'package:equatable/equatable.dart';

class CalendarHoliday extends Equatable {
  const CalendarHoliday({
    required this.id,
    required this.date,
    required this.name,
    this.localName = '',
    this.isHoliday = true,
  });

  final String id;
  final String date;
  final String name;
  final String localName;
  final bool isHoliday;

  String get displayName => name;
  String get subtitleName =>
      localName.trim().isNotEmpty ? localName.trim() : name;

  DateTime? get dateTime => DateTime.tryParse(date);

  factory CalendarHoliday.fromJson(Map<String, dynamic> json) {
    return CalendarHoliday(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Holiday',
      localName: json['local_name']?.toString() ?? '',
      isHoliday: json['is_holiday'] == true,
    );
  }

  @override
  List<Object?> get props => [id, date, name, localName, isHoliday];
}
