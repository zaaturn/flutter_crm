import 'package:flutter/material.dart';

import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';
import '../services/billing_api.dart';





class InvoicePreviewScreen extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoicePreviewScreen({required this.invoice, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice #${invoice.number}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "₹${invoice.total}",
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Chip(label: Text(invoice.status)),
          const Divider(),
          _party("FROM", invoice.companyName, invoice.companyAddress),
          _party("TO", invoice.clientName, invoice.clientAddress),
          const Divider(),
          ...invoice.items.map((e) => ListTile(
            title: Text(e.name),
            trailing: Text("₹${e.total}"),
          )),
          const Divider(),
          ElevatedButton(
            onPressed: _finalize,
            child: const Text("Finalize & Send"),
          )
        ],
      ),
    );
  }

  Widget _party(String label, String name, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(address),
      ],
    );
  }

  void _finalize() async {
    // issue + generate pdf
  }
}
