class AppConstants {

  static const String baseUrl =
  String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // API endpoints
  static const String clients     = '/api/client/clients/';
  static const String services    = '/api/client/services/';
  static const String credentials = '/api/client/credentials/';
  static const String payments    = '/api/client/payments/';
  static const String dashboard   = '/api/client/dashboard/';
  static const String events      = '/api/events/';

  static String clientById(int id)           => '/api/client/clients/$id/';
  static String servicesByClient(int cid)    => '/api/client/services/client/$cid/';
  static String credentialsByClient(int cid) => '/api/client/credentials/client/$cid/';
  static String paymentById(int id)          => '/api/client/payments/$id/';

  static const List<String> platforms = [
    'youtube',
    'facebook',
    'instagram',
    'google_ads',
    'meta_ads',
    'website',
    'other'
  ];

  static const Map<String, String> platformLabels = {
    'youtube': 'YouTube',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'google_ads': 'Google Ads',
    'meta_ads': 'Meta Ads',
    'website': 'Website',
    'other': 'Other',
  };
}