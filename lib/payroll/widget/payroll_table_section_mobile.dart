import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/secure_storage_service.dart';
import '../bloc/payroll_dashboard_bloc.dart';
import '../bloc/payroll_dashboard_event.dart';
import '../bloc/payroll_dashboard_state.dart';
import '../models/payroll_merged_row.dart';

class ZaaturnMobileTheme {
  static const Color background = Color(0xFFFAF3E0);
  static const Color cardColor = Color(0xFFEADBC8); // Terracotta-Beige
  static const Color subBoxColor = Color(0xFFF2E6D6);
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color textMain = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF5D4037);

  static const Color successBg = Color(0xFFD0F4E0);
  static const Color successText = Color(0xFF00695C);
  static const Color warningBg = Color(0xFFFCF5BF);
  static const Color warningText = Color(0xFF857000);
}

class PayrollTableMobile extends StatelessWidget {
  const PayrollTableMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayrollDashboardBloc, PayrollDashboardState>(
      builder: (context, state) {
        final rows = state.tableRows;

        if (rows.isEmpty && state.loadStatus == PayrollDashboardLoadStatus.success) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No records found.',
                style: GoogleFonts.manrope(color: ZaaturnMobileTheme.textMuted),
              ),
            ),
          );
        }

        return Column(
          children: rows.asMap().entries.map((entry) {
            return _PayrollEmployeeCard(
              row: entry.value,
              index: entry.key + 1,
              rowSaving: state.savingRecordId == entry.value.recordId ||
                  state.savingEmployeeId == entry.value.employeeId,
            );
          }).toList(),
        );
      },
    );
  }
}

class _PayrollEmployeeCard extends StatefulWidget {
  const _PayrollEmployeeCard({
    required this.row,
    required this.index,
    required this.rowSaving,
  });
  final PayrollMergedRow row;
  final int index;
  final bool rowSaving;

  @override
  State<_PayrollEmployeeCard> createState() => _PayrollEmployeeCardState();
}

class _PayrollEmployeeCardState extends State<_PayrollEmployeeCard> {
  late TextEditingController _amountCtrl;
  final _amountFocus = FocusNode();
  bool _notifySalaryCredited = false;
  bool _paidSelectionPending = false;
  bool? _pendingPaid;

  bool? _effectivePaid() => _paidSelectionPending ? _pendingPaid : widget.row.paid;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.row.amountRaw);
    _amountFocus.addListener(() {
      if (!_amountFocus.hasFocus) _push();
    });
    _loadPersistedNotifyPref();
  }

  Future<void> _loadPersistedNotifyPref() async {
    final storage = SecureStorageService();
    final uid = await storage.readUserId();
    if (!mounted || uid == null) return;
    final st = context.read<PayrollDashboardBloc>().state;
    final key = 'payroll_notify_salary_credited:$uid:${st.year}-${st.monthIndex.toString().padLeft(2, '0')}:${widget.row.employeeId}';
    final v = await storage.readBool(key);
    if (!mounted || v == null) return;
    setState(() => _notifySalaryCredited = v);
  }

  void _push() {
    final rid = widget.row.recordId;
    final bloc = context.read<PayrollDashboardBloc>();
    final paid = _effectivePaid();
    if (rid != null) {
      bloc.add(PayrollInlinePatchRequested(
        recordId: rid,
        paid: paid,
        amountRaw: _amountCtrl.text,
        notifySalaryCredited: paid == true ? _notifySalaryCredited : null,
      ));
    } else {
      bloc.add(PayrollInlineCreateRequested(
        employeeId: widget.row.employeeId,
        paid: paid,
        amountRaw: _amountCtrl.text,
        notifySalaryCredited: paid == true ? _notifySalaryCredited : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.row;
    final statusPaid = _effectivePaid();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZaaturnMobileTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Status Row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: ZaaturnMobileTheme.subBoxColor,
                child: Text(r.avatarInitials,
                    style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: ZaaturnMobileTheme.textMain)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.employeeName,
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: ZaaturnMobileTheme.textMain, fontSize: 15)),
                    Text(r.jobTitle,
                        style: GoogleFonts.manrope(fontSize: 11, color: ZaaturnMobileTheme.textMuted)),
                  ],
                ),
              ),
              _StatusDropdown(
                value: statusPaid,
                onChanged: (v) {
                  setState(() { _paidSelectionPending = true; _pendingPaid = v; });
                  _push();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Amount and Last Update Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AMOUNT', style: GoogleFonts.manrope(fontSize: 9, fontWeight: FontWeight.w900, color: ZaaturnMobileTheme.textMuted)),
                    const SizedBox(height: 4),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(color: ZaaturnMobileTheme.subBoxColor, borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _amountCtrl,
                        focusNode: _amountFocus,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('LAST UPDATE', style: GoogleFonts.manrope(fontSize: 9, fontWeight: FontWeight.w900, color: ZaaturnMobileTheme.textMuted)),
                    const SizedBox(height: 8),
                    Text(r.updatedDateLabel,
                        style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: ZaaturnMobileTheme.textMain)),
                  ],
                ),
              ),
            ],
          ),
          // Notification Switch
          if (statusPaid == true) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Transform.scale(
                  scale: 0.7,
                  child: Switch.adaptive(
                    value: _notifySalaryCredited,
                    activeColor: ZaaturnMobileTheme.accentOrange,
                    onChanged: (v) {
                      setState(() => _notifySalaryCredited = v);
                      _push();
                    },
                  ),
                ),
                Text('Notify employee',
                    style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.bold, color: ZaaturnMobileTheme.textMuted)),
              ],
            ),
          ],
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
    final Color bg = isPaid ? ZaaturnMobileTheme.successBg : isPending ? ZaaturnMobileTheme.warningBg : ZaaturnMobileTheme.subBoxColor;
    final Color fg = isPaid ? ZaaturnMobileTheme.successText : isPending ? ZaaturnMobileTheme.warningText : ZaaturnMobileTheme.textMain;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down, color: fg, size: 16),
          items: const [
            DropdownMenuItem(value: null, child: Text('SELECT')),
            DropdownMenuItem(value: true, child: Text('PAID')),
            DropdownMenuItem(value: false, child: Text('PENDING')),
          ],
          style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, color: fg),
          onChanged: onChanged,
        ),
      ),
    );
  }
}