import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api';

  // ── Event endpoints ──
  static String get eventsUrl => '$baseUrl/events/';
  static String eventUrl(int id) => '$baseUrl/events/$id/';

  // ── Users endpoint (NEW) ──
  static String get allUsersUrl =>
      '$baseUrl/accounts/crm/users/all/';
}
