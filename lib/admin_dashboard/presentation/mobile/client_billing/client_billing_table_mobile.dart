import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_cubit.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_state.dart';
import 'package:my_app/admin_dashboard/model/client_dashboard_summary_models.dart';

import 'client_billing_mobile_theme.dart';

const int _kBillingPageSize = 20;

class _BillingPageView {
  const _BillingPageView({
    required this.rows,
    required this.pagination,
    required this.useServerPaging,
  });

  final List<ClientSummaryRow> rows;
  final SummaryPagination pagination;
  final bool useServerPaging;
}

class ClientBillingTableMobile extends StatefulWidget {
  const ClientBillingTableMobile({
    super.key,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onSelectionChanged;

  @override
  State<ClientBillingTableMobile> createState() =>
      _ClientBillingTableMobileState();
}

class _ClientBillingTableMobileState extends State<ClientBillingTableMobile> {
  int _localPage = 0;

  _BillingPageView _resolvePaging(ClientDashboardSummaryState state) {
    final allRows = state.summary.results;
    final pageSize = state.pageSize.clamp(1, _kBillingPageSize);
    final apiPagination = state.summary.pagination;
    final total = apiPagination.total > 0
        ? apiPagination.total
        : state.summary.totalClients;

    final serverPaging = total > pageSize ||
        apiPagination.totalPages > 1 ||
        apiPagination.hasNext ||
        apiPagination.hasPrev ||
        state.page > 1;

    if (serverPaging) {
      final pagination = apiPagination.total > 0
          ? apiPagination
          : SummaryPagination.synthetic(
              page: state.page,
              pageSize: pageSize,
              total: total,
            );
      return _BillingPageView(
        rows: allRows,
        pagination: pagination,
        useServerPaging: true,
      );
    }

    if (allRows.length > _kBillingPageSize) {
      final pageCount = (allRows.length / _kBillingPageSize).ceil();
      final safePage = _localPage.clamp(0, pageCount - 1);
      if (safePage != _localPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _localPage = safePage);
        });
      }
      return _BillingPageView(
        rows: allRows
            .skip(safePage * _kBillingPageSize)
            .take(_kBillingPageSize)
            .toList(),
        pagination: SummaryPagination.synthetic(
          page: safePage + 1,
          pageSize: _kBillingPageSize,
          total: allRows.length,
        ),
        useServerPaging: false,
      );
    }

