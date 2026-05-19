import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/invoice_list_item.dart';
import '../theme/billing_theme.dart';
import '../theme/billing_adaptive_theme.dart';
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
    final bool isMobile = BillingAdaptiveTheme.isMobile(context);

    // Zaaturn Mobile Palette
    const Color inkText = Color(0xFF1A1C1E);
    const Color accentOrange = Color(0xFFB14D1E);
    const Color clayFill = Color(0xFFF5E6DA);
    const Color paperWhite = Color(0xFFFFFDFB);
    const Color zaaturnInk = Color(0xFF8D5B39);

    return Container(
      decoration: isMobile
          ? BoxDecoration(
        color: paperWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: accentOrange.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      )
          : BillingAdaptiveTheme.cardDecoration(context, highlighted: highlight),
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
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isMobile ? inkText : BillingAdaptiveTheme.text(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            inv.clientName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isMobile ? inkText.withOpacity(0.6) : BillingAdaptiveTheme.muted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _issuedChip(context, isMobile, accentOrange, zaaturnInk),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!inv.isIssued) ...[
                  _outlineButton(
                    context,
                    isMobile: isMobile,
                    icon: Icons.edit_note_rounded,
                    label: 'Edit',
                    accentColor: zaaturnInk,
                    onTap: () async {
                      final updated = await Navigator.of(context, rootNavigator: true).push<bool>(
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
                    value: _normalizedPayment(inv.paymentStatus),
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isMobile ? accentOrange : BillingAdaptiveTheme.muted(context),
                      ),
                      filled: true,
                      fillColor: isMobile ? clayFill : BillingAdaptiveTheme.bg(context),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: isMobile ? Colors.transparent : BillingAdaptiveTheme.border(context)),
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isMobile ? inkText : BillingAdaptiveTheme.text(context),
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
                  child: OutlinedButton(
                    onPressed: inv.hasPdf ? onDownload : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isMobile ? accentOrange : BillingAdaptiveTheme.primary(context),
                      side: BorderSide(color: isMobile ? accentOrange.withOpacity(0.2) : BillingAdaptiveTheme.border(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _issuedChip(BuildContext context, bool isMobile, Color accent, Color ink) {
    if (inv.isIssued) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isMobile ? const Color(0xFFF5E6DA) : const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isMobile ? accent.withOpacity(0.2) : const Color(0xFFBBF7D0)),
        ),
        child: Text(
          'Issued',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isMobile ? accent : const Color(0xFF059669),
          ),
        ),
      );
    }
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onIssue,
        style: ElevatedButton.styleFrom(
          backgroundColor: isMobile ? ink : const Color(0xFFDC2626),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          'Issue',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ),
    );
  }

  String _normalizedPayment(String raw) {
    final s = raw.trim().toUpperCase();
    if (s.isEmpty) return 'PENDING';
    if (s == 'UNPAID' || s == 'PARTIALLY_PAID' || s == 'OVERDUE') return 'PENDING';
    if (s == 'PAID') return 'PAID';
    if (s == 'PENDING') return 'PENDING';
    return s;
  }

  Widget _outlineButton(
      BuildContext context, {
        required bool isMobile,
        required IconData icon,
        required String label,
        required Color accentColor,
        required VoidCallback onTap,
      }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: isMobile ? accentColor : BillingTheme.purpleDark,
          side: BorderSide(color: isMobile ? accentColor.withOpacity(0.2) : BillingTheme.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}