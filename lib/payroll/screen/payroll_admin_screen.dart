import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/leave_management/screens/mobile_screen/widget/leave_manager_colors.dart';

import '../bloc/payroll_dashboard_bloc.dart';
import '../bloc/payroll_dashboard_event.dart';
import '../bloc/payroll_dashboard_state.dart';
import '../widget/payroll_header.dart';
import '../widget/payroll_kpi_cards.dart';
import '../widget/payroll_sidebar.dart';
import '../widget/payroll_filter_section.dart';
import '../widget/payroll_table_section.dart';
import 'mobile_screen/payroll_mobile_dashboard.dart';


class WorkspaceTheme {
  static const Color scaffoldBg = Color(0xFFFBFBFE);
  static const Color primaryPurple = Color(0xFF6F34DC);
  static const Color cardSurface = Colors.white;
  static const Color borderSubtle = Color(0xFFE8E9F1);
  static const Color textMain = Color(0xFF1E1E24);
}

class PayrollAdminScreen extends StatelessWidget {
  const PayrollAdminScreen({super.key});

  static const double _lgBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PayrollDashboardBloc, PayrollDashboardState>(
      listenWhen: (p, c) => p.errorMessage != c.errorMessage,
      listener: (context, state) {
        final msg = state.errorMessage;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: WorkspaceTheme.textMain,
              content: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          );
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= _lgBreakpoint;

            if (!wide) {
              return Theme(
                data: Theme.of(context).copyWith(
                  scaffoldBackgroundColor: LeaveManagerColors.background,
                  textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
                ),
                child: const Scaffold(
                  backgroundColor: LeaveManagerColors.background,
                  body: PayrollMobileDashboard(),
                ),
              );
            }

            return Theme(
              data: Theme.of(context).copyWith(
                scaffoldBackgroundColor: WorkspaceTheme.scaffoldBg,
                textTheme: GoogleFonts.interTextTheme(),
              ),
              child: Scaffold(
                body: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PayrollSidebar(),
                    const VerticalDivider(
                      width: 1,
                      color: WorkspaceTheme.borderSubtle,
                    ),
                    Expanded(
                      child: _MainColumn(
                        showDrawerBtn: false,
                        state: state,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn({
    required this.showDrawerBtn,
    required this.state,
  });

  final bool showDrawerBtn;
  final PayrollDashboardState state;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 600;
    final hPad = compact ? 12.0 : 24.0;
    final vPad = compact ? 16.0 : 32.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        if (showDrawerBtn)
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: WorkspaceTheme.cardSurface,
              border: Border(bottom: BorderSide(color: WorkspaceTheme.borderSubtle)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  color: WorkspaceTheme.textMain,
                ),
                Text(
                  'Payroll Dashboard',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: WorkspaceTheme.textMain,
                  ),
                ),
              ],
            ),
          ),


        PayrollHeader(showTitle: !showDrawerBtn),

        // Content Area
        Expanded(
          child: RefreshIndicator(
            color: WorkspaceTheme.primaryPurple,
            onRefresh: () async {
              context.read<PayrollDashboardBloc>().add(const PayrollDashboardRefreshed());

            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      if (state.loadStatus == PayrollDashboardLoadStatus.loading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                            child: LinearProgressIndicator(
                              minHeight: 3,
                              backgroundColor: WorkspaceTheme.borderSubtle,
                              valueColor: AlwaysStoppedAnimation<Color>(WorkspaceTheme.primaryPurple),
                            ),
                          ),
                        ),


                      PayrollKpiCards(dashboard: state.dashboard),

                      const SizedBox(height: 32),


                      const PayrollFilterSection(),

                      const SizedBox(height: 32),

                      // Main Data Table
                      const PayrollTableSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}