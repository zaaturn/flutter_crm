import 'package:intl/intl.dart';

class PublicHoliday {
  final DateTime date;
  final String name;
  final String localName;
  final String day;
  final bool isHoliday;

  PublicHoliday({
    required this.date,
    required this.name,
    this.localName = '',
    this.day = '',
    this.isHoliday = true,
  });

  String get weekdayLabel {
    if (day.trim().isNotEmpty) return day.trim();
    return DateFormat('EEEE').format(date);
  }

  /// e.g. "14 Jan · Wednesday · Makara Sankranti"
  String get listLabel {
    final datePart = DateFormat('d MMM').format(date);
    return '$datePart · $weekdayLabel · $name';
  }

  factory PublicHoliday.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['date'] ??
        json['holiday_date'] ??
        json['holidayDate'] ??
        json['day_date'];
    DateTime parsedDate;
    if (dateRaw is String && dateRaw.isNotEmpty) {
      parsedDate = _parseHolidayDate(dateRaw);
    } else if (dateRaw is DateTime) {
      parsedDate = dateRaw;
    } else {
      throw FormatException('Missing holiday date in $json');
    }

    final name = (json['name'] ??
            json['title'] ??
            json['holiday_name'] ??
            json['holidayName'] ??
            'Holiday')
        .toString();
    final localName = (json['local_name'] ??
            json['localName'] ??
            json['local_title'] ??
            '')
        .toString();
    final day = (json['day'] ?? json['weekday'] ?? '').toString();
    final isHoliday = _parseIsHoliday(json['is_holiday'] ?? json['isHoliday']);

    return PublicHoliday(
      date: parsedDate,
      name: name,
      localName: localName,
      day: day,
      isHoliday: isHoliday,
    );
  }
}

DateTime _parseHolidayDate(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    throw const FormatException('Empty holiday date');
  }
  final dateOnly = value.split('T').first.split(' ').first;
  final parsed = DateTime.tryParse(dateOnly);
  if (parsed != null) return parsed;

  for (final pattern in ['dd-MM-yyyy', 'dd/MM/yyyy', 'MM/dd/yyyy']) {
    try {
      return DateFormat(pattern).parseStrict(dateOnly);
    } catch (_) {}
  }

  throw FormatException('Unrecognized holiday date: $raw');
}

bool _parseIsHoliday(dynamic value) {
  if (value == null) return true;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value.toString().toLowerCase().trim();
  if (normalized.isEmpty) return true;
  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes' ||
      normalized == 'y';
}

Map<String, dynamic> unwrapHolidayPayload(dynamic data) {
  if (data is! Map) return {};
  var map = _asStringKeyMap(data);

  for (final key in ['data', 'payload', 'result', 'response']) {
    final nested = map[key];
    if (nested is Map) {
      map = _asStringKeyMap(nested);
      break;
    }
  }

  return map;
}

Map<String, dynamic> _asStringKeyMap(Map map) {
  return Map<String, dynamic>.from(
    map.map((key, value) => MapEntry(key.toString(), value)),
  );
}

List<dynamic> _readHolidayList(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) return value;
  }
  return const [];
}

bool _looksLikeHolidayMap(Map<String, dynamic> json) {
  return json['date'] != null ||
      json['holiday_date'] != null ||
      json['holidayDate'] != null;
}

List<PublicHoliday> _parseHolidayRows(List<dynamic> rows) {
  final holidays = <PublicHoliday>[];
  for (final row in rows) {
    if (row is! Map) continue;
    try {
      final holiday = PublicHoliday.fromJson(_asStringKeyMap(row));
      if (holiday.isHoliday) holidays.add(holiday);
    } catch (_) {
      // Skip malformed rows instead of failing the whole calendar.
    }
  }
  holidays.sort((a, b) => a.date.compareTo(b.date));
  return holidays;
}

List<PublicHoliday> _dedupeHolidays(List<PublicHoliday> holidays) {
  final seen = <String>{};
  final unique = <PublicHoliday>[];
  for (final holiday in holidays) {
    final key =
        '${holiday.date.year}-${holiday.date.month}-${holiday.date.day}|${holiday.name}';
    if (seen.add(key)) unique.add(holiday);
  }
  unique.sort((a, b) => a.date.compareTo(b.date));
  return unique;
}

List<PublicHoliday> parsePublicHolidayList(dynamic data) {
  if (data is List) return _parseHolidayRows(data);
  if (data is! Map) return const [];

  final map = unwrapHolidayPayload(data);
  final rows = _readHolidayList(
    map,
    ['holidays', 'public_holidays', 'results', 'data', 'items'],
  );
  return _parseHolidayRows(rows);
}

/// Handles `{ holidays: [...] }`, `{ months: [...] }`, nested `data`, or raw lists.
List<PublicHoliday> parsePublicHolidayResponse(dynamic data) {
  if (data is List) {
    return _dedupeHolidays(_parseHolidayRows(data));
  }

  final map = unwrapHolidayPayload(data);
  if (map.isEmpty) return const [];

  final all = <PublicHoliday>[];

  all.addAll(
    _parseHolidayRows(
      _readHolidayList(
        map,
        ['holidays', 'public_holidays', 'results', 'items'],
      ),
    ),
  );

  final months = map['months'];
  if (months is List) {
    for (final entry in months) {
      if (entry is List) {
        all.addAll(_parseHolidayRows(entry));
        continue;
      }
      if (entry is! Map) continue;

      final monthMap = _asStringKeyMap(entry);
      final rows = _readHolidayList(
        monthMap,
        ['holidays', 'public_holidays', 'days', 'items', 'entries', 'list'],
      );
      if (rows.isNotEmpty) {
        all.addAll(_parseHolidayRows(rows));
      } else if (_looksLikeHolidayMap(monthMap)) {
        all.addAll(_parseHolidayRows([monthMap]));
      }
    }
  } else if (months is Map) {
    for (final entry in months.values) {
      if (entry is List) {
        all.addAll(_parseHolidayRows(entry));
      } else if (entry is Map) {
        final monthMap = _asStringKeyMap(entry);
        final rows = _readHolidayList(
          monthMap,
          ['holidays', 'public_holidays', 'days', 'items', 'entries', 'list'],
        );
        if (rows.isNotEmpty) {
          all.addAll(_parseHolidayRows(rows));
        } else if (_looksLikeHolidayMap(monthMap)) {
          all.addAll(_parseHolidayRows([monthMap]));
        }
      }
    }
  }

  return _dedupeHolidays(all);
}

List<PublicHoliday> mergePublicHolidayLists(
  Iterable<List<PublicHoliday>> groups,
) {
  return _dedupeHolidays(groups.expand((group) => group).toList());
}
