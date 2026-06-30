import 'package:dio/dio.dart';

import 'package:my_app/event_management/core/network/api_service.dart';
import 'package:my_app/event_management/features/calendar/domain/entities/calendar_grid_event.dart';
import 'package:my_app/event_management/features/calendar/domain/entities/calendar_holiday.dart';
import 'package:my_app/event_management/features/events/data/models/event_model.dart';

class CalendarRangeData {
  const CalendarRangeData({
    required this.events,
    required this.taskDeadlines,
    this.holidays = const [],
  });

  final List<CalendarGridEvent> events;
  final List<CalendarGridEvent> taskDeadlines;
  final List<CalendarHoliday> holidays;

  List<CalendarGridEvent> get all => [...events, ...taskDeadlines];
}

class ConflictItem {
  const ConflictItem({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  factory ConflictItem.fromJson(Map<String, dynamic> json) {
    DateTime parse(dynamic v) =>
        DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
    return ConflictItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      startTime: parse(json['start_time']),
      endTime: parse(json['end_time']),
    );
  }
}

abstract class CalendarRemoteDataSource {
  Future<CalendarRangeData> getCalendarRange({
    required DateTime start,
    required DateTime end,
    bool includeTasks = true,
    bool includeHolidays = true,
  });

  Future<Map<String, List<String>>> getDotMap({
    required DateTime start,
    required DateTime end,
  });

  Future<List<CalendarReminderItem>> getMyReminders();

  Future<CalendarGridEvent> moveEvent({
    required String eventId,
    required DateTime startTime,
    required DateTime endTime,
  });

  Future<({bool hasConflict, List<ConflictItem> conflicts})> conflictCheck({
    required DateTime startTime,
    required DateTime endTime,
    String? excludeEventId,
  });

  Future<EventModel> getEventDetail(String id);
  Future<EventModel> completeEvent(String id);
  Future<EventModel> cancelEvent(String id);
  Future<EventModel> restoreEvent(String id);
  Future<EventModel> duplicateEvent(String id);
  Future<List<int>> exportIcsRange({required DateTime start, required DateTime end});
  Future<List<int>> exportIcsEvent(String id);
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  CalendarRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Map<String, dynamic> _unwrapObject(dynamic data) {
    if (data == null) return {};
    if (data is! Map) return {};
    final map = Map<String, dynamic>.from(
      data.map((k, v) => MapEntry(k.toString(), v)),
    );
    final nested = map['event'] ?? map['data'];
    if (nested is Map) {
      return Map<String, dynamic>.from(
        nested.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    return map;
  }

  @override
  Future<CalendarRangeData> getCalendarRange({
    required DateTime start,
    required DateTime end,
    bool includeTasks = true,
    bool includeHolidays = true,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.eventsCalendar,
      queryParameters: {
        'start': _dateKey(start),
        'end': _dateKey(end),
        'include_tasks': includeTasks,
        'include_holidays': includeHolidays,
      },
    );
    final data = res.data is Map ? res.data as Map<String, dynamic> : <String, dynamic>{};
    final events = (data['events'] as List? ?? [])
        .whereType<Map>()
        .map((e) => CalendarGridEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final deadlines = (data['task_deadlines'] as List? ?? [])
        .whereType<Map>()
        .map((e) => CalendarGridEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final holidays = (data['holidays'] as List? ?? [])
        .whereType<Map>()
        .map((e) => CalendarHoliday.fromJson(Map<String, dynamic>.from(e)))
        .where((h) => h.isHoliday)
        .toList();
    return CalendarRangeData(
      events: events,
      taskDeadlines: deadlines,
      holidays: holidays,
    );
  }

  @override
  Future<Map<String, List<String>>> getDotMap({
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.eventsDotMap,
      queryParameters: {
        'start': _dateKey(start),
        'end': _dateKey(end),
      },
    );
    final dots = (res.data is Map ? res.data['dots'] : null) as Map? ?? {};
    return dots.map(
      (k, v) => MapEntry(
        k.toString(),
        (v as List? ?? []).map((e) => e.toString()).toList(),
      ),
    );
  }

  @override
  Future<List<CalendarReminderItem>> getMyReminders() async {
    final res = await _dio.get(ApiEndpoints.eventsMyReminders);
    final rows = res.data is Map
        ? (res.data['results'] as List? ?? [])
        : (res.data as List? ?? []);
    return rows
        .whereType<Map>()
        .map((e) => CalendarReminderItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<CalendarGridEvent> moveEvent({
    required String eventId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final res = await _dio.patch(
      '${ApiEndpoints.events}$eventId/move/',
      data: {
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
      },
    );
    final map = _unwrapObject(res.data);
    return CalendarGridEvent.fromJson(map);
  }

  @override
  Future<({bool hasConflict, List<ConflictItem> conflicts})> conflictCheck({
    required DateTime startTime,
    required DateTime endTime,
    String? excludeEventId,
  }) async {
    final body = <String, dynamic>{
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
    };
    if (excludeEventId != null && excludeEventId.isNotEmpty) {
      body['exclude_event_id'] = excludeEventId;
    }
    final res = await _dio.post(ApiEndpoints.eventsConflictCheck, data: body);
    final data = res.data is Map ? res.data as Map<String, dynamic> : {};
    final conflicts = (data['conflicts'] as List? ?? [])
        .whereType<Map>()
        .map((e) => ConflictItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return (
      hasConflict: data['has_conflict'] == true,
      conflicts: conflicts,
    );
  }

  @override
  Future<EventModel> getEventDetail(String id) async {
    final res = await _dio.get('${ApiEndpoints.events}$id/');
    return EventModel.fromJson(_unwrapObject(res.data));
  }

  @override
  Future<EventModel> completeEvent(String id) async {
    final res = await _dio.post('${ApiEndpoints.events}$id/complete/');
    return EventModel.fromJson(_unwrapObject(res.data));
  }

  @override
  Future<EventModel> cancelEvent(String id) async {
    final res = await _dio.post('${ApiEndpoints.events}$id/cancel/');
    return EventModel.fromJson(_unwrapObject(res.data));
  }

  @override
  Future<EventModel> restoreEvent(String id) async {
    final res = await _dio.post('${ApiEndpoints.events}$id/restore/');
    return EventModel.fromJson(_unwrapObject(res.data));
  }

  @override
  Future<EventModel> duplicateEvent(String id) async {
    final res = await _dio.post('${ApiEndpoints.events}$id/duplicate/');
    return EventModel.fromJson(_unwrapObject(res.data));
  }

  @override
  Future<List<int>> exportIcsRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await _dio.get<List<int>>(
      ApiEndpoints.eventsExportIcs,
      queryParameters: {'start': _dateKey(start), 'end': _dateKey(end)},
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? [];
  }

  @override
  Future<List<int>> exportIcsEvent(String id) async {
    final res = await _dio.get<List<int>>(
      '${ApiEndpoints.events}$id/export-ical/',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? [];
  }
}
