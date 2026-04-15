import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/invoice_review_model.dart';
import '../../theme/billing_theme.dart';

class InvoiceDetailLayout extends StatelessWidget {
  final InvoiceReviewModel inv;
  final VoidCallback onDownload;
  final VoidCallback? onIssue; // shown only when draft

  const InvoiceDetailLayout({
    super.key,
    required this.inv,
    required this.onDownload,
    required this.onIssue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 1100;
        final left = _Left(inv: inv, onDownload: onDownload);
        final right = _Right(inv: inv, onDownload: onDownload, onIssue: onIssue);

        if (!wide) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              left,
              const SizedBox(height: 14),
              right,
            ],
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 8, child: left),
                  const SizedBox(width: 18),
                  Expanded(flex: 4, child: right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Left extends StatelessWidget {
  final InvoiceReviewModel inv;
  final VoidCallback onDownload;

  const _Left({required this.inv, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMMM d, yyyy');
    final issuedText = inv.status.toUpperCase() == 'DRAFT'
        ? 'Draft invoice'
        : 'Issued on ${dateFmt.format(inv.invoiceDate.toLocal())}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _breadcrumb(),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoice Detail', style: BillingTheme.titleLarge()),
                  const SizedBox(height: 6),
                  Text(issuedText, style: BillingTheme.body()),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: onDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: BillingTheme.purple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.download_rounded),
              label: Text(
                'Download PDF',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _bentoFromTo(),
        const SizedBox(height: 14),
        _itemsTable(),
      ],
    );
  }

  Widget _breadcrumb() {
    return Row(
      children: [
        Text('Invoices', style: BillingTheme.body().copyWith(fontSize: 12)),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded, size: 18, color: BillingTheme.textMuted),
        const SizedBox(width: 6),
        Text(
          inv.invoiceNumber,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: BillingTheme.purple,
          ),
        ),
      ],
    );
  }

  Widget _bentoFromTo() {
    Widget block({
      required String label,
      required IconData icon,
      required Color iconBg,
      required Color iconFg,
      required String title,
      required String subtitle,
    }) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: BillingTheme.overline()),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BillingTheme.border),
                  ),
                  child: Icon(icon, color: iconFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: BillingTheme.cardTitle()),
                      const SizedBox(height: 4),
                      Text(subtitle, style: BillingTheme.body().copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: BillingTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BillingTheme.border),
      ),
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, c) {
          final stacked = c.maxWidth < 760;
          if (stacked) {
            return Column(
              children: [
                block(
                  label: 'From',
                  icon: Icons.domain_rounded,
                  iconBg: BillingTheme.purpleLight,
                  iconFg: BillingTheme.purple,
                  title: inv.billingFrom.name,
                  subtitle: inv.billingFrom.address,
                ),
                const SizedBox(height: 18),
                block(
                  label: 'Bill to',
                  icon: Icons.person_rounded,
                  iconBg: BillingTheme.scaffoldBg,
                  iconFg: BillingTheme.textMuted,
                  title: inv.billingTo.name,
                  subtitle: (inv.billingTo.address ?? '').isEmpty
                      ? '-'
                      : inv.billingTo.address!,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              block(
                label: 'From',
                icon: Icons.domain_rounded,
                iconBg: BillingTheme.purpleLight,
                iconFg: BillingTheme.purple,
                title: inv.billingFrom.name,
                subtitle: inv.billingFrom.address,
              ),
              Container(
                width: 1,
                height: 110,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                color: BillingTheme.border,
              ),
              block(
                label: 'Bill to',
                icon: Icons.person_rounded,
                iconBg: BillingTheme.scaffoldBg,
                iconFg: BillingTheme.textMuted,
                title: inv.billingTo.name,
                subtitle: (inv.billingTo.address ?? '').isEmpty
                    ? '-'
                    : inv.billingTo.address!,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _itemsTable() {
    final money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    Widget th(String s, {TextAlign align = TextAlign.left}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          s.toUpperCase(),
          textAlign: align,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: BillingTheme.textMuted,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: BillingTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BillingTheme.border),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: BillingTheme.scaffoldBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: th('Description')),
                Expanded(flex: 1, child: Center(child: th('Qty', align: TextAlign.center))),
                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: th('Unit price', align: TextAlign.right))),
                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: th('Amount', align: TextAlign.right))),
              ],
            ),
          ),
          ...inv.items.map((it) {
            final amount = it.lineTotal ?? (it.quantity * it.price);
            return Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: BillingTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        it.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: BillingTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        it.quantity.toStringAsFixed(0),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: BillingTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        money.format(it.price),
                        textAlign: TextAlign.right,
                        style: GoogleFonts.plusJakartaSans(color: BillingTheme.textMuted, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        money.format(amount),
                        textAlign: TextAlign.right,
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 320,
                child: Column(
                  children: [
                    _totalLine('Subtotal', money.format(inv.subtotal)),
                    const SizedBox(height: 8),
                    _totalLine('Tax', money.format(inv.taxTotal)),
                    const SizedBox(height: 12),
                    Container(height: 1, color: BillingTheme.border),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: BillingTheme.purple,
                            ),
                          ),
                        ),
                        Text(
                          money.format(inv.grandTotal),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: BillingTheme.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalLine(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: BillingTheme.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: BillingTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _Right extends StatelessWidget {
  final InvoiceReviewModel inv;
  final VoidCallback onDownload;
  final VoidCallback? onIssue;

  const _Right({
    required this.inv,
    required this.onDownload,
    required this.onIssue,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = inv.status.toUpperCase() == 'DRAFT';
    final statusText = isDraft ? 'Draft' : 'Issued';
    final badgeBg = isDraft ? const Color(0xFFE5E7EB) : const Color(0xFFDCFCE7);
    final badgeFg = isDraft ? const Color(0xFF374151) : const Color(0xFF166534);

    final money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dueFmt = DateFormat('MMM d, yyyy');

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [BillingTheme.purple, Color(0xFF5D21DF)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: BillingTheme.purple.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusText.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: badgeFg,
                      ),
                    ),
                  ),
                  const Icon(Icons.verified_rounded, color: Colors.white54, size: 34),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Total amount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                money.format(inv.grandTotal),
                style: GoogleFonts.manrope(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due date',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          inv.dueDate == null ? '-' : dueFmt.format(inv.dueDate!.toLocal()),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ),
                ],
              ),
              if (isDraft && onIssue != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onIssue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Issue invoice',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Intentionally keep a single download option on the page (header button).
      ],
    );
  }
}

