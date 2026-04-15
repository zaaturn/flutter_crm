import 'package:flutter/material.dart';
import 'package:my_app/billing/screen/billing_home_screen.dart';
import 'package:my_app/billing/screen/invoice_dashboard_screen.dart';
import 'dart:typed_data';

import '../screen/company_profile_screen.dart';
import '../screen/create_invoice_screen.dart';
import '../screen/choose_company_screen.dart';
import '../utils/pdf_saver.dart';

class BillingFlowController {

  static Future<void> start(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const BillingHomeScreen(),
      ),
    );
  }

  static Future<void> startGenerate(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const ChooseCompanyScreen(),
      ),
    );
  }

  static Future<void> startTrack(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const InvoiceDashboardScreen(),
      ),
    );
  }

  static void backToAdminDashboard(BuildContext context) {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    nav.pushNamed('/adminDashboard');
  }

  static Future<void> saveAndOpenPdf(
    BuildContext context, {
    required Uint8List bytes,
    required String filename,
  }) async {
    final path = await savePdfBytes(bytes: bytes, filename: filename);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          path == null ? 'Invoice download started.' : 'Invoice saved successfully.',
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> goToCreateInvoice(
      BuildContext context, {
        required String companyId,
        required String authToken,
      }) async {


    final invoiceId = await Navigator.of(context, rootNavigator: true)
        .push<String>(
      MaterialPageRoute(
        builder: (_) => CreateInvoiceScreen(companyId: companyId),
      ),
    );

    if (invoiceId == null) return;

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice saved successfully'),
        backgroundColor: Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );

    await Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (_) => InvoiceDashboardScreen(highlightInvoiceId: invoiceId),
      ),
    );
  }

  static Future<void> goToCreateNewCompany(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const CompanyProfileScreen(),
      ),
    );
  }
}




