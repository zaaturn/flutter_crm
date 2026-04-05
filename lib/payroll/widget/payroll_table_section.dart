import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
    return BlocBuilder<PayrollDashboardBloc, PayrollDashboardState>(
      builder: (context, state) {
        final rows = state.tableRows;
        final paidCount = rows.where((r) => r.paid == true).length;
        final pendingCount = rows.where((r) => r.paid == false).length;

        // Current Period Label
        final m = state.monthIndex.clamp(1, 12);
        final periodLabel = DateFormat('MMMM').format(DateTime(state.year, m));

        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER SECTION
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$periodLabel ${state.year} Payroll',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
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
                    _SummaryPill('$paidCount Paid', WorkspaceTheme.successBg, WorkspaceTheme.successText),
                    const SizedBox(width: 8),
                    _SummaryPill('$pendingCount Pending', WorkspaceTheme.warningBg, WorkspaceTheme.warningText),
                  ],
                ),
              ),

              // TABLE HEADER
              Container(
                color: WorkspaceTheme.tableHeaderBg,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

              // EMPTY STATES
              if (rows.isEmpty && state.loadStatus == PayrollDashboardLoadStatus.success)
                _EmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: WorkspaceTheme.borderSubtle),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return _PayrollInlineRow(
                      row: row,
                      index: index + 1,
                      rowSaving: state.savingRecordId == row.recordId || state.savingEmployeeId == row.employeeId,
                    );
                  },
                ),

              _TableFooter(state: state),
            ],
          ),
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
  const _PayrollInlineRow({required this.row, required this.index, required this.rowSaving});
  final PayrollMergedRow row;
  final int index;
  final bool rowSaving;

  @override
  State<_PayrollInlineRow> createState() => _PayrollInlineRowState();
}

class _PayrollInlineRowState extends State<_PayrollInlineRow> {
  late TextEditingController _amountCtrl;
  final _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.row.amountRaw);
    _amountFocus.addListener(() { if (!_amountFocus.hasFocus) _push(); });
  }

  void _push() {
    final rid = widget.row.recordId;
    final bloc = context.read<PayrollDashboardBloc>();
    if (rid != null) {
      bloc.add(PayrollInlinePatchRequested(recordId: rid, paid: widget.row.paid, amountRaw: _amountCtrl.text));
    } else {
      bloc.add(PayrollInlineCreateRequested(employeeId: widget.row.employeeId, paid: widget.row.paid, amountRaw: _amountCtrl.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.row;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            child: _StatusDropdown(
              value: r.paid,
              onChanged: (v) {
                context.read<PayrollDashboardBloc>().add(
                    r.recordId != null
                        ? PayrollInlinePatchRequested(recordId: r.recordId!, paid: v, amountRaw: _amountCtrl.text)
                        : PayrollInlineCreateRequested(employeeId: r.employeeId, paid: v, amountRaw: _amountCtrl.text)
                );
              },
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