import 'package:flutter/material.dart';

import '../models/invoice_list_item.dart';
import '../theme/billing_theme.dart';
import 'invoice_dashboard_row.dart';

class InvoiceDashboardMobileList extends StatelessWidget {
  final List<InvoiceListItem> items;
  final String? highlightInvoiceId;
  final List<String> paymentOptions;
  final void Function(String invoiceId, String status) onPaymentChanged;
  final void Function(InvoiceListItem inv) onIssue;
  final void Function(InvoiceListItem inv) onDownload;
  final Future<void> Function() onAfterEdit;

  const InvoiceDashboardMobileList({
    super.key,
    required this.items,
    required this.highlightInvoiceId,
    required this.paymentOptions,
    required this.onPaymentChanged,
    required this.onIssue,
    required this.onDownload,
    required this.onAfterEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F3EE),
      child: _buildList(),
    );
  }

  Widget _buildList() {
    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              'No invoices this month.',
              style: BillingTheme.body().copyWith(
                color: const Color(0xFF1A1C1E).withOpacity(0.5),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final inv = items[i];
        return InvoiceDashboardRow(
          inv: inv,
          highlight: highlightInvoiceId == inv.id,
          paymentOptions: paymentOptions,
          onPaymentChanged: onPaymentChanged,
          onIssue: () => onIssue(inv),
          onDownload: () => onDownload(inv),
          onAfterEdit: onAfterEdit,
        );
      },
    );
  }
}