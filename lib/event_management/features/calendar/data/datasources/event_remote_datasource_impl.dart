import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:my_app/services/secure_storage_service.dart';
import '../models/event_models.dart';
import 'event_remote_datasource.dart';
import 'package:my_app/event_management/features/domain/entities/event_entity.dart'; // ✅ Added for Participant class

class UserLite {
  final int id;
  final String name;
  final String? email; // ✅ Added email to match Participant needs

  UserLite({required this.id, required this.name, this.email});
}

class EventRemoteDatasourceImpl implements EventRemoteDatasource {
  final http.Client _client;
  final SecureStorageService _storage = SecureStorageService();

  EventRemoteDatasourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  final Map<int, UserLite> _permanentUserCache = {};
  List<UserLite>? _cachedUsers;

  // ───────────── JWT HEADER BUILDER ─────────────
  Future<String?> _getToken() async => await _storage.readToken();

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    if (token == null) {
      throw ServerException(message: 'No access token found. Please login again.', statusCode: 401);
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _throwOnError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw ServerException(message: 'Server error', statusCode: response.statusCode);
  }

  // ───────────── FETCH EVENTS (WITH HYDRATION) ─────────────

  @override
  Future<List<EventModel>> fetchEvents({String? start, String? end}) async {
    final query = <String, String>{};
    if (start != null) query['start'] = start;
    if (end != null) query['end'] = end;

    final uri = Uri.parse(ApiConstants.eventsUrl).replace(queryParameters: query);
    final response = await _client.get(uri, headers: await _headers());
    _throwOnError(response);

    final body = jsonDecode(response.body);
    final List<dynamic> list = body is Map ? body['results'] as List<dynamic> : body as List<dynamic>;


    final List<EventModel> events = list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();


    return events.map((event) {
      final hydratedParticipants = event.participants.map((p) {
        final cachedUser = _permanentUserCache[p.id];
        if (cachedUser != null) {
          return Participant(
            id: p.id,
            name: cachedUser.name,
            email: cachedUser.email ?? '',
          );
        }
        return p; // Keep "User 18" if not found in cache yet
      }).toList();

      return EventModel.fromEntity(event.copyWith(participants: hydratedParticipants));
    }).toList();
  }

  // ───────────── CREATE / UPDATE ─────────────

  @override
  Future<EventModel> createEvent(EventModel event) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.eventsUrl),
      headers: await _headers(),
      body: jsonEncode(event.toJson()),
    );
    _throwOnError(response);
    return EventModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    final response = await _client.put(
      Uri.parse(ApiConstants.eventUrl(event.id!)),
      headers: await _headers(),
      body: jsonEncode(event.toJson()),
    );
    _throwOnError(response);
    return EventModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<bool> deleteEvent(int id) async {
    final response = await _client.delete(Uri.parse(ApiConstants.eventUrl(id)), headers: await _headers());
    return response.statusCode == 204;
  }

  // ───────────── PARTICIPANT SEARCH (FILLS CACHE) ─────────────

  Future<List<UserLite>> searchUser(String query, {int page = 1}) async {
    final uri = Uri.parse("${ApiConstants.allUsersUrl}?search=$query&page=$page");
    final response = await _client.get(uri, headers: await _headers());
    _throwOnError(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded is List ? decoded : (decoded['results'] ?? []);

    return data.map((e) {

      final String firstName = e['first_name'] ?? '';
      final String lastName = e['last_name'] ?? '';
      String fullName = '$firstName $lastName'.trim();
      if (fullName.isEmpty) fullName = e['username'] ?? 'User ${e['id']}';

      final user = UserLite(
          id: e['id'],
          name: fullName,
          email: e['email']
      );


      _permanentUserCache[user.id] = user;
      return user;
    }).toList();
  }

  Future<void> ensureUsersLoaded() async {
    // If the cache is empty, we search with empty string to grab initial users
    if (_permanentUserCache.isEmpty) {
      await searchUser("");
    }
  }

  Map<int, UserLite> get usersById => _permanentUserCache;
}