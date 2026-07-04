import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/secure_storage_service.dart';
import '../bloc/payroll_dashboard_bloc.dart';
import '../bloc/payroll_dashboard_event.dart';
import '../bloc/payroll_dashboard_state.dart';
import '../models/payroll_merged_row.dart';
import '../theme/payroll_mobile_theme.dart';
import 'payroll_mobile_edit_panel.dart';

const int _kPageSize = 20;

class PayrollTableMobile extends StatefulWidget {
  const PayrollTableMobile({
    super.key,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onSelectionChanged;

  @override
  State<PayrollTableMobile> createState() => _PayrollTableMobileState();
}

class _PayrollTableMobileState extends State<PayrollTableMobile> {
  int _page = 0;

  void _toggleSelect(int employeeId) {
    final next = Set<int>.from(widget.selectedIds);
    if (next.contains(employeeId)) {
      next.remove(employeeId);
    } else {
      next.add(employeeId);
    }
    widget.onSelectionChanged(next);
  }

  void _toggleSelectAllPage(List<PayrollMergedRow> pageRows) {
    final ids = pageRows.map((r) => r.employeeId).toSet();
    final allSelected = ids.every(widget.selectedIds.contains);
    final next = Set<int>.from(widget.selectedIds);
    if (allSelected) {
      next.removeAll(ids);
    } else {
      next.addAll(ids);
    }
    widget.onSelectionChanged(next);
  }

  void _markBulkPaid(bool notify) async {
    final bloc = context.read<PayrollDashboardBloc>();
    final state = bloc.state;
    for (final id in widget.selectedIds) {
      if (notify) {
        await _writeNotifyPref(
          employeeId: id,
          state: state,
          value: true,
        );
      }
    }
    if (!mounted) return;
    bloc.add(
      PayrollBulkUpdateRequested(
        employeeIds: widget.selectedIds.toList(),
        paid: true,
        amountRaw: '',
        notifySalaryCredited: notify,
      ),
    );
    widget.onSelectionChanged({});
  }

  void _saveIndividual(
    PayrollMergedRow row,
    PayrollDashboardBloc bloc,
    bool? paid,
    String amount,
    bool notify,
  ) {
    final notifyArg = paid == true ? notify : null;
    if (row.recordId != null) {
      bloc.add(PayrollInlinePatchRequested(
        recordId: row.recordId!,
        paid: paid,
        amountRaw: amount,
        notifySalaryCredited: notifyArg,
      ));
    } else {
      bloc.add(PayrollInlineCreateRequested(
        employeeId: row.employeeId,
        paid: paid,
        amountRaw: amount,
        notifySalaryCredited: notifyArg,
      ));
    }
  }

  Future<void> _openEmployeeSheet(PayrollMergedRow row) async {
    final bloc = context.read<PayrollDashboardBloc>();
    final notify = await _readNotifyPref(
      employeeId: row.employeeId,
      state: bloc.state,
    );
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PayrollMobileTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
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
                      color: PayrollMobileTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  row.employeeName,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: PayrollMobileTheme.textDark,
                  ),
                ),
                if (row.jobTitle.isNotEmpty)
                  Text(
                    row.jobTitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: PayrollMobileTheme.textMuted,
                    ),
                  ),
                const SizedBox(height: 14),
                PayrollMobileEditPanel(
                  applyLabel: 'Save',
                  initialPaid: row.paid,
                  initialAmount: row.amountRaw,
                  initialNotify: notify,
                  onApply: (paid, amount, n) async {
                    if (paid == true) {
                      await _writeNotifyPref(
                        employeeId: row.employeeId,
                        state: bloc.state,
                        value: n,
                      );
                    }
                    _saveIndividual(row, bloc, paid, amount, n);
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PayrollDashboardBloc, PayrollDashboardState>(
      listenWhen: (p, c) =>
          p.monthIndex != c.monthIndex ||
          p.year != c.year ||
          p.searchQuery != c.searchQuery ||
          p.recordsPaidFilter != c.recordsPaidFilter,
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onSelectionChanged({});
          setState(() => _page = 0);
        });
      },
      child: BlocBuilder<PayrollDashboardBloc, PayrollDashboardState>(
        builder: (context, state) {
          final rows = state.tableRows;

        if (state.loadStatus == PayrollDashboardLoadStatus.loading &&
            rows.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PayrollMobileTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PayrollMobileTheme.border),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: PayrollMobileTheme.terracotta,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Loading employees…',
                    style: GoogleFonts.manrope(
                      color: PayrollMobileTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (rows.isEmpty &&
            state.loadStatus == PayrollDashboardLoadStatus.success) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PayrollMobileTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PayrollMobileTheme.border),
            ),
            child: Center(
              child: Text(
                'No records found.',
                style: GoogleFonts.manrope(
                  color: PayrollMobileTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        final pageCount = (rows.length / _kPageSize).ceil().clamp(1, 9999);
        final safePage = _page.clamp(0, pageCount - 1);
        if (safePage != _page) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _page = safePage);
          });
        }
        final start = safePage * _kPageSize;
        final pageRows = rows.skip(start).take(_kPageSize).toList();
        final pageIds = pageRows.map((r) => r.employeeId).toSet();
        final allPageSelected =
            pageRows.isNotEmpty && pageIds.every(widget.selectedIds.contains);
        final hasBulk = widget.selectedIds.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 14, 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Checkbox(
                            value: allPageSelected,
                            tristate: true,
                            activeColor: PayrollMobileTheme.terracotta,
                            side: const BorderSide(
                              color: PayrollMobileTheme.border,
                            ),
                            onChanged: pageRows.isEmpty
                                ? null
                                : (_) => _toggleSelectAllPage(pageRows),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'EMPLOYEE',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: PayrollMobileTheme.textMuted,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 72,
                          child: Text(
                            'AMOUNT',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: PayrollMobileTheme.textMuted,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            'STATUS',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: PayrollMobileTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasBulk)
                    PayrollMobileBulkPaidBar(
                      count: widget.selectedIds.length,
                      onClear: () => widget.onSelectionChanged({}),
                      onMarkPaid: _markBulkPaid,
                    ),
                  const Divider(height: 1, color: PayrollMobileTheme.border),
                  ...pageRows.asMap().entries.map((entry) {
                    final row = entry.value;
                    final isLast = entry.key == pageRows.length - 1;
                    final selected =
                        widget.selectedIds.contains(row.employeeId);
                    return Column(
                      children: [
                        _PayrollEmployeeRow(
                          row: row,
                          selected: selected,
                          onSelectChanged: () => _toggleSelect(row.employeeId),
                          onNameTap: () => _openEmployeeSheet(row),
                        ),
                        if (!isLast)
                          const Divider(
                            height: 1,
                            color: PayrollMobileTheme.border,
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            if (rows.length > _kPageSize) ...[
              const SizedBox(height: 12),
              _PaginationBar(
                page: safePage,
                pageCount: pageCount,
                total: rows.length,
                onPrev: safePage > 0
                    ? () => setState(() => _page = safePage - 1)
                    : null,
                onNext: safePage < pageCount - 1
                    ? () => setState(() => _page = safePage + 1)
                    : null,
              ),
            ],
          ],
        );
        },
      ),
    );
  }
}

