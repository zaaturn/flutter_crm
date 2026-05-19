import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event_state.dart';
import '../repository/payment_repository.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repo;

  PaymentBloc(this._repo) : super(PaymentInitial()) {
    on<LoadPaymentsEvent>(_onLoad);
    on<UpdatePaymentEvent>(_onUpdate);
  }

  Future<void> _onLoad(LoadPaymentsEvent event, Emitter emit) async {
    emit(PaymentLoading());
    try {
      final payments = await _repo.getPayments(event.month, event.year);
      emit(PaymentLoaded(payments, event.month, event.year));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdatePaymentEvent event, Emitter emit) async {
    final current = state;
    if (current is! PaymentLoaded) return;

    try {
      // ✅ We now pass nulls through so "Select" is preserved correctly.
      final updated = await _repo.updatePayment(
        event.paymentId,
        event.invoiceSent,
        event.paymentReceived,
      );

      final list = current.payments.map((p) {
        if (p.id == updated.id) return updated;
        return p;
      }).toList();

      emit(PaymentLoaded(list, current.month, current.year));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
