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
import '../../models/payroll_merged_row.dart';
import '../../theme/payroll_mobile_theme.dart';
import '../../widget/payroll_table_section_mobile.dart';
import 'payroll_mobile_filters.dart';

String _fmtInt(int n) => NumberFormat('#,##0', 'en_IN').format(n);

String _fmtMoney(double n) {
  if (n <= 0) return '—';
  return '₹${NumberFormat('#,##,###', 'en_IN').format(n.round())}';
}

double _parseAmount(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(cleaned) ?? 0;
}

class PayrollMobileDashboard extends StatefulWidget {
  const PayrollMobileDashboard({super.key});

  @override
  State<PayrollMobileDashboard> createState() => _PayrollMobileDashboardState();
}

class _PayrollMobileDashboardState extends State<PayrollMobileDashboard> {
  final Set<int> _selectedIds = {};

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
      backgroundColor: PayrollMobileTheme.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<PayrollDashboardBloc, PayrollDashboardState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PayrollMobileHeader(
                  state: state,
                  onBack: () => _goBack(context),
                ),
                if (state.loadStatus == PayrollDashboardLoadStatus.loading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: PayrollMobileTheme.terracotta,
                    backgroundColor: Colors.transparent,
                  ),
                Expanded(
                  child: RefreshIndicator(
                    color: PayrollMobileTheme.terracotta,
                    onRefresh: () async {
                      context
                          .read<PayrollDashboardBloc>()
                          .add(const PayrollDashboardRefreshed());
                      await Future<void>.delayed(
                        const Duration(milliseconds: 400),
                      );
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: _SummaryStrip(
                              dashboard: state.dashboard,
                              rows: state.allTableRows,
                            ),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: PayrollMobileFiltersColumn(),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            14,
                            16,
                            MediaQuery.paddingOf(context).bottom + 24,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: PayrollTableMobile(
                              selectedIds: _selectedIds,
                              onSelectionChanged: (ids) {
                                setState(() {
                                  _selectedIds
                                    ..clear()
                                    ..addAll(ids);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PayrollMobileHeader extends StatelessWidget {
  const _PayrollMobileHeader({
    required this.state,
    required this.onBack,
  });

  final PayrollDashboardState state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final m = state.monthIndex.clamp(1, 12);
    final period = '${DateFormat('MMMM').format(DateTime(state.year, m))} ${state.year}';
    final eligible = state.dashboard.totalEligibleUsers ?? state.dashboard.totalEmployees;
    final headcount = eligible == 0
        ? (state.dashboard.paidRecordsCount + state.dashboard.totalPending)
        : eligible;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: PayrollMobileTheme.card,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PayrollMobileTheme.border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: PayrollMobileTheme.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payroll',
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: PayrollMobileTheme.textDark,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$period • $headcount staff',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PayrollMobileTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _MonthPill(
            month: m,
            onTap: () => _showPeriodSheet(context),
          ),
        ],
      ),
    );
  }

  void _showPeriodSheet(BuildContext context) {
    final bloc = context.read<PayrollDashboardBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PayrollMobileTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<PayrollDashboardBloc, PayrollDashboardState>(
            builder: (context, st) {
            final selectedMonth = st.monthIndex.clamp(1, 12);
            final years = List.generate(6, (i) => DateTime.now().year - i);

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                28 + MediaQuery.paddingOf(sheetCtx).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: PayrollMobileTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select period',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: PayrollMobileTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Year',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: PayrollMobileTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: years.map((y) {
                      final selected = y == st.year;
                      return GestureDetector(
                        onTap: () {
                          if (y != st.year) {
                            context
                                .read<PayrollDashboardBloc>()
                                .add(PayrollDashboardYearChanged(y));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? PayrollMobileTheme.terracotta
                                : PayrollMobileTheme.segmentBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? PayrollMobileTheme.terracotta
                                  : PayrollMobileTheme.border,
                            ),
                          ),
                          child: Text(
                            '$y',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? Colors.white
                                  : PayrollMobileTheme.textDark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Month',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: PayrollMobileTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.4,
                    ),
                    itemCount: 12,
                    itemBuilder: (_, i) {
                      final m = i + 1;
                      final selected = m == selectedMonth;
                      final label = DateFormat('MMM').format(DateTime(2024, m));
                      return Material(
                        color: selected
                            ? PayrollMobileTheme.terracotta
                            : PayrollMobileTheme.segmentBg,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            final bloc = context.read<PayrollDashboardBloc>();
                            if (m != selectedMonth) {
                              bloc.add(PayrollDashboardMonthChanged(m));
                            }
                            Navigator.of(sheetCtx).pop();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? PayrollMobileTheme.terracotta
                                    : PayrollMobileTheme.border,
                              ),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                color: selected
                                    ? Colors.white
                                    : PayrollMobileTheme.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
            },
          ),
        );
      },
    );
  }
}

class _MonthPill extends StatelessWidget {
  const _MonthPill({required this.month, required this.onTap});

  final int month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMM').format(DateTime(2024, month));
    return Material(
      color: PayrollMobileTheme.terracotta,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.dashboard,
    required this.rows,
  });

  final PayrollDashboardModel dashboard;
  final List<PayrollMergedRow> rows;

  double _sumAmount(bool? paidFilter) {
    return rows
        .where((r) => paidFilter == null || r.paid == paidFilter)
        .fold<double>(0, (sum, r) {
      final n = _parseAmount(r.amountRaw);
      return sum + n;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eligible = dashboard.totalEligibleUsers ?? dashboard.totalEmployees;
    final headcount = eligible == 0
        ? (dashboard.paidRecordsCount + dashboard.totalPending)
        : eligible;
    final hasRows = rows.isNotEmpty;
    final pendingAmt = hasRows ? _sumAmount(false) : 0.0;
    final paidAmt = hasRows ? _sumAmount(true) : 0.0;
    final paidLabel = hasRows && paidAmt > 0
        ? _fmtMoney(paidAmt)
        : dashboard.totalPaidAmount.replaceAll(r'$', '₹');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: PayrollMobileTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PayrollMobileTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              value: _fmtInt(headcount),
              label: 'HEADCOUNT',
              valueColor: PayrollMobileTheme.textDark,
            ),
          ),
          Container(width: 1, height: 40, color: PayrollMobileTheme.border),
          Expanded(
            child: _Metric(
              value: hasRows ? _fmtMoney(pendingAmt) : '—',
              label: 'PENDING',
              valueColor: PayrollMobileTheme.terracotta,
            ),
          ),
          Container(width: 1, height: 40, color: PayrollMobileTheme.border),
          Expanded(
            child: _Metric(
              value: hasRows && paidAmt > 0 ? paidLabel : (hasRows ? '—' : paidLabel),
              label: 'DISBURSED',
              valueColor: PayrollMobileTheme.paidGreenDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: PayrollMobileTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
