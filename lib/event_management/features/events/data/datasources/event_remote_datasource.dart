import 'package:dio/dio.dart';
import 'package:my_app/event_management/core/network/api_service.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEventsInRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<List<EventModel>> getTodayEvents();
  Future<List<EventModel>> getUpcomingEvents({int limit = 10});
  Future<List<EventModel>> getMissedEvents({int limit = 10});
  Future<EventModel> getEventById(String id);
  Future<EventModel> createEvent(EventModel event);
  Future<EventModel> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
  Future<List<EventModel>> searchEvents({
    required String query,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? participantId,
  });
  Future<EventModel> addParticipant({required String eventId, required String userId});
  Future<void> removeParticipant({required String eventId, required String userId});
  Future<EventModel> acceptEventInvite(String eventId);
  Future<EventModel> declineEventInvite(String eventId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio _dio;
  EventRemoteDataSourceImpl(this._dio);

  /// Normalizes API payloads; some endpoints nest the object under [event] or [data].
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
  Future<List<EventModel>> getEventsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.eventsRange,
      queryParameters: {
        'start': startDate.toIso8601String().split('T')[0],
        'end': endDate.toIso8601String().split('T')[0],
      },
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EventModel>> getTodayEvents() async {
    final response = await _dio.get(ApiEndpoints.eventsToday);
    final results = response.data is List
        ? response.data as List<dynamic>
        : response.data['results'] as List<dynamic>;
    return results
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EventModel>> getUpcomingEvents({int limit = 10}) async {
    final response = await _dio.get(
      ApiEndpoints.eventsUpcoming,
      queryParameters: {'limit': limit},
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EventModel>> getMissedEvents({int limit = 10}) async {
    final response = await _dio.get(
      ApiEndpoints.eventsMissed,
      queryParameters: {'limit': limit},
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EventModel> getEventById(String id) async {
    final response = await _dio.get('${ApiEndpoints.events}$id/');
    return EventModel.fromJson(_unwrapObject(response.data));
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    final response = await _dio.post(
      ApiEndpoints.events,
      data: event.toJson(),
    );
    return EventModel.fromJson(
      _unwrapObject(response.data),
      mergeFrom: event,
    );
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    final response = await _dio.put(
      '${ApiEndpoints.events}${event.id}/',
      data: event.toJson(),
    );
    return EventModel.fromJson(
      _unwrapObject(response.data),
      mergeFrom: event,
    );
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _dio.delete('${ApiEndpoints.events}$id/');
  }

  @override
  Future<List<EventModel>> searchEvents({
    required String query,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? participantId,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.events,
      queryParameters: {
        'search': query,
        if (eventType != null) 'event_type': eventType,
        if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
        if (participantId != null) 'participant': participantId,
      },
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EventModel> addParticipant({
    required String eventId,
    required String userId,
  }) async {
    final response = await _dio.post(
      '${ApiEndpoints.events}$eventId/add-participant/',
      data: {'user_id': userId},
    );
    return EventModel.fromJson(_unwrapObject(response.data));
  }

  @override
  Future<void> removeParticipant({
    required String eventId,
    required String userId,
  }) async {
    await _dio.delete(
      '${ApiEndpoints.events}$eventId/remove-participant/',
      data: {'user_id': userId},
    );
  }

  @override
  Future<EventModel> acceptEventInvite(String eventId) async {
    await _dio.post('${ApiEndpoints.events}$eventId/accept/');
    // API often returns a short ack (e.g. ~20 bytes), not a full event — always refetch.
    return getEventById(eventId);
  }

  @override
  Future<EventModel> declineEventInvite(String eventId) async {
    await _dio.post('${ApiEndpoints.events}$eventId/decline/');
    return getEventById(eventId);
  }
}