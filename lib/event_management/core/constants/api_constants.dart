class ApiConstants {
  static const String baseUrl =
  String.fromEnvironment('BASE_URL',
      defaultValue: 'http://localhost:8000/api');

  // ── Event endpoints ──
  static String get eventsUrl => '$baseUrl/api/events/';
  static String eventUrl(int id) => '$baseUrl/api/events/$id/';
  static String get allUsersUrl =>
      '$baseUrl/api/accounts/crm/users/all/';
}


