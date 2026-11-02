import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/presentation/mobile/admin_module_access.dart';
import 'package:my_app/admin_dashboard/screen/project_and_task_options_screen.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/dashboard_card.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/dashboard_item.dart';
import 'package:my_app/leave_management/screens/mobile_screen/screen/leave_manager_mobile_screen.dart';
import 'package:my_app/dashboards/presentations/screens/mobile_screen/screen/share_dashboard_mobile_screen.dart';
import 'package:my_app/client tracker/features/clients/bloc/client_bloc.dart';
import 'package:my_app/client tracker/features/clients/repository/client_repository.dart';
import 'package:my_app/client tracker/features/clients/screen/mobile_screen/screen/client_tracker_mobile_shell.dart';
import 'package:my_app/billing/navigation/billing_flow_controller.dart';
import 'package:my_app/event_management/features/calendar/presentation/screen/calendar_screen_mobile.dart';
import 'package:my_app/payroll/navigation/payroll_flow_controller.dart';
import 'package:my_app/asset_management/navigation/asset_flow_controller.dart';
import 'package:my_app/analytics/navigation/analytics_flow_controller.dart';
import 'package:my_app/auth/manage_users_navigation.dart';
import 'package:my_app/admin_settings/screens/admin_settings_screen.dart';
import 'package:my_app/admin_settings/screens/user_form_screen.dart';
import 'package:my_app/auth/profile_remote_sync.dart';
import 'package:my_app/admin_dashboard/presentation/mobile/live_attendance_mobile_screen.dart';

/// Mobile module shortcuts — filtered by the same `admin_modules` as desktop.
class MobileFeatureGrid extends StatefulWidget {
  final List<Employee> employees;
  final int totalEmployeeCount;
  final bool isSuperuser;

  const MobileFeatureGrid({
    super.key,
    required this.employees,
    required this.totalEmployeeCount,
    this.isSuperuser = false,
  });

  @override
  State<MobileFeatureGrid> createState() => _MobileFeatureGridState();
}

class _MobileFeatureGridState extends State<MobileFeatureGrid> {
  AdminModuleAccess? _access;

  @override
  void initState() {
    super.initState();
    ProfileRemoteSync.authSessionEpoch.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    ProfileRemoteSync.authSessionEpoch.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    final access = await AdminModuleAccess.load();
    if (!mounted) return;
    setState(() => _access = access);
  }

  @override
  Widget build(BuildContext context) {
    final access = _access;
    if (access == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFC05E41)),
        ),
      );
    }

    const List<Color> palette = [
      Color(0xFFAACC96),
      Color(0xFF25533F),
      Color(0xFFF4BEAE),
      Color(0xFF52A5CE),
      Color(0xFFFF7BAC),
      Color(0xFF876029),
      Color(0xFF6D1F42),
      Color(0xFFD3B6D3),
      Color(0xFFEFCE7B),
      Color(0xFFB8CEE8),
      Color(0xFFEF6F3C),
      Color(0xFFAFAB23),
    ];

    Color getContrast(Color bg) =>
        ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    int colorIdx = 0;
    Color nextBg() => palette[colorIdx++ % palette.length];

    final isSuper = access.isSuperuser || widget.isSuperuser;
    final items = <DashboardItem>[];

    void addItem({
      required String? moduleKey,
      required IconData icon,
      required String label,
      required VoidCallback? onTap,
      Color? bgColor,
      Color? iconColor,
    }) {
      if (!access.allows(moduleKey)) return;
      final bg = bgColor ?? nextBg();
      items.add(
        DashboardItem(
          icon: icon,
          label: label,
          bgColor: bg,
          iconColor: iconColor ?? getContrast(bg),
          onTap: onTap,
        ),
      );
    }

    if (isSuper) {
      addItem(
        moduleKey: null,
        icon: Icons.manage_accounts_rounded,
        label: 'Manage users',
        onTap: () => openManageUsersIfAllowed(context),
      );
      addItem(
        moduleKey: null,
        icon: Icons.person_add_alt_1_rounded,
        label: 'Add user',
        onTap: () => UserFormScreen.open(context),
      );
    }

    addItem(
      moduleKey: 'analytics',
      icon: Icons.assessment_rounded,
      label: 'Analytics',
      bgColor: const Color(0xFFEADBC8),
      iconColor: const Color(0xFFC05E41),
      onTap: () => AnalyticsFlowController.openWithPermissionCheck(context),
    );
    addItem(
      moduleKey: 'employees',
      icon: Icons.badge_rounded,
      label: 'Employees',
      onTap: () => _openLiveAttendance(context),
    );
    addItem(
      moduleKey: 'tasks',
      icon: Icons.assignment_rounded,
      label: 'Projects & Tasks',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProjectAndTaskOptionsScreen(),
          ),
        );
      },
    );
    addItem(
      moduleKey: 'share',
      icon: Icons.share_rounded,
      label: 'Share',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ShareDashboardMobileScreen(),
          ),
        );
      },
    );
    addItem(
      moduleKey: 'clients',
      icon: Icons.handshake_rounded,
      label: 'Clients',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => ClientBloc(ClientRepository()),
              child: const ClientTrackerMobileShell(),
            ),
          ),
        );
      },
    );
    addItem(
      moduleKey: 'asset_management',
      icon: Icons.inventory_2_rounded,
      label: 'Assets & Resources',
      onTap: () => AssetFlowController.openAdmin(context),
    );
    addItem(
      moduleKey: 'leave_management',
      icon: Icons.event_busy_rounded,
      label: 'Leave Management',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LeaveManagerMobileScreen(),
          ),
        );
      },
    );
    addItem(
      moduleKey: 'billing',
      icon: Icons.receipt_long_rounded,
      label: 'Billing & Invoices',
      onTap: () => BillingFlowController.start(context),
    );
    addItem(
      moduleKey: 'payroll',
      icon: Icons.payments_rounded,
      label: 'Payroll',
      onTap: () => PayrollFlowController.openWithPermissionCheck(context),
    );
    addItem(
      moduleKey: 'leads',
      icon: Icons.groups_3_rounded,
      label: 'Leads',
      onTap: null,
    );
    addItem(
      moduleKey: 'events',
      icon: Icons.event_available_rounded,
      label: 'Events',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CalendarScreenMobile(),
          ),
        );
      },
    );

    // Always last: holidays and other admin settings.
    addItem(
      moduleKey: null,
      icon: Icons.settings_rounded,
      label: 'Settings',
      bgColor: const Color(0xFF3E2723),
      iconColor: const Color(0xFFFAF9F6),
      onTap: () => AdminSettingsScreen.open(context),
    );

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
        child: Text(
          'No modules assigned to your account. Contact a superadmin.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.brown.shade700,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 140,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => DashboardCard(item: items[index]),
    );
  }

  void _openLiveAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveAttendanceMobileScreen(
          employees: widget.employees,
          totalEmployeeCount: widget.totalEmployeeCount,
        ),
      ),
    );
  }
}
