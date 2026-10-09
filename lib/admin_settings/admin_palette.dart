import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/admin_top_bar_mobile.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';

/// Colours for the admin settings screens. Desktop follows the mint/teal admin
/// shell, mobile the terracotta one — the same split as [SuperadminUsersScreen].
class AdminPalette {
  const AdminPalette._(this.wide);

  final bool wide;

  static AdminPalette of(BuildContext context) =>
      AdminPalette._(MediaQuery.sizeOf(context).width >= 900);

  Color get primary =>
      wide ? AdminDashboardTheme.teal : AdminMobileTerracottaTheme.terracotta;
  Color get primaryDark =>
      wide ? AdminDashboardTheme.tealDark : AdminMobileTerracottaTheme.terracottaDark;
  Color get primaryLight =>
      wide ? AdminDashboardTheme.tealLight : const Color(0xFFEADBC8);
  Color get text => wide ? AdminDashboardTheme.textDark : const Color(0xFF3E2723);
  Color get muted => wide ? AdminDashboardTheme.textMuted : const Color(0xFF8D6E63);
  Color get border => wide
      ? AdminDashboardTheme.border
      : AdminMobileTerracottaTheme.terracotta.withValues(alpha: 0.16);
  Color get background =>
      wide ? AdminDashboardTheme.shellMint : AdminMobileTerracottaTheme.cream;
  Color get surface => Colors.white;
  Color get surfaceMuted =>
      wide ? AdminDashboardTheme.surfaceMuted : AdminMobileTerracottaTheme.creamMuted;
  Color get danger => const Color(0xFFC0392B);
}

/// Page frame shared by the settings screens: app bar, and on desktop the
/// rounded white panel the rest of the admin shell uses.
class AdminSettingsScaffold extends StatelessWidget {
  const AdminSettingsScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    final base = Theme.of(context);
    // Same typeface as the dashboard. Dialogs opened from these screens
    // inherit it too (showDialog captures the surrounding theme).
    return Theme(
      data: base.copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
        colorScheme: base.colorScheme.copyWith(primary: p.primary),
      ),
      child: _buildScaffold(context, p),
    );
  }

  Widget _buildScaffold(BuildContext context, AdminPalette p) {
    return Scaffold(
      backgroundColor: p.background,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        backgroundColor: p.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.text,
        centerTitle: false,
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: p.text,
            fontSize: 20,
          ),
        ),
        actions: actions,
      ),
      body: p.wide
          ? Padding(
              padding: const EdgeInsets.all(AdminDashboardTheme.shellPadding),
              child: AdminDashboardPanel(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: body,
                  ),
                ),
              ),
            )
          : SafeArea(top: false, child: body),
    );
  }
}

void showAdminSnack(BuildContext context, String message, {bool error = false}) {
  final p = AdminPalette.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? p.danger : p.primaryDark,
      content: Text(
        message,
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
      ),
    ),
  );
}
