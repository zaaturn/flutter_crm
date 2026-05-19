import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/admin_dashboard_mobile.dart';

import '../../bloc/payroll_dashboard_bloc.dart';
import '../../bloc/payroll_dashboard_event.dart';
import '../../bloc/payroll_dashboard_state.dart';
import '../../models/payroll_dashboard_model.dart';
import '../../widget/payroll_table_section_mobile.dart';
import 'payroll_mobile_filters.dart';

class ZaaturnTheme {
  static const Color background = Color(0xFFFAF3E0);
  static const Color cardGreen = Color(0xFFD0F4E0);
  static const Color cardYellow = Color(0xFFFCF5BF);
  static const Color cardPink = Color(0xFFFF99C8);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color headerBlue = Color(0xFF0D47A1);
  static const Color terracottaAccent = Color(0xFFC05E41);
}

class PayrollMobileDashboard extends StatelessWidget {
  const PayrollMobileDashboard({super.key});

  static String _fmt(int n) => NumberFormat('#,##0', 'en_US').format(n);

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    final narrow = MediaQuery.sizeOf(context).width < 900;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
        narrow ? const AdminDashboardMobile() : const AdminDashboardDesktop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZaaturnTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PayrollMobileTopBar(onBack: () => _goBack(context)),
            Expanded(
              child: BlocBuilder<PayrollDashboardBloc, PayrollDashboardState>(
                builder: (context, state) {
                  return RefreshIndicator(
                    color: ZaaturnTheme.terracottaAccent,
                    onRefresh: () async {
                      context
                          .read<PayrollDashboardBloc>()
                          .add(const PayrollDashboardRefreshed());
                      await Future<void>.delayed(const Duration(milliseconds: 400));
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (state.loadStatus == PayrollDashboardLoadStatus.loading)
                          const SliverToBoxAdapter(
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(ZaaturnTheme.terracottaAccent),
                            ),
                          ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            8,
                            0,
                            16 + MediaQuery.paddingOf(context).bottom,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _MobileKpiStack(dashboard: state.dashboard),
                              const SizedBox(height: 14),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: PayrollMobileFiltersColumn(),
                              ),
                              const SizedBox(height: 14),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: PayrollTableMobile(),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayrollMobileTopBar extends StatelessWidget {
  const _PayrollMobileTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: Colors.blueAccent,
          ),
          Text(
            'Payroll',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ZaaturnTheme.headerBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileKpiStack extends StatelessWidget {
  const _MobileKpiStack({required this.dashboard});

  final PayrollDashboardModel dashboard;

  @override
  Widget build(BuildContext context) {
    final eligible = dashboard.totalEligibleUsers ?? dashboard.totalEmployees;
    final displayHeadcount = (eligible == 0)
        ? (dashboard.paidRecordsCount + dashboard.totalPending)
        : eligible;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _CompactKpiCard(
            title: 'TOTAL HEADCOUNT',
            value: PayrollMobileDashboard._fmt(displayHeadcount),
            meta: 'Total registered staff',
            icon: Icons.badge_outlined,
            color: ZaaturnTheme.cardGreen,
          ),
          const SizedBox(width: 12),
          _CompactKpiCard(
            title: 'TOTAL PAID',
            value: PayrollMobileDashboard._fmt(dashboard.paidRecordsCount),
            meta: 'Monthly disbursement',
            icon: Icons.payments_outlined,
            color: ZaaturnTheme.cardYellow,
          ),
          const SizedBox(width: 12),
          _CompactKpiCard(
            title: 'UNSET / PENDING',
            value: PayrollMobileDashboard._fmt(dashboard.unsetCount ?? dashboard.totalPending),
            meta: 'Awaiting processing',
            icon: Icons.hourglass_top_rounded,
            color: ZaaturnTheme.cardPink,
          ),
        ],
      ),
    );
  }
}

class _CompactKpiCard extends StatelessWidget {
  const _CompactKpiCard({
    required this.title,
    required this.value,
    required this.meta,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String meta;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * 0.45;

    return Container(
      width: cardWidth,
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: ZaaturnTheme.textDark.withOpacity(0.6)),
              Icon(Icons.info_outline_rounded, size: 14, color: ZaaturnTheme.textDark.withOpacity(0.3)),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1,
              color: ZaaturnTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: ZaaturnTheme.textDark.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: ZaaturnTheme.textDark.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}