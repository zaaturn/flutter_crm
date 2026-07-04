import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/payroll_mobile_theme.dart';

/// Individual employee editor — amount, status, notify on Save.
class PayrollMobileEditPanel extends StatefulWidget {
  const PayrollMobileEditPanel({
    super.key,
    required this.initialPaid,
    required this.initialAmount,
    required this.initialNotify,
    required this.onApply,
    this.applyLabel = 'Save',
  });

  final bool? initialPaid;
  final String initialAmount;
  final bool initialNotify;
  final String applyLabel;
  final void Function(bool? paid, String amountRaw, bool notify) onApply;

  @override
  State<PayrollMobileEditPanel> createState() => _PayrollMobileEditPanelState();
}

class _PayrollMobileEditPanelState extends State<PayrollMobileEditPanel> {
  late bool? _paid;
  late TextEditingController _amountCtrl;
  late bool _notify;

  @override
  void initState() {
    super.initState();
    _paid = widget.initialPaid;
    _amountCtrl = TextEditingController(text: widget.initialAmount);
    _notify = widget.initialNotify;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PayrollMobileTheme.terracotta.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: PayrollMobileTheme.terracotta.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AMOUNT',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: PayrollMobileTheme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '₹ ',
              filled: true,
              fillColor: PayrollMobileTheme.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PayrollMobileTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PayrollMobileTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: PayrollMobileTheme.terracotta,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'STATUS',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: PayrollMobileTheme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          PayrollStatusSegment(
            value: _paid,
            onChanged: (v) => setState(() => _paid = v),
          ),
          if (_paid == true) ...[
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _notify,
              activeTrackColor: PayrollMobileTheme.terracotta,
              title: Text(
                'Notify employee',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: PayrollMobileTheme.textDark,
                ),
              ),
              subtitle: Text(
                'Sends notification when you tap Save',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: PayrollMobileTheme.textMuted,
                ),
              ),
              onChanged: (v) => setState(() => _notify = v),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () => widget.onApply(
                _paid,
                _amountCtrl.text,
                _notify,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: PayrollMobileTheme.terracotta,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.applyLabel,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Checkbox bulk action — mark paid (+ optional notify) only.
class PayrollMobileBulkPaidBar extends StatefulWidget {
  const PayrollMobileBulkPaidBar({
    super.key,
    required this.count,
    required this.onMarkPaid,
    required this.onClear,
  });

  final int count;
  final void Function(bool notify) onMarkPaid;
  final VoidCallback onClear;

  @override
  State<PayrollMobileBulkPaidBar> createState() =>
      _PayrollMobileBulkPaidBarState();
}

class _PayrollMobileBulkPaidBarState extends State<PayrollMobileBulkPaidBar> {
  bool _notify = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: PayrollMobileTheme.terracotta.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: PayrollMobileTheme.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: widget.onClear,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: PayrollMobileTheme.textMuted,
              ),
              Expanded(
                child: Text(
                  '${widget.count} selected',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: PayrollMobileTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _notify,
            activeTrackColor: PayrollMobileTheme.terracotta,
            title: Text(
              'Notify employees',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: PayrollMobileTheme.textDark,
              ),
            ),
            subtitle: Text(
              'Send salary credited notification',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: PayrollMobileTheme.textMuted,
              ),
            ),
            onChanged: (v) => setState(() => _notify = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () => widget.onMarkPaid(_notify),
              style: ElevatedButton.styleFrom(
                backgroundColor: PayrollMobileTheme.paidGreen,
                foregroundColor: PayrollMobileTheme.textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Mark paid',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PayrollStatusSegment extends StatelessWidget {
  const PayrollStatusSegment({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PayrollMobileTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PayrollMobileTheme.border),
      ),
      child: Row(
        children: [
          _SegChip(
            label: 'Not set',
            selected: value == null,
            onTap: () => onChanged(null),
          ),
          _SegChip(
            label: 'Pending',
            selected: value == false,
            onTap: () => onChanged(false),
          ),
          _SegChip(
            label: 'Paid',
            selected: value == true,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _SegChip extends StatelessWidget {
  const _SegChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? PayrollMobileTheme.terracotta : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : PayrollMobileTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

String displayPayrollAmount(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '—';
  final n = double.tryParse(t.replaceAll(RegExp(r'[^0-9.]'), ''));
  if (n == null) return t;
  return '₹${n.round()}';
}

Color payrollStatusDot(bool? paid) {
  if (paid == true) return PayrollMobileTheme.paidGreen;
  if (paid == false) return PayrollMobileTheme.pendingOrange;
  return PayrollMobileTheme.textMuted;
}

String payrollStatusLabel(bool? paid) {
  if (paid == true) return 'Paid';
  if (paid == false) return 'Pending';
  return 'Not set';
}

Color payrollStatusText(bool? paid) {
  if (paid == true) return PayrollMobileTheme.paidGreenDark;
  if (paid == false) return PayrollMobileTheme.terracotta;
  return PayrollMobileTheme.textMuted;
}
