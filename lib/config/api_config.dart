class ApiConfig {
  static const String server = "http://192.168.1.13:8000";

  // AUTH + LOGIN
  static const String accounts = "$server/api/accounts/crm";

  // EMPLOYEE FEATURES (attendance, live-status, check-in/out)
  static const String employee = "$server/api/employee/crm";

  // LEADS + SETUPS
  static const String leadsSetups = "$server/api";

  // ADMIN PANEL — if you expose admin APIs
  static const String admin = "$server/admin";
}
