/// Shared platform options for credentials (add client, add credential, etc.).
abstract final class ClientPlatformChoices {
  static const List<Map<String, String>> entries = [
    {'value': 'youtube', 'label': 'YouTube'},
    {'value': 'facebook', 'label': 'Facebook'},
    {'value': 'instagram', 'label': 'Instagram'},
    {'value': 'google_ads', 'label': 'Google Ads'},
    {'value': 'meta_ads', 'label': 'Meta Ads'},
    {'value': 'website', 'label': 'Website'},
    {'value': 'other', 'label': 'Other'},
  ];
}
