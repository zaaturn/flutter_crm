import 'package:my_app/billing/models/CompanyBankDetailsModel.dart';

class CompanyModel {
  final String? id;

  final String name;
  final String gstNumber;
  final Map<String, dynamic> address;

  final String state;
  final String country;
  final String currency;

  final String invoiceTheme;

  final String? logoUrl;
  final String? signatureUrl;

  final CompanyBankDetailsModel? bankDetails;

  CompanyModel({
    this.id,
    required this.name,
    required this.gstNumber,
    required this.address,
    required this.state,
    required this.country,
    required this.currency,
    required this.invoiceTheme,
    this.logoUrl,
    this.signatureUrl,
    this.bankDetails,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      gstNumber: json['gst_number'] ?? '',
      address: json['address'] is Map<String, dynamic>
          ? json['address']
          : {},
      state: json['state'] ?? '',
      country: json['country'] ?? 'India',
      currency: json['currency'] ?? 'INR',
      invoiceTheme: json['invoice_theme'] ?? 'classic',


      logoUrl: json['logo'],
      signatureUrl: json['signature_url'],

      bankDetails: json['bank_details'] != null
          ? CompanyBankDetailsModel.fromJson(json['bank_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gst_number': gstNumber,
      'address': address,
      'state': state,
      'country': country,
      'currency': currency,
      'invoice_theme': invoiceTheme,
      'logo': logoUrl,
      'signature_url': signatureUrl,
      'bank_details': bankDetails?.toJson(),
    };
  }
}


