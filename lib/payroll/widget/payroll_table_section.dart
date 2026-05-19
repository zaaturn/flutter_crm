import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../services/secure_storage_service.dart';
import '../bloc/payroll_dashboard_bloc.dart';
import '../bloc/payroll_dashboard_event.dart';
import '../bloc/payroll_dashboard_state.dart';
import '../models/payroll_merged_row.dart';

/// THEME CONSTANTS: Signature Daxarrow/Workspace Light
class WorkspaceTheme {
  static const Color primaryPurple = Color(0xFF6F34DC);
  static const Color cardSurface = Colors.white;
  static const Color borderSubtle = Color(0xFFE8E9F1);
  static const Color tableHeaderBg = Color(0xFFF8F9FD);

  static const Color textMain = Color(0xFF1E1E24);
  static const Color textMuted = Color(0xFF64748B);

  static const Color successBg = Color(0xFFECFDF5);
  static const Color successText = Color(0xFF10B981);
  static const Color warningBg = Color(0xFFFFF7ED);
  static const Color warningText = Color(0xFFF59E0B);
  static const Color neutralBg = Color(0xFFF1F5F9);
  static const Color neutralText = Color(0xFF475569);
}

class PayrollTableSection extends StatelessWidget {
  const PayrollTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final narrow = outerConstraints.maxWidth < 760;
        const minTableWidth = 700.0;

        return BlocBuilder<PayrollDashboardBloc, PayrollDashboardState>(
          builder: (context, state) {
            final rows = state.tableRows;
            final paidCount = rows.where((r) => r.paid == true).length;
            final pendingCount = rows.where((r) => r.paid == false).length;

            final m = state.monthIndex.clamp(1, 12);
            final periodLabel = DateFormat('MMMM').format(DateTime(state.year, m));
            final pad = narrow ? 14.0 : 24.0;

            final tableColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(pad),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$periodLabel ${state.year} Payroll',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: narrow ? 16 : 18,
                                fontWeight: FontWeight.w800,
                                color: WorkspaceTheme.textMain,
                              ),
                            ),
                            Text(
                              'Management of employee disbursements',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: WorkspaceTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (narrow)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _SummaryPill(
                              '$paidCount Paid',
                              WorkspaceTheme.successBg,
                              WorkspaceTheme.successText,
                            ),
                            const SizedBox(height: 6),
                            _SummaryPill(
                              '$pendingCount Pending',
                              WorkspaceTheme.warningBg,
                              WorkspaceTheme.warningText,
                            ),
                          ],
                        )
                      else ...[
                        _SummaryPill(
                          '$paidCount Paid',
                          WorkspaceTheme.successBg,
                          WorkspaceTheme.successText,
                        ),
                        const SizedBox(width: 8),
                        _SummaryPill(
                          '$pendingCount Pending',
                          WorkspaceTheme.warningBg,
                          WorkspaceTheme.warningText,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  color: WorkspaceTheme.tableHeaderBg,
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
                  child: Row(
                    children: [
                      _HdrText('#', flex: 0, width: 40),
                      _HdrText('EMPLOYEE', flex: 4),
                      _HdrText('STATUS', flex: 2),
                      _HdrText('AMOUNT', flex: 2),
                      _HdrText('LAST UPDATE', flex: 2),
                    ],
                  ),
                ),
                if (rows.isEmpty &&
                    state.loadStatus == PayrollDashboardLoadStatus.success)
                  _EmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: WorkspaceTheme.borderSubtle,
                    ),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return _PayrollInlineRow(
                        row: row,
                        index: index + 1,
                        rowSaving: state.savingRecordId == row.recordId ||
                            state.savingEmployeeId == row.employeeId,
                        compactPadding: narrow,
                      );
                    },
                  ),
                _TableFooter(state: state),
              ],
            );

            final decorated = Container(
              decoration: BoxDecoration(
                color: WorkspaceTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WorkspaceTheme.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: narrow
                  ? Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: minTableWidth,
                          child: tableColumn,
                        ),
                      ),
                    )
                  : tableColumn,
            );

            return decorated;
          },
        );
      },
    );
  }
}

