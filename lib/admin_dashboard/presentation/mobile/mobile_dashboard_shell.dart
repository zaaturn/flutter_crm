import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/presentation/mobile/mobile_dashboard_home_tab.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/admin_top_bar_mobile.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/bottom_nav.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/employee_list_screen_mobile.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_menu_config_desktop.dart';
import 'package:my_app/analytics/navigation/analytics_flow_controller.dart';
import 'package:my_app/asset_management/navigation/asset_flow_controller.dart';
import 'package:my_app/auth/admin_landing.dart';
import 'package:my_app/billing/navigation/billing_flow_controller.dart';
import 'package:my_app/client tracker/core/layout/app_shell.dart';
import 'package:my_app/client tracker/features/clients/bloc/client_bloc.dart';
import 'package:my_app/client tracker/features/clients/repository/client_repository.dart';
import 'package:my_app/client tracker/features/payment/bloc/payment_bloc.dart';
import 'package:my_app/client tracker/features/payment/repository/payment_repository.dart';
import 'package:my_app/dashboards/presentations/screens/content_management_page.dart';
import 'package:my_app/event_management/shared/widgets/event_management_shell.dart';
import 'package:my_app/payroll/navigation/payroll_flow_controller.dart';
import 'package:my_app/screens/device_specific/profile_screen_mobile.dart';

/// Mobile admin shell — bottom nav + module grid home tab.
class MobileDashboardShell extends StatefulWidget {
  const MobileDashboardShell({super.key});

  @override
  State<MobileDashboardShell> createState() => _MobileDashboardShellState();
}

class _MobileDashboardShellState extends State<MobileDashboardShell> {
  int _selectedIndex = 0;
  bool _openedLandingModule = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openLandingIfNeeded());
  }

  Future<void> _openLandingIfNeeded() async {
    if (_openedLandingModule || !mounted) return;
    final pending = AdminLandingIntent.takePending();
    if (pending == null) return;
    _openedLandingModule = true;
    await _openModule(pending);
  }

  Future<void> _openModule(SidebarAction action) async {
    if (!mounted) return;
    switch (action) {
      case SidebarAction.analytics:
        await AnalyticsFlowController.openWithPermissionCheck(context);
      case SidebarAction.assets:
        await AssetFlowController.openAdmin(context);
      case SidebarAction.client:
        await Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ClientBloc(ClientRepository())),
                BlocProvider(create: (_) => PaymentBloc(PaymentRepository())),
              ],
              child: const AppShell(),
            ),
          ),
        );
      case SidebarAction.share:
        await Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute(builder: (_) => const ContentManagementPage()),
        );
      case SidebarAction.billingGenerate:
        await BillingFlowController.start(context);
      case SidebarAction.payroll:
        await PayrollFlowController.openWithPermissionCheck(context);
      case SidebarAction.events:
        await Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute(builder: (_) => const EventManagementShell()),
        );
      case SidebarAction.employees:
        setState(() => _selectedIndex = 1);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AdminMobileTerracottaTheme.cream,
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              MobileDashboardHomeTab(state: state),
              EmployeeListScreenMobile(
                onBack: () => setState(() => _selectedIndex = 0),
              ),
              _buildPlaceholder('Logs'),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: BottomNav(
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}