Future<bool> _readNotifyPref({
  required int employeeId,
  required PayrollDashboardState state,
}) async {
  final storage = SecureStorageService();
  final uid = await storage.readUserId();
  if (uid == null || uid.trim().isEmpty) return false;
  final month = state.monthIndex.clamp(1, 12);
  final key =
      'payroll_notify_salary_credited:$uid:${state.year}-${month.toString().padLeft(2, '0')}:$employeeId';
  final v = await storage.readBool(key);
  return v ?? false;
}

Future<void> _writeNotifyPref({
  required int employeeId,
  required PayrollDashboardState state,
  required bool value,
}) async {
  final storage = SecureStorageService();
  final uid = await storage.readUserId();
  if (uid == null || uid.trim().isEmpty) return;
  final month = state.monthIndex.clamp(1, 12);
  final key =
      'payroll_notify_salary_credited:$uid:${state.year}-${month.toString().padLeft(2, '0')}:$employeeId';
  await storage.writeBool(key, value);
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageCount,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int page;
  final int pageCount;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final from = page * _kPageSize + 1;
    final to = ((page + 1) * _kPageSize).clamp(0, total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: PayrollMobileTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PayrollMobileTheme.border),
      ),
      child: Row(
        children: [
          _PageBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Expanded(
            child: Text(
              '$from–$to of $total',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: PayrollMobileTheme.textMuted,
              ),
            ),
          ),
          Text(
            '${page + 1}/$pageCount',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: PayrollMobileTheme.textDark,
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
          ? PayrollMobileTheme.segmentBg.withValues(alpha: 0.5)
          : PayrollMobileTheme.segmentBg,
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
                ? PayrollMobileTheme.border
                : PayrollMobileTheme.terracotta,
          ),
        ),
      ),
    );
  }
}

class _PayrollEmployeeRow extends StatelessWidget {
  const _PayrollEmployeeRow({
    required this.row,
    required this.selected,
    required this.onSelectChanged,
    required this.onNameTap,
  });

  final PayrollMergedRow row;
  final bool selected;
  final VoidCallback onSelectChanged;
  final VoidCallback onNameTap;

  @override
  Widget build(BuildContext context) {
    final r = row;
    final avatarBg = PayrollMobileTheme.avatarBg(r.employeeId);
    final paid = r.paid;

    return Material(
      color: selected
          ? PayrollMobileTheme.terracotta.withValues(alpha: 0.07)
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
                activeColor: PayrollMobileTheme.terracotta,
                side: const BorderSide(color: PayrollMobileTheme.border),
                onChanged: (_) => onSelectChanged(),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onNameTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: avatarBg,
                        child: Text(
                          r.avatarInitials,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: PayrollMobileTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.employeeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: PayrollMobileTheme.textDark,
                              ),
                            ),
                            if (r.jobTitle.isNotEmpty)
                              Text(
                                r.jobTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: PayrollMobileTheme.textMuted,
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
              width: 72,
              child: Text(
                displayPayrollAmount(r.amountRaw),
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: PayrollMobileTheme.textDark,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: payrollStatusDot(paid),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      payrollStatusLabel(paid),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: payrollStatusText(paid),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
