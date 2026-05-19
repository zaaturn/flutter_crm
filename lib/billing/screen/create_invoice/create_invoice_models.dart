import 'package:flutter/material.dart';

import '../../models/company_model.dart';
import '../../models/invoice_item_model.dart';
import '../../models/pdf_design_option.dart';

class CreateInvoiceState {
  CompanyModel? selectedCompany;
  PdfDesignOption? selectedDesign;

  DateTime invoiceDate;
  DateTime dueDate;

  final TextEditingController clientNameCtrl;
  final TextEditingController clientGstinCtrl;
  final TextEditingController clientAddressCtrl;
  final TextEditingController clientStateCtrl;

  final List<InvoiceItemModel> items;

  CreateInvoiceState({
    required this.selectedCompany,
    required this.selectedDesign,
    required this.invoiceDate,
    required this.dueDate,
    required this.clientNameCtrl,
    required this.clientGstinCtrl,
    required this.clientAddressCtrl,
    required this.clientStateCtrl,
    required this.items,
  });

  double get subtotal => items.fold(0.0, (sum, i) => sum + (i.quantity * i.unitPrice));

  double get taxTotal => items.fold(
        0.0,
        (sum, i) => sum + ((i.quantity * i.unitPrice) * (i.taxRate / 100.0)),
      );

  double get grandTotal => subtotal + taxTotal;
}

