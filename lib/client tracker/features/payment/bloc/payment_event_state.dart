import 'package:my_app/client tracker/features/payment/model/payment_model.dart';

// ── Events ──────────────────────────────────────────────
abstract class PaymentEvent {}

class LoadPaymentsEvent extends PaymentEvent {
  final int month;
  final int year;

  LoadPaymentsEvent(this.month, this.year);
}

class UpdatePaymentEvent extends PaymentEvent {
  final int paymentId;

  // ✅ changed to nullable
  final bool? invoiceSent;
  final bool? paymentReceived;

  UpdatePaymentEvent({
    required this.paymentId,
    required this.invoiceSent,
    required this.paymentReceived,
  });
}

// ── States ──────────────────────────────────────────────
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;
  final int month;
  final int year;

  PaymentLoaded(this.payments, this.month, this.year);
}

class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);
}