import 'package:flutter/material.dart';

import '../screen/company_profile_screen.dart';
import '../screen/create_invoice_screen.dart';
import '../screen/choose_company_screen.dart';
import '../screen/invoice_review_screen.dart';

class BillingFlowController {

  static Future<void> start(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const ChooseCompanyScreen(),
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


    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => InvoiceReviewScreen(
          invoiceId: invoiceId

        ),
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




