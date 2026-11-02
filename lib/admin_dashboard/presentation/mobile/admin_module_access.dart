import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Shared admin-module gate used by mobile grids (same rules as desktop sidebar).
class AdminModuleAccess {
  AdminModuleAccess._({
    required this.session,
    required this.isSuperuser,
    required this.isAdmin,
  });

  final AuthSession? session;
  final bool isSuperuser;
  final bool isAdmin;

  static Future<AdminModuleAccess> load() async {
    final storage = SecureStorageService();
    final raw = await storage.readAuthSessionJson();
    final session = AuthSession.fromStorageString(raw);
    final role = (await storage.readRole())?.toLowerCase();
    final legacySuper = await storage.readIsSuperuser();
    final isSuperuser = session?.isSuperuser == true ||
        (session == null && legacySuper);
    final isAdmin =
        session?.isAdmin == true || role == 'admin' || isSuperuser;
    return AdminModuleAccess._(
      session: session,
      isSuperuser: isSuperuser,
      isAdmin: isAdmin,
    );
  }

  bool allows(String? moduleKey) {
    if (isSuperuser) return true;
    if (moduleKey == null || moduleKey.isEmpty) return true;
    if (session != null) {
      if (moduleKey == 'payroll') return session!.canAccessPayrollAdmin;
      if (moduleKey == 'analytics') {
        return session!.adminModules['analytics'] == true;
      }
      return session!.moduleAllowed(moduleKey);
    }
    // No session payload: keep backward-compatible open access for admins.
    return isAdmin;
  }

  bool get canSeeEmployees => allows('employees');
}
