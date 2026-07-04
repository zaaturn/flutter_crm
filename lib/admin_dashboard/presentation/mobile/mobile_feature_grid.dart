import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
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
import 'package:my_app/analytics/navigation/analytics_flow_controller.dart';
import 'package:my_app/auth/manage_users_navigation.dart';
import 'package:my_app/admin_dashboard/presentation/mobile/live_attendance_mobile_screen.dart';

/// Mobile module shortcuts — Analytics opens on tap (not embedded on home).
class MobileFeatureGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

    final List<DashboardItem> items = [
      if (isSuperuser)
        DashboardItem(
          icon: Icons.manage_accounts_rounded,
          label: 'Manage users',
          bgColor: palette[colorIdx++],
          iconColor: getContrast(palette[colorIdx - 1]),
          onTap: () => openManageUsersIfAllowed(context),
        ),
      DashboardItem(
        icon: Icons.assessment_rounded,
        label: 'Analytics',
        bgColor: const Color(0xFFEADBC8),
        iconColor: const Color(0xFFC05E41),
        onTap: () => AnalyticsFlowController.openWithPermissionCheck(context),
      ),
      DashboardItem(
        icon: Icons.badge_rounded,
        label: 'Employees',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
        onTap: () => _openLiveAttendance(context),
      ),
      DashboardItem(
        icon: Icons.assignment_rounded,
        label: 'Projects & Tasks',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProjectAndTaskOptionsScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        icon: Icons.share_rounded,
        label: 'Share',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ShareDashboardMobileScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        icon: Icons.handshake_rounded,
        label: 'Clients',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
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
      ),
      DashboardItem(
        icon: Icons.inventory_2_rounded,
        label: 'Assets & Resources',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
      ),
      DashboardItem(
        icon: Icons.event_busy_rounded,
        label: 'Leave Management',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LeaveManagerMobileScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        icon: Icons.receipt_long_rounded,
        label: 'Billing & Invoices',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
        onTap: () => BillingFlowController.start(context),
      ),
      DashboardItem(
        icon: Icons.payments_rounded,
        label: 'Payroll',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
        onTap: () => PayrollFlowController.openWithPermissionCheck(context),
      ),
      DashboardItem(
        icon: Icons.groups_3_rounded,
        label: 'Leads',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
      ),
      DashboardItem(
        icon: Icons.event_available_rounded,
        label: 'Events',
        bgColor: palette[colorIdx++],
        iconColor: getContrast(palette[colorIdx - 1]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CalendarScreenMobile(),
            ),
          );
        },
      ),
    ];

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
          employees: employees,
          totalEmployeeCount: totalEmployeeCount,
        ),
      ),
    );
  }
}
