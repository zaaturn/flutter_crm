import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/invoice_list_item.dart';
import '../theme/billing_theme.dart';
import 'edit_invoice_draft_screen.dart';
import 'invoice_review_screen.dart';

class InvoiceDashboardRow extends StatelessWidget {
  final InvoiceListItem inv;
  final bool highlight;
  final List<String> paymentOptions;
  final void Function(String invoiceId, String status) onPaymentChanged;
  final VoidCallback onIssue;
  final VoidCallback onDownload;
  final Future<void> Function() onAfterEdit;

  const InvoiceDashboardRow({
    super.key,
    required this.inv,
    required this.highlight,
    required this.paymentOptions,
    required this.onPaymentChanged,
    required this.onIssue,
    required this.onDownload,
    required this.onAfterEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BillingTheme.cardDecoration(highlighted: highlight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => InvoiceReviewScreen(invoiceId: inv.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice #${inv.invoiceNumber}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: BillingTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            inv.clientName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: BillingTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _issuedChip(context),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (!inv.isIssued) ...[
                  _outlineButton(
                    context,
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    onTap: () async {
                      final updated = await Navigator.of(context, rootNavigator: true)
                          .push<bool>(
                        MaterialPageRoute(
                          builder: (_) => EditInvoiceDraftScreen(invoiceId: inv.id),
                        ),
                      );
                      if (updated == true) await onAfterEdit();
                    },
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _normalizedPayment(inv.paymentStatus),
                    decoration: InputDecoration(
                      labelText: 'Payment status',
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: BillingTheme.textMuted,
                      ),
                      filled: true,
                      fillColor: BillingTheme.scaffoldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: BillingTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: BillingTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: BillingTheme.purple, width: 1.5),
                      ),
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: BillingTheme.textPrimary,
                    ),
                    items: <String>{
                      _normalizedPayment(inv.paymentStatus),
                      ...paymentOptions.map(_normalizedPayment),
                    }
                        .where((e) => e.trim().isNotEmpty)
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      onPaymentChanged(inv.id, v);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: inv.hasPdf ? onDownload : null,
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BillingTheme.purple,
                      side: const BorderSide(color: BillingTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _issuedChip(BuildContext context) {
    if (inv.isIssued) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Text(
          'Issued',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF059669),
          ),
        ),
      );
    }
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onIssue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626), // red before issue
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          'Issue',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ),
    );
  }

  String _normalizedPayment(String raw) {
    final s = raw.trim().toUpperCase();
    if (s.isEmpty) return 'PENDING';
    // Treat UNPAID/PARTIALLY_PAID as pending for the “Pending/Paid” UX.
    if (s == 'UNPAID' || s == 'PARTIALLY_PAID' || s == 'OVERDUE') return 'PENDING';
    if (s == 'PAID') return 'PAID';
    if (s == 'PENDING') return 'PENDING';
    return s;
  }

  Widget _outlineButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: BillingTheme.purpleDark,
          side: const BorderSide(color: BillingTheme.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
