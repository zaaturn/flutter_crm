import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/invoice_list_item.dart';
import '../theme/billing_theme.dart';

class InvoiceDashboardTable extends StatelessWidget {
  final List<InvoiceListItem> items;
  final String monthLabel;
  final int page;
  final int pageSize;
  final int total;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onCreateInvoice;
  final VoidCallback onFilter;
  final ValueChanged<String> onMonthPill; // yyyy-MM
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;
  final ValueChanged<int> onGotoPage;
  final void Function(InvoiceListItem inv) onOpenDetails;
  final void Function(InvoiceListItem inv) onDownload;
  final void Function(InvoiceListItem inv) onIssue;
  final void Function(String invoiceId, String status) onPaymentChanged;
  final Future<void> Function(InvoiceListItem inv) onEditDraft;

  const InvoiceDashboardTable({
    super.key,
    required this.items,
    required this.monthLabel,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.query,
    required this.onQueryChanged,
    required this.onCreateInvoice,
    required this.onFilter,
    required this.onMonthPill,
    required this.onPrevPage,
    required this.onNextPage,
    required this.onGotoPage,
    required this.onOpenDetails,
    required this.onDownload,
    required this.onIssue,
    required this.onPaymentChanged,
    required this.onEditDraft,
  });

  @override
  Widget build(BuildContext context) {
    final pages = (total / pageSize).ceil().clamp(1, 999999);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 18),
              _monthPills(),
              const SizedBox(height: 18),
              _tableCard(context),
              const SizedBox(height: 14),
              _pagination(pages: pages),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoices', style: BillingTheme.titleLarge()),
              const SizedBox(height: 6),
              Text(
                'Manage and monitor your financial transactions with precision.',
                style: BillingTheme.body(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _monthPills() {
    // Show a 6-month window centered around current selected month.
    final current = DateTime.tryParse('$monthLabel-01') ?? DateTime.now();
    final months = List.generate(6, (i) {
      final d = DateTime(current.year, current.month - 3 + i, 1);
      return d;
    });
    final short = DateFormat('MMM');

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: BillingTheme.purpleLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BillingTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: months.map((d) {
            final key = DateFormat('yyyy-MM').format(d);
            final selected = key == monthLabel;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: TextButton(
                onPressed: () => onMonthPill(key),
                style: TextButton.styleFrom(
                  backgroundColor: selected ? BillingTheme.surface : Colors.transparent,
                  foregroundColor: selected ? BillingTheme.purple : BillingTheme.textMuted,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  short.format(d),
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _tableCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BillingTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BillingTheme.border),
        boxShadow: [
          BoxShadow(
            color: BillingTheme.purple.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _controls(),
          const Divider(height: 1, color: BillingTheme.border),
          _table(context),
        ],
      ),
    );
  }

  Widget _controls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: query)
                ..selection = TextSelection.collapsed(offset: query.length),
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search by invoice number or client name...',
                filled: true,
                fillColor: BillingTheme.scaffoldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onFilter,
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text('Filter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: BillingTheme.textPrimary,
              backgroundColor: BillingTheme.scaffoldBg,
              side: const BorderSide(color: BillingTheme.border),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onCreateInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: BillingTheme.purple,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Create Invoice', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _table(BuildContext context) {
    final money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFmt = DateFormat('MMM dd, yyyy');

    Widget th(String text, {TextAlign align = TextAlign.left}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Text(
          text.toUpperCase(),
          textAlign: align,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: BillingTheme.textMuted,
          ),
        ),
      );
    }

    Widget cell(Widget child, {TextAlign align = TextAlign.left}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: DefaultTextStyle(
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: BillingTheme.textPrimary,
          ),
          child: child,
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: BillingTheme.scaffoldBg,
          child: Row(
            children: [
              Expanded(flex: 2, child: th('Invoice number')),
              Expanded(flex: 3, child: th('Client name')),
              Expanded(flex: 2, child: th('Date issued')),
              Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: th('Amount', align: TextAlign.right))),
              Expanded(flex: 2, child: Align(alignment: Alignment.center, child: th('Status', align: TextAlign.center))),
              SizedBox(width: 160, child: Align(alignment: Alignment.centerRight, child: th('Actions', align: TextAlign.right))),
            ],
          ),
        ),
        ...items.map((inv) {
          return InkWell(
            onTap: () => onOpenDetails(inv),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: BillingTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: cell(Text(inv.invoiceNumber, style: GoogleFonts.manrope(fontWeight: FontWeight.w800))),
                  ),
                  Expanded(
                    flex: 3,
                    child: cell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: BillingTheme.purpleLight,
                            child: Text(
                              _initials(inv.clientName),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                color: BillingTheme.purpleDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(inv.clientName)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: cell(
                      Text(
                        inv.dateIssued == null ? '-' : dateFmt.format(inv.dateIssued!.toLocal()),
                        style: GoogleFonts.plusJakartaSans(color: BillingTheme.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: cell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          money.format(inv.amount),
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(child: _statusDropdown(inv)),
                  ),
                  SizedBox(
                    width: 160,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!inv.isIssued) ...[
                            IconButton(
                              onPressed: () async => onEditDraft(inv),
                              icon: const Icon(Icons.edit_rounded),
                              color: BillingTheme.purple,
                              tooltip: 'Edit draft',
                            ),
                            const SizedBox(width: 4),
                          ],
                          _issueButton(inv),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: inv.hasPdf ? () => onDownload(inv) : null,
                            icon: const Icon(Icons.file_download_outlined),
                            color: BillingTheme.purple,
                            tooltip: 'Download PDF',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _statusDropdown(InvoiceListItem inv) {
    final normalized = _normalizedPayment(inv.paymentStatus);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: normalized,
        items: const [
          DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
          DropdownMenuItem(value: 'PAID', child: Text('PAID')),
        ],
        onChanged: (v) {
          if (v == null) return;
          onPaymentChanged(inv.id, v);
        },
        dropdownColor: BillingTheme.surface,
        borderRadius: BorderRadius.circular(14),
        icon: const Icon(Icons.expand_more_rounded, size: 18, color: BillingTheme.textMuted),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: BillingTheme.textPrimary,
        ),
        selectedItemBuilder: (context) {
          return ['PENDING', 'PAID'].map((s) {
            return Align(
              alignment: Alignment.center,
              child: _statusBadge(s),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _issueButton(InvoiceListItem inv) {
    if (inv.isIssued) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Text(
          'Issued',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF059669),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => onIssue(inv),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDC2626),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Issue',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 11),
      ),
    );
  }

  Widget _pagination({required int pages}) {
    final start = (page * pageSize) + 1;
    final end = (start + items.length - 1).clamp(0, total);

    List<int> visiblePages() {
      // Show up to 5 page pills around current.
      final from = (page - 2).clamp(0, pages - 1);
      final to = (from + 4).clamp(0, pages - 1);
      final start2 = (to - 4).clamp(0, pages - 1);
      return [for (var i = start2; i <= to; i++) i];
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            'Showing $start-$end of $total invoices',
            style: BillingTheme.body().copyWith(fontSize: 12),
          ),
        ),
        Row(
          children: [
            _pageIcon(
              icon: Icons.chevron_left_rounded,
              enabled: page > 0,
              onTap: onPrevPage,
            ),
            const SizedBox(width: 8),
            ...visiblePages().map((p) => _pagePill(p, selected: p == page)),
            const SizedBox(width: 8),
            _pageIcon(
              icon: Icons.chevron_right_rounded,
              enabled: page < pages - 1,
              onTap: onNextPage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _pagePill(int p, {required bool selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: () => onGotoPage(p),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? BillingTheme.purple : BillingTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BillingTheme.border),
          ),
          child: Text(
            '${p + 1}',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              color: selected ? Colors.white : BillingTheme.textPrimary,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageIcon({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: BillingTheme.scaffoldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BillingTheme.border),
        ),
        child: Icon(icon, color: enabled ? BillingTheme.textMuted : BillingTheme.border),
      ),
    );
  }

  Widget _statusBadge(String status) {
    // Map common status values to a chip similar to the reference.
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'PAID':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'PAID';
        break;
      case 'OVERDUE':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'OVERDUE';
        break;
      case 'PENDING':
      case 'UNPAID':
      default:
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
        label = status.isEmpty ? 'PENDING' : status;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: fg,
        ),
      ),
    );
  }

  String _normalizedPayment(String raw) {
    final s = raw.trim().toUpperCase();
    if (s.isEmpty) return 'PENDING';
    if (s == 'PAID') return 'PAID';
    return 'PENDING';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'C';
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts[1].characters.first : '';
    return (first + second).toUpperCase();
  }
}

