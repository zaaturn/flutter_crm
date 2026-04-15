import 'package:flutter/material.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';
import '../services/billing_api.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoicePreviewScreen({required this.invoice, super.key});

  static const Color _surface = Color(0xFF0A0A0B);
  static const Color _cardBg = Color(0xFF141416);
  static const Color _accent = Color(0xFF6366F1);
  static const Color _border = Color(0xFF27272A);
  static const Color _textPrimary = Color(0xFFF4F4F5);
  static const Color _textSecondary = Color(0xFF71717A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "PREVIEW: #${invoice.invoiceNumber}",
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.2,
            color: _textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: _accent, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 40),
              _sectionHeader("ENTITY RECIPIENTS"),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _party("ORIGIN / FROM", invoice.companyName, invoice.companyAddress)),
                  Container(width: 1, height: 80, color: _border, margin: const EdgeInsets.symmetric(horizontal: 24)),
                  Expanded(child: _party("DESTINATION / TO", invoice.clientName, invoice.clientAddress)),
                ],
              ),
              const SizedBox(height: 40),
              _sectionHeader("LINE ITEM MANIFEST"),
              ...invoice.items.map((e) => _itemRow(e)),
              const SizedBox(height: 32),
              const Divider(color: _border, thickness: 1),
              const SizedBox(height: 24),
              _buildFinalAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TOTAL AGGREGATE",
          style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "₹${invoice.totalAmount}",
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: _textPrimary, letterSpacing: -1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accent.withOpacity(0.5)),
              ),
              child: Text(
                invoice.status.toUpperCase(),
                style: const TextStyle(color: _accent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900, color: _textSecondary)),
          const SizedBox(width: 16),
          Expanded(child: Container(height: 1, color: _border)),
        ],
      ),
    );
  }

  Widget _party(String label, String name, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _textPrimary)),
        const SizedBox(height: 4),
        Text(address, style: const TextStyle(color: _textSecondary, fontSize: 13, height: 1.4)),
      ],
    );
  }

  Widget _itemRow(dynamic e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(e.name, style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          Text(
            "₹${e.total}",
            style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalAction() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _finalize,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              "FINALIZE & DEPLOY INVOICE",
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _finalize() async {

  }
}