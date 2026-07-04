import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/payroll_dashboard_bloc.dart';
import '../../bloc/payroll_dashboard_event.dart';
import '../../bloc/payroll_dashboard_state.dart';
import '../../models/payroll_records_paid_filter.dart';
import '../../theme/payroll_mobile_theme.dart';

class PayrollMobileFiltersColumn extends StatefulWidget {
  const PayrollMobileFiltersColumn({super.key});

  @override
  State<PayrollMobileFiltersColumn> createState() =>
      _PayrollMobileFiltersColumnState();
}

class _PayrollMobileFiltersColumnState extends State<PayrollMobileFiltersColumn> {
  final _searchCtrl = TextEditingController();
  String _lastSyncedSearch = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _syncSearchField(String query) {
    if (_lastSyncedSearch == query) return;
    _lastSyncedSearch = query;
    if (_searchCtrl.text != query) {
      _searchCtrl.text = query;
    }
  }

  void _applySearch(BuildContext context) {
    final bloc = context.read<PayrollDashboardBloc>();
    if (bloc.state.loadStatus == PayrollDashboardLoadStatus.loading) return;
    bloc.add(PayrollDashboardSearchSubmitted(_searchCtrl.text.trim()));
  }

  void _applyStatusFilter(
    BuildContext context,
    PayrollRecordsPaidFilter filter,
  ) {
    final bloc = context.read<PayrollDashboardBloc>();
    if (bloc.state.loadStatus == PayrollDashboardLoadStatus.loading) return;
    if (bloc.state.recordsPaidFilter == filter) return;
    bloc.add(PayrollRecordsPaidFilterChanged(filter));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PayrollDashboardBloc, PayrollDashboardState>(
      listenWhen: (p, c) =>
          p.searchQuery != c.searchQuery ||
          p.monthIndex != c.monthIndex ||
          p.year != c.year,
      listener: (context, state) => _syncSearchField(state.searchQuery),
      builder: (context, state) {
        _syncSearchField(state.searchQuery);

        final loading = state.loadStatus == PayrollDashboardLoadStatus.loading;
        final rows = state.allTableRows;
        final allCount = rows.length;
        final pendingCount = rows.where((r) => r.paid == false).length;
        final paidCount = rows.where((r) => r.paid == true).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: PayrollMobileTheme.terracotta,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _TabChip(
                    label: 'All',
                    count: allCount,
                    selected:
                        state.recordsPaidFilter == PayrollRecordsPaidFilter.all,
                    enabled: !loading,
                    onTap: () => _applyStatusFilter(
                      context,
                      PayrollRecordsPaidFilter.all,
                    ),
                  ),
                  _TabChip(
                    label: 'Pending',
                    count: pendingCount,
                    selected: state.recordsPaidFilter ==
                        PayrollRecordsPaidFilter.unpaid,
                    enabled: !loading,
                    onTap: () => _applyStatusFilter(
                      context,
                      PayrollRecordsPaidFilter.unpaid,
                    ),
                  ),
                  _TabChip(
                    label: 'Paid',
                    count: paidCount,
                    selected:
                        state.recordsPaidFilter == PayrollRecordsPaidFilter.paid,
                    enabled: !loading,
                    onTap: () => _applyStatusFilter(
                      context,
                      PayrollRecordsPaidFilter.paid,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              enabled: !loading,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _applySearch(context),
              onChanged: (v) {
                setState(() {});
                if (v.trim().isEmpty && state.searchQuery.isNotEmpty) {
                  _applySearch(context);
                }
              },
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: PayrollMobileTheme.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Search name or email',
                hintStyle: GoogleFonts.manrope(
                  color: PayrollMobileTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: PayrollMobileTheme.card,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: PayrollMobileTheme.textMuted,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: PayrollMobileTheme.textMuted,
                        onPressed: loading
                            ? null
                            : () {
                                _searchCtrl.clear();
                                _applySearch(context);
                              },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: PayrollMobileTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: PayrollMobileTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: PayrollMobileTheme.terracotta,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? PayrollMobileTheme.card
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: selected
                      ? PayrollMobileTheme.terracotta
                      : PayrollMobileTheme.onTerracotta,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? PayrollMobileTheme.terracotta.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? PayrollMobileTheme.terracotta
                        : PayrollMobileTheme.onTerracotta,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
