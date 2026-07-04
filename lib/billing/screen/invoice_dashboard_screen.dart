import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/invoice_list_item.dart';
import '../navigation/billing_flow_controller.dart';
import '../services/billing_dio_api.dart';
import '../theme/billing_theme.dart';
import '../theme/billing_adaptive_theme.dart';
import '../widgets/billing_app_bar.dart';
import 'invoice_review_screen.dart';
import 'edit_invoice_draft_screen.dart';
import 'invoice_dashboard_mobile_list.dart';
import 'invoice_dashboard_table.dart';

class InvoiceDashboardScreen extends StatefulWidget {
  final String? initialMonth;
  final String? highlightInvoiceId;

  const InvoiceDashboardScreen({
    super.key,
    this.initialMonth,
    this.highlightInvoiceId,
  });

  @override
  State<InvoiceDashboardScreen> createState() => _InvoiceDashboardScreenState();
}

class _InvoiceDashboardScreenState extends State<InvoiceDashboardScreen> {
  late String _month;
  bool _loading = true;
  String? _error;
  List<InvoiceListItem> _items = const [];
  String _query = '';
  String _paymentFilter = 'ALL'; // ALL | PENDING | PAID
  String _issueFilter = 'ALL'; // ALL | DRAFT | ISSUED
  int _page = 0;
  static const int _pageSize = 8;

  static const _paymentOptions = [
    'PENDING',
    'PAID',
  ];

