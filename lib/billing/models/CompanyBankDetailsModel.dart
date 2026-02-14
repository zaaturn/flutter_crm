class CompanyBankDetailsModel {
  final String? accountHolderName;
  final String bankName;
  final String? accountNumber; // For sending to API
  final String? accountNumberMasked; // For display from API
  final String ifscCode;
  final String? upiId;

  CompanyBankDetailsModel({
    this.accountHolderName,
    required this.bankName,
    this.accountNumber,
    this.accountNumberMasked,
    required this.ifscCode,
    this.upiId,
  });

  factory CompanyBankDetailsModel.fromJson(Map<String, dynamic> json) {
    return CompanyBankDetailsModel(
      accountHolderName: json['account_holder_name'],
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'], // Usually not returned by API
      accountNumberMasked: json['account_number_masked'],
      ifscCode: json['ifsc_code'] ?? '',
      upiId: json['upi_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (accountHolderName != null) 'account_holder_name': accountHolderName,
      'bank_name': bankName,
      if (accountNumber != null) 'account_number': accountNumber, // Send actual number
      if (accountNumberMasked != null) 'account_number_masked': accountNumberMasked,
      'ifsc_code': ifscCode,
      if (upiId != null) 'upi_id': upiId,
    };
  }
}