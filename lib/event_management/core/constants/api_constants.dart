class ApiConstants {
  static const String baseUrl =
  String.fromEnvironment('BASE_URL',
      defaultValue: 'http://localhost:8000/api');

  // ── Event endpoints ──
  static String get eventsUrl => '$baseUrl/events/';
  static String eventUrl(int id) => '$baseUrl/events/$id/';
  static String get allUsersUrl =>
      '$baseUrl/accounts/crm/users/all/';
}


