import 'package:my_app/client tracker/core/network/api_services.dart';
import 'package:my_app/client tracker/core/constants/app_constant.dart';
import '../model/payment_model.dart';

class PaymentRepository {
  final ApiClient _api = ApiClient();

  Future<List<PaymentModel>> getPayments(int month, int year) async {
    final data = await _api.get(AppConstants.payments, queryParams: {
      'month': month.toString(),
      'year': year.toString(),
    });
    return (data as List).map((e) => PaymentModel.fromJson(e)).toList();
  }

  Future<PaymentModel> updatePayment(
      int id, bool? invoiceSent, bool? paymentReceived) async {
    final data = await _api.patch(AppConstants.paymentById(id), {
      'invoice_sent': invoiceSent,
      'payment_received': paymentReceived,
    });
    return PaymentModel.fromJson(data);
  }
}