    return _BillingPageView(
      rows: allRows,
      pagination: apiPagination.total > 0
          ? apiPagination
          : SummaryPagination.synthetic(
              page: 1,
              pageSize: pageSize,
              total: allRows.length,
            ),
      useServerPaging: true,
    );
  }

  void _toggleSelect(int paymentRecordId) {
    final next = Set<int>.from(widget.selectedIds);
    if (next.contains(paymentRecordId)) {
      next.remove(paymentRecordId);
    } else {
      next.add(paymentRecordId);
    }
    widget.onSelectionChanged(next);
  }

  void _toggleSelectAllPage(List<ClientSummaryRow> pageRows) {
    final ids = pageRows.map((r) => r.paymentRecordId).toSet();
    final allSelected = ids.every(widget.selectedIds.contains);
    final next = Set<int>.from(widget.selectedIds);
    if (allSelected) {
      next.removeAll(ids);
    } else {
      next.addAll(ids);
    }
    widget.onSelectionChanged(next);
  }

  Future<void> _bulkMarkInvoiceSent() async {
    final cubit = context.read<ClientDashboardSummaryCubit>();
    await cubit.bulkMarkInvoiceSent(widget.selectedIds.toList());
    if (!mounted) return;
    widget.onSelectionChanged({});
  }

  Future<void> _bulkMarkPaymentReceived() async {
    final cubit = context.read<ClientDashboardSummaryCubit>();
    await cubit.bulkMarkPaymentReceived(widget.selectedIds.toList());
    if (!mounted) return;
    widget.onSelectionChanged({});
  }

  Future<void> _openClientSheet(ClientSummaryRow row) async {
    final cubit = context.read<ClientDashboardSummaryCubit>();
    if (!mounted) return;

    await showModalBottomSheet<void>(
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
            builder: (context, state) {
              final current = state.summary.results
                      .where((r) => r.paymentRecordId == row.paymentRecordId)
                      .firstOrNull ??
                  row;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  24 + MediaQuery.paddingOf(sheetCtx).bottom,
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
                    const SizedBox(height: 14),
                    Text(
                      current.displayName,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: ClientBillingMobileTheme.textDark,
                      ),
                    ),
                    if (current.email.isNotEmpty)
                      Text(
                        current.email,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: ClientBillingMobileTheme.textMuted,
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      'Invoice sent',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ClientBillingMobileTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _TriStateSegments(
                      value: current.invoiceSent,
                      isInvoice: true,
                      onChanged: (v) => cubit.setInvoiceSent(current, v),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment received',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ClientBillingMobileTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _TriStateSegments(
                      value: current.paymentReceived,
                      isInvoice: false,
                      onChanged: (v) => cubit.setPaymentReceived(current, v),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: ClientBillingMobileTheme.terracotta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientDashboardSummaryCubit,
        ClientDashboardSummaryState>(
      listenWhen: (p, c) =>
          p.month != c.month ||
          p.year != c.year ||
          p.search != c.search ||
          p.invoiceFilter != c.invoiceFilter ||
          p.paymentFilter != c.paymentFilter ||
          p.page != c.page,
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _localPage = 0);
          widget.onSelectionChanged({});
        });
      },
      child: BlocBuilder<ClientDashboardSummaryCubit,
          ClientDashboardSummaryState>(
        builder: (context, state) {
          final paging = _resolvePaging(state);
          final rows = paging.rows;
          final pagination = paging.pagination;
          final nextInvoiceLabel = DateFormat('MMM d').format(
            DateTime(state.year, state.month.clamp(1, 12), 1),
          );

          if (state.isLoading && rows.isEmpty) {
            return _emptyCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: ClientBillingMobileTheme.terracotta,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Loading clients…',
                    style: GoogleFonts.manrope(
                      color: ClientBillingMobileTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.error != null && rows.isEmpty) {
            return _emptyCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: ClientBillingMobileTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context
                        .read<ClientDashboardSummaryCubit>()
                        .load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!state.isLoading && rows.isEmpty) {
            return _emptyCard(
              child: Text(
                'No clients found.',
                style: GoogleFonts.manrope(
                  color: ClientBillingMobileTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final pageIds = rows.map((r) => r.paymentRecordId).toSet();
          final allPageSelected =
              rows.isNotEmpty && pageIds.every(widget.selectedIds.contains);
          final hasBulk = widget.selectedIds.isNotEmpty;
          final cubit = context.read<ClientDashboardSummaryCubit>();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
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
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 14, 10, 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              value: allPageSelected,
                              tristate: true,
                              activeColor: ClientBillingMobileTheme.terracotta,
                              side: const BorderSide(
                                color: ClientBillingMobileTheme.border,
                              ),
                              onChanged: rows.isEmpty
                                  ? null
                                  : (_) => _toggleSelectAllPage(rows),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'CLIENT',
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: ClientBillingMobileTheme.textMuted,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 52,
                            child: Text(
                              'NEXT INV',
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: ClientBillingMobileTheme.textMuted,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 58,
                            child: Text(
                              'SENT',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: ClientBillingMobileTheme.textMuted,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 58,
                            child: Text(
                              'PAID',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: ClientBillingMobileTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasBulk)
                      _BulkActionBar(
                        count: widget.selectedIds.length,
                        onClear: () => widget.onSelectionChanged({}),
                        onMarkInvoiceSent: _bulkMarkInvoiceSent,
                        onMarkPaymentReceived: _bulkMarkPaymentReceived,
                      ),
                    const Divider(height: 1, color: ClientBillingMobileTheme.border),
                    ...rows.asMap().entries.map((entry) {
                      final row = entry.value;
                      final isLast = entry.key == rows.length - 1;
                      final selected =
                          widget.selectedIds.contains(row.paymentRecordId);
                      final invoiceKey = '${row.paymentRecordId}_invoice';
                      final paymentKey = '${row.paymentRecordId}_payment';
                      final updatingInvoice =
                          state.updatingCellKey == invoiceKey;
                      final updatingPayment =
                          state.updatingCellKey == paymentKey;

                      return Column(
                        children: [
                          _ClientRow(
                            row: row,
                            selected: selected,
                            nextInvoiceLabel: nextInvoiceLabel,
                            flashInvoice: state.flashCellKey == invoiceKey,
                            flashPayment: state.flashCellKey == paymentKey,
                            updatingInvoice: updatingInvoice,
                            updatingPayment: updatingPayment,
                            onSelectChanged: () =>
                                _toggleSelect(row.paymentRecordId),
                            onNameTap: () => _openClientSheet(row),
                            onInvoiceTap: updatingInvoice
                                ? null
                                : () => cubit.toggleInvoice(row),
                            onPaymentTap: updatingPayment
                                ? null
                                : () => cubit.togglePayment(row),
                          ),
                          if (!isLast)
                            const Divider(
                              height: 1,
                              color: ClientBillingMobileTheme.border,
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              if (pagination.totalPages > 1) ...[
                const SizedBox(height: 12),
                _PaginationBar(
                  pagination: pagination,
                  onPrev: pagination.hasPrev
                      ? () {
                          if (paging.useServerPaging) {
                            cubit.setPage(pagination.page - 1);
                          } else {
                            setState(() => _localPage -= 1);
                          }
                        }
                      : null,
                  onNext: pagination.hasNext
                      ? () {
                          if (paging.useServerPaging) {
                            cubit.setPage(pagination.page + 1);
                          } else {
                            setState(() => _localPage += 1);
                          }
                        }
                      : null,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _emptyCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: ClientBillingMobileTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ClientBillingMobileTheme.border),
      ),
      child: Center(child: child),
    );
  }
}

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({
    required this.count,
    required this.onClear,
    required this.onMarkInvoiceSent,
    required this.onMarkPaymentReceived,
  });

  final int count;
  final VoidCallback onClear;
  final VoidCallback onMarkInvoiceSent;
  final VoidCallback onMarkPaymentReceived;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      color: ClientBillingMobileTheme.terracotta.withValues(alpha: 0.08),
      child: Row(
        children: [
          Text(
            '$count selected',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: ClientBillingMobileTheme.textDark,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClear,
            child: Text(
              'Clear',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: ClientBillingMobileTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 4),
          FilledButton.tonal(
            onPressed: onMarkInvoiceSent,
            style: FilledButton.styleFrom(
              backgroundColor:
                  ClientBillingMobileTheme.terracotta.withValues(alpha: 0.15),
              foregroundColor: ClientBillingMobileTheme.terracotta,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: Text(
              'Mark sent',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          FilledButton(
            onPressed: onMarkPaymentReceived,
            style: FilledButton.styleFrom(
              backgroundColor: ClientBillingMobileTheme.terracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: Text(
              'Mark paid',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.pagination,
    required this.onPrev,
    required this.onNext,
  });

  final SummaryPagination pagination;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ClientBillingMobileTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ClientBillingMobileTheme.border),
      ),
      child: Row(
        children: [
          _PageBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Expanded(
            child: Text(
              pagination.total == 0
                  ? 'No clients'
                  : '${pagination.rangeStart}–${pagination.rangeEnd} of ${pagination.total}',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ClientBillingMobileTheme.textMuted,
              ),
            ),
          ),
          Text(
            '${pagination.page}/${pagination.totalPages}',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: ClientBillingMobileTheme.textDark,
            ),
          ),
          _PageBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null
          ? ClientBillingMobileTheme.segmentBg.withValues(alpha: 0.5)
          : ClientBillingMobileTheme.segmentBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 22,
            color: onTap == null
                ? ClientBillingMobileTheme.border
                : ClientBillingMobileTheme.terracotta,
          ),
        ),
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  const _ClientRow({
    required this.row,
    required this.selected,
    required this.nextInvoiceLabel,
    required this.flashInvoice,
    required this.flashPayment,
    required this.updatingInvoice,
    required this.updatingPayment,
    required this.onSelectChanged,
    required this.onNameTap,
    required this.onInvoiceTap,
    required this.onPaymentTap,
  });

  final ClientSummaryRow row;
  final bool selected;
  final String nextInvoiceLabel;
  final bool flashInvoice;
  final bool flashPayment;
  final bool updatingInvoice;
  final bool updatingPayment;
  final VoidCallback onSelectChanged;
  final VoidCallback onNameTap;
  final VoidCallback? onInvoiceTap;
  final VoidCallback? onPaymentTap;

  @override
  Widget build(BuildContext context) {
    final avatarBg =
        ClientBillingMobileTheme.avatarBg(row.paymentRecordId);
    final initials = _initials(row.displayName);

    return Material(
      color: selected
          ? ClientBillingMobileTheme.terracotta.withValues(alpha: 0.07)
          : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                value: selected,
                activeColor: ClientBillingMobileTheme.terracotta,
                side: const BorderSide(color: ClientBillingMobileTheme.border),
                onChanged: (_) => onSelectChanged(),
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: onNameTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: avatarBg,
                        child: Text(
                          initials,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: ClientBillingMobileTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: ClientBillingMobileTheme.textDark,
                              ),
                            ),
                            if (row.email.isNotEmpty)
                              Text(
                                row.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 9,
                                  color: ClientBillingMobileTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 52,
              child: Text(
                nextInvoiceLabel,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: ClientBillingMobileTheme.textMuted,
                ),
              ),
            ),
            SizedBox(
              width: 58,
              child: Center(
                child: _StatusChip(
                  value: row.invoiceSent,
                  isInvoice: true,
                  flashing: flashInvoice,
                  loading: updatingInvoice,
                  onTap: onInvoiceTap,
                ),
              ),
            ),
            SizedBox(
              width: 58,
              child: Center(
                child: _StatusChip(
                  value: row.paymentReceived,
                  isInvoice: false,
                  flashing: flashPayment,
                  loading: updatingPayment,
                  onTap: onPaymentTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.value,
    required this.isInvoice,
    required this.flashing,
    required this.loading,
    required this.onTap,
  });

  final bool? value;
  final bool isInvoice;
  final bool flashing;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(value);
    final label = _statusShortLabel(value, isInvoice);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: flashing
            ? color.withValues(alpha: 0.28)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: loading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _TriStateSegments extends StatelessWidget {
  const _TriStateSegments({
    required this.value,
    required this.isInvoice,
    required this.onChanged,
  });

  final bool? value;
  final bool isInvoice;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <bool?>[
      null,
      true,
      false,
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ClientBillingMobileTheme.segmentBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = value == opt;
          final label = _statusShortLabel(opt, isInvoice);
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? ClientBillingMobileTheme.card : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? _statusColor(opt)
                        : ClientBillingMobileTheme.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

String _statusShortLabel(bool? value, bool isInvoice) {
  if (value == null) return 'Pend';
  if (value) return isInvoice ? 'Sent' : 'Paid';
  return isInvoice ? 'No' : 'No';
}

Color _statusColor(bool? value) {
  if (value == null) return ClientBillingMobileTheme.warning;
  if (value) return ClientBillingMobileTheme.successDark;
  return const Color(0xFFC62828);
}
