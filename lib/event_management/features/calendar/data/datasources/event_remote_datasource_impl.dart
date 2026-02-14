import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../models/event_models.dart';
import 'event_remote_datasource.dart';


class UserLite {
  final int id;
  final String name;

  UserLite({required this.id, required this.name});
}

class EventRemoteDatasourceImpl implements EventRemoteDatasource {
  final http.Client _client;
  final SecureStorageService _storage = SecureStorageService();

  EventRemoteDatasourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  // ───────────── JWT HEADER BUILDER ─────────────

  Future<String?> _getToken() async {
    return await _storage.readToken();
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    if (token == null) {
      throw ServerException(
        message: 'No access token found. Please login again.',
        statusCode: 401,
      );
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ───────────── ERROR HANDLER ─────────────

  void _throwOnError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if (response.statusCode == 401) {
      throw ServerException(
        message: 'Unauthorized. JWT token missing or expired.',
        statusCode: 401,
      );
    }

    if (response.statusCode == 400) {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw ValidationException(errors: body);
      } catch (e) {
        if (e is ValidationException) rethrow;
        throw ServerException(
          message: 'Bad request: ${response.body}',
          statusCode: 400,
        );
      }
    }

    if (response.statusCode == 404) {
      throw NotFoundException();
    }

    throw ServerException(
      message: 'Server error (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  // ───────────── FETCH EVENTS ─────────────

  @override
  Future<List<EventModel>> fetchEvents({String? start, String? end}) async {
    final query = <String, String>{};
    if (start != null) query['start'] = start;
    if (end != null) query['end'] = end;

    final uri =
    Uri.parse(ApiConstants.eventsUrl).replace(queryParameters: query);

    final response =
    await _client.get(uri, headers: await _headers());

    _throwOnError(response);

    final body = jsonDecode(response.body);
    final list = body is Map
        ? body['results'] as List<dynamic>
        : body as List<dynamic>;

    return list
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ───────────── CREATE EVENT ─────────────

  @override
  Future<EventModel> createEvent(EventModel event) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.eventsUrl),
      headers: await _headers(),
      body: jsonEncode(event.toJson()),
    );

    _throwOnError(response);
    return EventModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ───────────── UPDATE EVENT ─────────────

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    final response = await _client.put(
      Uri.parse(ApiConstants.eventUrl(event.id!)),
      headers: await _headers(),
      body: jsonEncode(event.toJson()),
    );

    _throwOnError(response);
    return EventModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ───────────── DELETE EVENT ─────────────

  @override
  Future<bool> deleteEvent(int id) async {
    final response = await _client.delete(
      Uri.parse(ApiConstants.eventUrl(id)),
      headers: await _headers(),
    );

    if (response.statusCode == 204) return true;

    _throwOnError(response);
    return false;
  }

  // ───────────── PARTICIPANT SEARCH (FIXED) ─────────────

  List<UserLite>? _cachedUsers;

  Future<List<UserLite>> searchUser(String query) async {
    if (_cachedUsers == null) {
      final uri = Uri.parse(ApiConstants.allUsersUrl);

      final response =
      await _client.get(uri, headers: await _headers());

      _throwOnError(response);

      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded is Map
          ? List<dynamic>.from(decoded['results'])
          : List<dynamic>.from(decoded);

      _cachedUsers = data.map((e) {
        final String name =
        (e['name'] ?? e['username'] ?? '').toString();

        return UserLite(
          id: e['id'],
          name: name,
        );
      }).toList();
    }

    final lower = query.toLowerCase();

    return _cachedUsers!
        .where((u) => u.name.toLowerCase().startsWith(lower))
        .toList();
  }

  Future<void> ensureUsersLoaded() async {
    if (_cachedUsers != null) return;

    final uri = Uri.parse(ApiConstants.allUsersUrl);

    final response = await _client.get(uri, headers: await _headers());
    _throwOnError(response);

    final decoded = jsonDecode(response.body);

    final List<dynamic> data = decoded is Map
        ? List<dynamic>.from(decoded['results'])
        : List<dynamic>.from(decoded);

    _cachedUsers = data.map((e) {
      final String name =
      (e['name'] ?? e['username'] ?? '').toString();

      return UserLite(
        id: e['id'],
        name: name,
      );
    }).toList();
  }

  Map<int, UserLite> get usersById {
    if (_cachedUsers == null) return {};
    return {for (final u in _cachedUsers!) u.id: u};
  }
}

