import 'package:flutter/material.dart';
import 'package:my_app/admin_settings/admin_palette.dart';
import 'package:my_app/admin_settings/screens/holidays_admin_screen.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Admin → Settings. Opened from the desktop sidebar's settings icon and the
/// mobile dashboard's Settings box.
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const AdminSettingsScreen()),
      );

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool? _isSuperuser;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final raw = await SecureStorageService().readAuthSessionJson();
    if (!mounted) return;
    setState(() => _isSuperuser = AuthSession.fromStorageString(raw)?.isSuperuser ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    final isSuper = _isSuperuser;
    return AdminSettingsScaffold(
      title: 'Settings',
      body: isSuper == null
          ? Center(child: CircularProgressIndicator(color: p.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SettingsTile(
                  icon: Icons.beach_access_rounded,
                  title: 'Holidays',
                  subtitle: isSuper
                      ? 'Add holidays or import a CSV. No check-in reminder emails go out on these days.'
                      : 'Office holiday list. Only a super admin can change it.',
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => HolidaysAdminScreen(canEdit: isSuper),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: p.primaryDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: p.text),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: p.muted, fontSize: 13, height: 1.35)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.muted),
            ],
          ),
        ),
      ),
    );
  }
}
