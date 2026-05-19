import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/invoice_review_model.dart';
import '../../theme/billing_theme.dart';
import '../../theme/billing_adaptive_theme.dart';

class InvoiceDetailLayout extends StatelessWidget {
  final InvoiceReviewModel inv;
  final VoidCallback onDownload;
  final VoidCallback? onIssue;

  const InvoiceDetailLayout({
    super.key,
    required this.inv,
    required this.onDownload,
    required this.onIssue,
  });

  static const Color inkText = Color(0xFF1A1C1E);
  static const Color accentOrange = Color(0xFFB14D1E);
  static const Color clayFill = Color(0xFFF5E6DA);
  static const Color paperWhite = Color(0xFFFFFDFB);
  static const Color deepInk = Color(0xFF8D5B39);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = BillingAdaptiveTheme.isMobile(context);

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 1100;
        final left = _Left(inv: inv, onDownload: onDownload, isMobile: isMobile);
        final right = _Right(inv: inv, onDownload: onDownload, onIssue: onIssue, isMobile: isMobile);

        if (!wide) {
          return Column(
            children: [
              left,
              const SizedBox(height: 20),
              right,
            ],
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 8, child: left),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: right),
              ],
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
  final bool isMobile;

  const _Left({required this.inv, required this.onDownload, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMMM d, yyyy');
    final issuedText = inv.status.toUpperCase() == 'DRAFT'
        ? 'Draft Mode'
        : 'Issued: ${dateFmt.format(inv.invoiceDate.toLocal())}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          Text('INVOICE DETAIL',
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: InvoiceDetailLayout.accentOrange)),
          const SizedBox(height: 4),
          Text(inv.invoiceNumber,
              style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: InvoiceDetailLayout.inkText,
                  letterSpacing: -1)),
          const SizedBox(height: 2),
          Text(issuedText,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: InvoiceDetailLayout.inkText.withOpacity(0.5))),
        ] else ...[
          _breadcrumb(),
          const SizedBox(height: 12),
          Text('Invoice Detail', style: BillingTheme.titleLarge()),
          Text(issuedText, style: BillingTheme.body()),
        ],
        const SizedBox(height: 28),
        _bentoFromTo(),
        const SizedBox(height: 18),
        _itemsTable(),
      ],
    );
  }

  Widget _breadcrumb() {
    return Row(
      children: [
        Text('Invoices', style: BillingTheme.body().copyWith(fontSize: 12)),
        const Icon(Icons.chevron_right_rounded,
            size: 18, color: BillingTheme.textMuted),
        Text(inv.invoiceNumber,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: BillingTheme.purple)),
      ],
    );
  }

  Widget _bentoFromTo() {
    Widget block(
        {required String label, required String title, required String subtitle}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: isMobile
                  ? GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: InvoiceDetailLayout.accentOrange,
                letterSpacing: 1.1,
              )
                  : BillingTheme.overline(),
            ),
            const SizedBox(height: 8),
            Text(
              title.toUpperCase(),
              style: isMobile
                  ? GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  color: InvoiceDetailLayout.inkText,
                  fontSize: 15)
                  : BillingTheme.cardTitle(),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: isMobile
                  ? GoogleFonts.inter(
                  fontSize: 13,
                  color: InvoiceDetailLayout.inkText.withOpacity(0.6),
                  height: 1.4)
                  : BillingTheme.body(),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isMobile ? InvoiceDetailLayout.clayFill : BillingTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: InvoiceDetailLayout.accentOrange.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: isMobile
          ? Column(
        children: [
          Row(children: [
            block(
                label: 'From',
                title: inv.billingFrom.name,
                subtitle: inv.billingFrom.address)
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(
                height: 1,
                color: InvoiceDetailLayout.accentOrange.withOpacity(0.1)),
          ),
          Row(children: [
            block(
                label: 'To',
                title: inv.billingTo.name,
                subtitle: inv.billingTo.address ?? '-')
          ]),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          block(
              label: 'From',
              title: inv.billingFrom.name,
              subtitle: inv.billingFrom.address),
          const SizedBox(width: 12),
          block(
              label: 'To',
              title: inv.billingTo.name,
              subtitle: inv.billingTo.address ?? '-'),
        ],
      ),
    );
  }

  Widget _itemsTable() {
    final money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: isMobile ? InvoiceDetailLayout.clayFill : BillingTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: InvoiceDetailLayout.accentOrange.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          ...inv.items.map((it) {
            final amount = it.lineTotal ?? (it.quantity * it.price);
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: InvoiceDetailLayout.accentOrange.withOpacity(0.05)))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.description,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: InvoiceDetailLayout.inkText)),
                        const SizedBox(height: 4),
                        Text(
                            '${it.quantity.toStringAsFixed(0)} × ${money.format(it.price)}',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: InvoiceDetailLayout.inkText.withOpacity(0.4))),
                      ],
                    ),
                  ),
                  Text(money.format(amount),
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900, fontSize: 15)),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('GRAND TOTAL',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: InvoiceDetailLayout.accentOrange,
                        letterSpacing: 1)),
                Text(money.format(inv.grandTotal),
                    style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: InvoiceDetailLayout.deepInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Right extends StatelessWidget {
  final InvoiceReviewModel inv;
  final VoidCallback onDownload;
  final VoidCallback? onIssue;
  final bool isMobile;

  const _Right(
      {required this.inv,
        required this.onDownload,
        required this.onIssue,
        required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          if (inv.status.toUpperCase() == 'DRAFT' && onIssue != null) ...[
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: onIssue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: InvoiceDetailLayout.deepInk,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text('ISSUE INVOICE',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_rounded, size: 20, color: InvoiceDetailLayout.deepInk),
              label: Text(
                'DOWNLOAD PDF',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  color: InvoiceDetailLayout.deepInk,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: InvoiceDetailLayout.clayFill,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: InvoiceDetailLayout.accentOrange.withOpacity(0.1)),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BillingTheme.purple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total amount',
              style: TextStyle(color: Colors.white.withOpacity(0.8))),
          Text(money.format(inv.grandTotal),
              style: GoogleFonts.manrope(
                  fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
          if (inv.status.toUpperCase() == 'DRAFT' && onIssue != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onIssue, child: const Text('Issue invoice')),
          ]
        ],
      ),
    );
  }
}