  @override
  void initState() {
    super.initState();
    _month = widget.initialMonth ?? DateFormat('yyyy-MM').format(DateTime.now());
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await BillingDioApi.listInvoicesByMonth(month: _month);
      if (!mounted) return;
      setState(() {
        _items = data;
        _page = 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final initial =
        DateTime.tryParse('$_month-01') ?? DateTime(now.year, now.month, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      builder: (ctx, child) =>
          Theme(data: BillingAdaptiveTheme.datePickerTheme(ctx), child: child!),
    );
    if (picked == null) return;
    final m =
        DateFormat('yyyy-MM').format(DateTime(picked.year, picked.month, 1));
    if (m == _month) return;
    setState(() => _month = m);
    await _load();
  }

  void _snack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _normalizedPayment(String raw) {
    final s = raw.trim().toUpperCase();
    if (s.isEmpty) return 'PENDING';
    if (s == 'PAID') return 'PAID';
    return 'PENDING';
  }

  Future<void> _openFilterDialog() async {
    var payment = _paymentFilter;
    var issue = _issueFilter;

    final res = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Filter invoices'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment status'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: payment,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All')),
                  DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                  DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                ],
                onChanged: (v) => payment = v ?? 'ALL',
              ),
              const SizedBox(height: 14),
              const Text('Invoice type'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: issue,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All')),
                  DropdownMenuItem(value: 'DRAFT', child: Text('Draft (not issued)')),
                  DropdownMenuItem(value: 'ISSUED', child: Text('Issued')),
                ],
                onChanged: (v) => issue = v ?? 'ALL',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, {'payment': 'ALL', 'issue': 'ALL'});
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, {'payment': payment, 'issue': issue});
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (res == null) return;
    setState(() {
      _paymentFilter = res['payment'] ?? 'ALL';
      _issueFilter = res['issue'] ?? 'ALL';
      _page = 0;
    });
  }

  List<InvoiceListItem> get _filtered {
    final q = _query.trim().toLowerCase();
    return _items.where((inv) {
      if (q.isNotEmpty) {
        final okQuery = inv.invoiceNumber.toLowerCase().contains(q) ||
            inv.clientName.toLowerCase().contains(q);
        if (!okQuery) return false;
      }

      if (_paymentFilter != 'ALL') {
        final p = _normalizedPayment(inv.paymentStatus);
        if (p != _paymentFilter) return false;
      }

      if (_issueFilter != 'ALL') {
        final isIssued = inv.isIssued == true;
        if (_issueFilter == 'ISSUED' && !isIssued) return false;
        if (_issueFilter == 'DRAFT' && isIssued) return false;
      }

      return true;
    }).toList();
  }

  List<InvoiceListItem> get _paged {
    final list = _filtered;
    final start = (_page * _pageSize).clamp(0, list.length);
    final end = (start + _pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 980;
    final filtered = _filtered;
    final pages = (filtered.length / _pageSize).ceil().clamp(1, 999999);
    if (_page > pages - 1) _page = pages - 1;

    return Scaffold(
      backgroundColor: BillingAdaptiveTheme.canvas(context),
      appBar: billingAppBar(
        title: 'Invoices',
        onBack: () => BillingFlowController.backToAdminDashboard(context),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _pickMonth,
              icon: Icon(
                Icons.calendar_month_rounded,
                color: BillingAdaptiveTheme.primary(context),
                size: 22,
              ),
              label: Text(
                _month,
                style: TextStyle(
                  color: BillingAdaptiveTheme.primary(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: BillingAdaptiveTheme.primary(context),
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 48),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: BillingTheme.body().copyWith(color: BillingAdaptiveTheme.muted(context)),
                        ),
                      ),
                    ],
                  )
                : isWide
                    ? InvoiceDashboardTable(
                        items: _paged,
                        monthLabel: _month,
                        page: _page,
                        pageSize: _pageSize,
                        total: filtered.length,
                        query: _query,
                        onQueryChanged: (v) => setState(() {
                          _query = v;
                          _page = 0;
                        }),
                        onCreateInvoice: () =>
                            BillingFlowController.startGenerate(context),
                        onFilter: _openFilterDialog,
                        onMonthPill: (m) async {
                          if (m == _month) return;
                          setState(() => _month = m);
                          await _load();
                        },
                        onPrevPage: () => setState(() => _page = (_page - 1).clamp(0, pages - 1)),
                        onNextPage: () => setState(() => _page = (_page + 1).clamp(0, pages - 1)),
                        onGotoPage: (p) => setState(() => _page = p.clamp(0, pages - 1)),
                        onOpenDetails: (inv) => Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => InvoiceReviewScreen(invoiceId: inv.id)),
                        ),
                        onDownload: (inv) async {
                          try {
                            final bytes = await BillingDioApi.downloadInvoicePdfBytes(invoiceId: inv.id);
                            if (!context.mounted) return;
                            await BillingFlowController.saveAndOpenPdf(
                              context,
                              bytes: bytes,
                              filename: 'INV-${inv.invoiceNumber}.pdf',
                            );
                          } catch (_) {
                            _snack('Download failed');
                          }
                        },
                        onIssue: (inv) async {
                          try {
                            await BillingDioApi.issueInvoice(invoiceId: inv.id);
                            _snack('Invoice issued.', isError: false);
                            await _load();
                          } catch (_) {
                            _snack('Issue failed');
                          }
                        },
                        onPaymentChanged: (id, status) async {
                          try {
                            await BillingDioApi.updatePaymentStatus(
                              invoiceId: id,
                              paymentStatus: status,
                            );
                            _snack('Payment status updated.', isError: false);
                            await _load();
                          } catch (_) {
                            _snack('Failed to update payment status');
                          }
                        },
                        onEditDraft: (inv) async {
                          final updated = await Navigator.of(context, rootNavigator: true).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => EditInvoiceDraftScreen(invoiceId: inv.id),
                            ),
                          );
                          if (updated == true) await _load();
                        },
                      )
                    : InvoiceDashboardMobileList(
                        items: _filtered,
                        highlightInvoiceId: widget.highlightInvoiceId,
                        paymentOptions: _paymentOptions,
                        onPaymentChanged: (id, status) async {
                          try {
                            await BillingDioApi.updatePaymentStatus(
                              invoiceId: id,
                              paymentStatus: status,
                            );
                            _snack('Payment status updated.', isError: false);
                            await _load();
                          } catch (_) {
                            _snack('Failed to update payment status');
                          }
                        },
                        onIssue: (inv) async {
                          try {
                            await BillingDioApi.issueInvoice(invoiceId: inv.id);
                            _snack('Invoice issued.', isError: false);
                            await _load();
                          } catch (_) {
                            _snack('Issue failed');
                          }
                        },
                        onDownload: (inv) async {
                          try {
                            final bytes = await BillingDioApi.downloadInvoicePdfBytes(
                              invoiceId: inv.id,
                            );
                            if (!context.mounted) return;
                            await BillingFlowController.saveAndOpenPdf(
                              context,
                              bytes: bytes,
                              filename: 'INV-${inv.invoiceNumber}.pdf',
                            );
                          } catch (_) {
                            _snack('Download failed');
                          }
                        },
                        onAfterEdit: _load,
                      ),
      ),
    );
  }
}