class _HdrText extends StatelessWidget {
  const _HdrText(this.label, {this.flex = 1, this.width});
  final String label;
  final int flex;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: WorkspaceTheme.textMuted,
      ),
    );
    return width != null
        ? SizedBox(width: width, child: text)
        : Expanded(flex: flex, child: text);
  }
}

class _PayrollInlineRow extends StatefulWidget {
  const _PayrollInlineRow({
    required this.row,
    required this.index,
    required this.rowSaving,
    this.compactPadding = false,
  });
  final PayrollMergedRow row;
  final int index;
  final bool rowSaving;
  final bool compactPadding;

  @override
  State<_PayrollInlineRow> createState() => _PayrollInlineRowState();
}

class _PayrollInlineRowState extends State<_PayrollInlineRow> {
  late TextEditingController _amountCtrl;
  final _amountFocus = FocusNode();

  /// Write-only API field; only used when `paid == true`. Default: do not notify.
  bool _notifySalaryCredited = false;

  /// Last dropdown choice until [widget.row.paid] matches (avoids stale [widget.row.paid] on amount blur).
  bool _paidSelectionPending = false;
  bool? _pendingPaid;

  bool? _effectivePaid() =>
      _paidSelectionPending ? _pendingPaid : widget.row.paid;

  String? _notifyKey;
  int? _lastYear;
  int? _lastMonth;

  String _buildNotifyKey({
    required String userId,
    required int year,
    required int month,
    required int employeeId,
  }) {
    return 'payroll_notify_salary_credited:$userId:$year-${month.toString().padLeft(2, '0')}:$employeeId';
  }

  Future<void> _loadPersistedNotifyPref() async {
    final storage = SecureStorageService();
    final uid = await storage.readUserId();
    if (!mounted) return;
    if (uid == null || uid.trim().isEmpty) return;

    final st = context.read<PayrollDashboardBloc>().state;
    final month = st.monthIndex.clamp(1, 12);
    final year = st.year;
    _lastMonth = month;
    _lastYear = year;

    final key = _buildNotifyKey(
      userId: uid,
      year: year,
      month: month,
      employeeId: widget.row.employeeId,
    );
    _notifyKey = key;

    final v = await storage.readBool(key);
    if (!mounted) return;
    if (v == null) return;
    setState(() => _notifySalaryCredited = v);
  }

