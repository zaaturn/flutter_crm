import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_cubit.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_state.dart';
import 'package:my_app/admin_dashboard/model/client_dashboard_summary_models.dart';

import 'client_billing_mobile_theme.dart';

enum ClientBillingQuickFilter { all, invoicePending, paymentPending }

ClientBillingQuickFilter quickFilterFromState(ClientDashboardSummaryState state) {
  if (state.invoiceFilter == TriStateFilter.pending &&
      state.paymentFilter == TriStateFilter.all) {
    return ClientBillingQuickFilter.invoicePending;
  }
  if (state.paymentFilter == TriStateFilter.pending &&
      state.invoiceFilter == TriStateFilter.all) {
    return ClientBillingQuickFilter.paymentPending;
  }
  return ClientBillingQuickFilter.all;
}

class ClientBillingMobileFiltersColumn extends StatefulWidget {
  const ClientBillingMobileFiltersColumn({super.key});

  @override
  State<ClientBillingMobileFiltersColumn> createState() =>
      _ClientBillingMobileFiltersColumnState();
}

class _ClientBillingMobileFiltersColumnState
    extends State<ClientBillingMobileFiltersColumn> {
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
    final cubit = context.read<ClientDashboardSummaryCubit>();
    if (cubit.state.isLoading) return;
    cubit.setSearch(_searchCtrl.text.trim());
  }

  void _applyQuickFilter(
    BuildContext context,
    ClientBillingQuickFilter filter,
  ) {
    final cubit = context.read<ClientDashboardSummaryCubit>();
    if (cubit.state.isLoading) return;
    if (quickFilterFromState(cubit.state) == filter) return;

    switch (filter) {
      case ClientBillingQuickFilter.all:
        cubit.applyFilters(
          invoiceFilter: TriStateFilter.all,
          paymentFilter: TriStateFilter.all,
        );
      case ClientBillingQuickFilter.invoicePending:
        cubit.applyFilters(
          invoiceFilter: TriStateFilter.pending,
          paymentFilter: TriStateFilter.all,
        );
      case ClientBillingQuickFilter.paymentPending:
        cubit.applyFilters(
          invoiceFilter: TriStateFilter.all,
          paymentFilter: TriStateFilter.pending,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientDashboardSummaryCubit, ClientDashboardSummaryState>(
      listenWhen: (p, c) =>
          p.search != c.search || p.month != c.month || p.year != c.year,
      listener: (context, state) => _syncSearchField(state.search),
      builder: (context, state) {
        _syncSearchField(state.search);

        final loading = state.isLoading;
        final summary = state.summary;
        final active = quickFilterFromState(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ClientBillingMobileTheme.segmentBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _TabChip(
                    label: 'All',
                    count: summary.totalClients,
                    selected: active == ClientBillingQuickFilter.all,
                    enabled: !loading,
                    onTap: () => _applyQuickFilter(
                      context,
                      ClientBillingQuickFilter.all,
                    ),
                  ),
                  _TabChip(
                    label: 'Inv Pend',
                    count: summary.invoicesPendingCount,
                    selected: active == ClientBillingQuickFilter.invoicePending,
                    enabled: !loading,
                    onTap: () => _applyQuickFilter(
                      context,
                      ClientBillingQuickFilter.invoicePending,
                    ),
                  ),
                  _TabChip(
                    label: 'Pay Pend',
                    count: summary.paymentsPendingCount,
                    selected: active == ClientBillingQuickFilter.paymentPending,
                    enabled: !loading,
                    onTap: () => _applyQuickFilter(
                      context,
                      ClientBillingQuickFilter.paymentPending,
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
                if (v.trim().isEmpty && state.search.isNotEmpty) {
                  _applySearch(context);
                }
              },
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: ClientBillingMobileTheme.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Search client or email',
                hintStyle: GoogleFonts.manrope(
                  color: ClientBillingMobileTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: ClientBillingMobileTheme.card,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: ClientBillingMobileTheme.textMuted,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: ClientBillingMobileTheme.textMuted,
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
                  borderSide:
                      const BorderSide(color: ClientBillingMobileTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: ClientBillingMobileTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: ClientBillingMobileTheme.terracotta,
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
            color: selected ? ClientBillingMobileTheme.card : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
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
                      ? ClientBillingMobileTheme.textDark
                      : ClientBillingMobileTheme.textMuted,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? ClientBillingMobileTheme.terracotta
                          .withValues(alpha: 0.12)
                      : ClientBillingMobileTheme.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? ClientBillingMobileTheme.terracotta
                        : ClientBillingMobileTheme.textMuted,
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
