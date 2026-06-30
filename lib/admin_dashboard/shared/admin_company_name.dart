import 'package:my_app/services/secure_storage_service.dart';

/// Resolves display company name from stored login profile.
Future<String> resolveAdminCompanyName() async {
  final user = await SecureStorageService().readUser();
  if (user != null) {
    for (final key in const [
      'company_name',
      'organization_name',
      'org_name',
      'company',
      'organization',
    ]) {
      final v = user[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is Map) {
        final name = v['name']?.toString().trim();
        if (name != null && name.isNotEmpty) return name;
      }
    }
  }
  return 'DAXARROW';
}