  Future<void> _persistNotifyPref(bool v) async {
    final storage = SecureStorageService();
    final uid = await storage.readUserId();
    if (uid == null || uid.trim().isEmpty) return;

    final st = context.read<PayrollDashboardBloc>().state;
    final month = st.monthIndex.clamp(1, 12);
    final year = st.year;
    final key = _notifyKey ??
        _buildNotifyKey(
          userId: uid,
          year: year,
          month: month,
          employeeId: widget.row.employeeId,
        );
    _notifyKey = key;
    await storage.writeBool(key, v);
  }

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.row.amountRaw);
    _amountFocus.addListener(() {
      if (!_amountFocus.hasFocus) _push();
    });
    _loadPersistedNotifyPref();
  }

  @override
  void didUpdateWidget(covariant _PayrollInlineRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row.amountRaw != widget.row.amountRaw &&
        widget.row.amountRaw != _amountCtrl.text) {
      _amountCtrl.text = widget.row.amountRaw;
    }
    if (oldWidget.row.employeeId != widget.row.employeeId ||
        oldWidget.row.recordId != widget.row.recordId) {
      _notifyKey = null;
      _paidSelectionPending = false;
      _pendingPaid = null;
      _loadPersistedNotifyPref();
    }
    final st = context.read<PayrollDashboardBloc>().state;
    final month = st.monthIndex.clamp(1, 12);
    final year = st.year;
    if (_lastMonth != null &&
        _lastYear != null &&
        (month != _lastMonth || year != _lastYear)) {
      _notifyKey = null;
      _loadPersistedNotifyPref();
    }
    if (_paidSelectionPending && widget.row.paid == _pendingPaid) {
      _paidSelectionPending = false;
      _pendingPaid = null;
    }
  }

  void _push() {
    final rid = widget.row.recordId;
    final bloc = context.read<PayrollDashboardBloc>();
    final paid = _effectivePaid();
    if (rid != null) {
      // When paid is true, always send explicit notify flag (even on amount blur).
      // Omitting the key after a status→Paid change (focus moves from amount→dropdown)
      // can trigger a second PATCH with null; backends often treat that as "notify: true".
      bloc.add(PayrollInlinePatchRequested(
        recordId: rid,
        paid: paid,
        amountRaw: _amountCtrl.text,
        notifySalaryCredited:
            paid == true ? _notifySalaryCredited : null,
      ));
    } else {
      bloc.add(PayrollInlineCreateRequested(
        employeeId: widget.row.employeeId,
        paid: paid,
        amountRaw: _amountCtrl.text,
        notifySalaryCredited:
            paid == true ? _notifySalaryCredited : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.row;
    final hPad = widget.compactPadding ? 12.0 : 24.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              widget.index.toString().padLeft(2, '0'),
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: WorkspaceTheme.textMuted
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: WorkspaceTheme.primaryPurple.withOpacity(0.1),
                  child: Text(r.avatarInitials, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: WorkspaceTheme.primaryPurple)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.employeeName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: WorkspaceTheme.textMain)),
                      if (r.jobTitle.isNotEmpty)
                        Text(r.jobTitle, style: GoogleFonts.inter(fontSize: 12, color: WorkspaceTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusDropdown(
                  value: r.paid,
                  onChanged: (v) {
                    _paidSelectionPending = true;
                    _pendingPaid = v;
                    setState(() {});
                    final notify = v == true ? _notifySalaryCredited : null;
                    context.read<PayrollDashboardBloc>().add(
                          r.recordId != null
                              ? PayrollInlinePatchRequested(
                                  recordId: r.recordId!,
                                  paid: v,
                                  amountRaw: _amountCtrl.text,
                                  notifySalaryCredited: notify,
                                )
                              : PayrollInlineCreateRequested(
                                  employeeId: r.employeeId,
                                  paid: v,
                                  amountRaw: _amountCtrl.text,
                                  notifySalaryCredited: notify,
                                ),
                        );
                  },
                ),
                if (r.paid == true) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: Checkbox(
                          value: _notifySalaryCredited,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onChanged: (nv) {
                            if (nv == null) return;
                            setState(() => _notifySalaryCredited = nv);
                            _persistNotifyPref(nv);
                            if (r.recordId != null) {
                              context.read<PayrollDashboardBloc>().add(
                                    PayrollInlinePatchRequested(
                                      recordId: r.recordId!,
                                      paid: true,
                                      amountRaw: _amountCtrl.text,
                                      notifySalaryCredited: nv,
                                    ),
                                  );
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2, top: 2),
                          child: Text(
                            'Send salary notification',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: WorkspaceTheme.textMuted,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 38,
              margin: const EdgeInsets.only(right: 20),
              child: TextField(
                controller: _amountCtrl,
                focusNode: _amountFocus,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: '0.00',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FE),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(r.updatedDateLabel, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: WorkspaceTheme.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});
  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isPaid = value == true;
    final bool isPending = value == false;

    final Color bg = isPaid ? WorkspaceTheme.successBg : isPending ? WorkspaceTheme.warningBg : WorkspaceTheme.neutralBg;
    final Color fg = isPaid ? WorkspaceTheme.successText : isPending ? WorkspaceTheme.warningText : WorkspaceTheme.neutralText;

    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: fg, size: 16),
          items: const [
            DropdownMenuItem(value: null, child: Text('SELECT')),
            DropdownMenuItem(value: true, child: Text('PAID')),
            DropdownMenuItem(value: false, child: Text('PENDING')),
          ],
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill(this.label, this.bg, this.fg);
  final String label; final Color bg; final Color fg;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No matching records found.', style: TextStyle(color: WorkspaceTheme.textMuted))));
  }
}

class _TableFooter extends StatelessWidget {
  const _TableFooter({required this.state});
  final PayrollDashboardState state;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: WorkspaceTheme.tableHeaderBg, borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
      child: Text('${state.tableRows.length} employees found in this period', style: GoogleFonts.inter(fontSize: 12, color: WorkspaceTheme.textMuted, fontWeight: FontWeight.w500)),
    );
  }
}