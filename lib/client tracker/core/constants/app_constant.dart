class AppConstants {

  static const String baseUrl =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000/api');

  static const String clients     = '/clients/';
  static const String services    = '/services/';
  static const String credentials = '/credentials/';
  static const String payments    = '/payments/';

  static String clientById(int id)           => '/clients/$id/';
  static String servicesByClient(int cid)    => '/services/client/$cid/';
  static String credentialsByClient(int cid) => '/credentials/client/$cid/';
  static String paymentById(int id)          => '/payments/$id/';

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