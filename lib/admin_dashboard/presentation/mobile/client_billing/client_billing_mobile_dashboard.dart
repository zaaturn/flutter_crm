import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_cubit.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_state.dart';
import 'package:my_app/admin_dashboard/model/client_dashboard_summary_models.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/admin_dashboard_mobile.dart';

import 'client_billing_mobile_filters.dart';
import 'client_billing_mobile_theme.dart';
import 'client_billing_table_mobile.dart';

class ClientBillingMobileDashboard extends StatefulWidget {
  const ClientBillingMobileDashboard({
    super.key,
    this.embeddedInShell = false,
  });

  /// When true, hides back navigation (used inside Client Tracker BILLING tab).
  final bool embeddedInShell;

  @override
  State<ClientBillingMobileDashboard> createState() =>
      _ClientBillingMobileDashboardState();
}

class _ClientBillingMobileDashboardState
    extends State<ClientBillingMobileDashboard> {
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
    final bottomPad = widget.embeddedInShell ? 100.0 : 24.0;

    return BlocListener<ClientDashboardSummaryCubit,
        ClientDashboardSummaryState>(
      listenWhen: (p, c) => p.toastError != c.toastError,
      listener: (context, state) {
        final msg = state.toastError;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: ClientBillingMobileTheme.terracotta,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ClientBillingMobileTheme.background,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<ClientDashboardSummaryCubit,
              ClientDashboardSummaryState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ClientBillingMobileHeader(
                    state: state,
                    embeddedInShell: widget.embeddedInShell,
                    onBack: () => _goBack(context),
                  ),
                if (state.isLoading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: ClientBillingMobileTheme.terracotta,
                    backgroundColor: Colors.transparent,
                  ),
                Expanded(
                  child: RefreshIndicator(
                    color: ClientBillingMobileTheme.terracotta,
                    onRefresh: () async {
                      await context
                          .read<ClientDashboardSummaryCubit>()
                          .load(showLoading: false);
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: _SummaryStrip(summary: state.summary),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: ClientBillingMobileFiltersColumn(),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            14,
                            16,
                            MediaQuery.paddingOf(context).bottom + bottomPad,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: ClientBillingTableMobile(
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
    ),
    );
  }
}

class _ClientBillingMobileHeader extends StatelessWidget {
  const _ClientBillingMobileHeader({
    required this.state,
    required this.onBack,
    this.embeddedInShell = false,
  });

  final ClientDashboardSummaryState state;
  final VoidCallback onBack;
  final bool embeddedInShell;

  @override
  Widget build(BuildContext context) {
    final m = state.month.clamp(1, 12);
    final period =
        '${DateFormat('MMMM').format(DateTime(state.year, m))} ${state.year}';
    final total = state.summary.totalClients;
    final title = embeddedInShell ? 'Billing' : 'Client Billing';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!embeddedInShell) ...[
            Material(
              color: ClientBillingMobileTheme.card,
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
                    border: Border.all(color: ClientBillingMobileTheme.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: ClientBillingMobileTheme.textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ] else
            const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: embeddedInShell ? 24 : 26,
                    fontWeight: FontWeight.w900,
                    color: ClientBillingMobileTheme.textDark,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$period • $total clients',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ClientBillingMobileTheme.textMuted,
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
    final cubit = context.read<ClientDashboardSummaryCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ClientBillingMobileTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<ClientDashboardSummaryCubit,
              ClientDashboardSummaryState>(
            builder: (context, st) {
              final selectedMonth = st.month.clamp(1, 12);
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
                          color: ClientBillingMobileTheme.border,
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
                        color: ClientBillingMobileTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Year',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ClientBillingMobileTheme.textMuted,
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
                                  .read<ClientDashboardSummaryCubit>()
                                  .setYear(y);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? ClientBillingMobileTheme.terracotta
                                  : ClientBillingMobileTheme.segmentBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? ClientBillingMobileTheme.terracotta
                                    : ClientBillingMobileTheme.border,
                              ),
                            ),
                            child: Text(
                              '$y',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                color: selected
                                    ? Colors.white
                                    : ClientBillingMobileTheme.textDark,
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
                        color: ClientBillingMobileTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.4,
                      ),
                      itemCount: 12,
                      itemBuilder: (_, i) {
                        final month = i + 1;
                        final selected = month == selectedMonth;
                        final label =
                            DateFormat('MMM').format(DateTime(2024, month));
                        return Material(
                          color: selected
                              ? ClientBillingMobileTheme.terracotta
                              : ClientBillingMobileTheme.segmentBg,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              if (month != selectedMonth) {
                                context
                                    .read<ClientDashboardSummaryCubit>()
                                    .setMonth(month);
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
                                      ? ClientBillingMobileTheme.terracotta
                                      : ClientBillingMobileTheme.border,
                                ),
                              ),
                              child: Text(
                                label,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? Colors.white
                                      : ClientBillingMobileTheme.textDark,
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
      color: ClientBillingMobileTheme.terracotta,
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
  const _SummaryStrip({required this.summary});

  final ClientDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final total = summary.totalClients;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: ClientBillingMobileTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ClientBillingMobileTheme.border),
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
              value: '$total',
              label: 'CLIENTS',
              valueColor: ClientBillingMobileTheme.textDark,
            ),
          ),
          Container(width: 1, height: 40, color: ClientBillingMobileTheme.border),
          Expanded(
            child: _Metric(
              value: '${summary.invoicesSentCount}',
              label: 'INV SENT',
              valueColor: ClientBillingMobileTheme.successDark,
            ),
          ),
          Container(width: 1, height: 40, color: ClientBillingMobileTheme.border),
          Expanded(
            child: _Metric(
              value: '${summary.paymentsReceivedCount}',
              label: 'PAID',
              valueColor: ClientBillingMobileTheme.successDark,
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
            color: ClientBillingMobileTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
