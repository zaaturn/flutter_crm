import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/client tracker/features/payment/bloc/payment_bloc.dart';
import 'package:my_app/client tracker/features/payment/bloc/payment_event_state.dart';
import 'package:my_app/client tracker/features/payment/model/payment_model.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0); // Light Cream
  static const Color cardColor = Color(0xFFEADBC8);   // Terracotta/Beige box
  static const Color subBoxColor = Color(0xFFF2E6D6); // Inner row color
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color textMain = Color(0xFF1A1A1A);
  static const Color headerBlue = Color(0xFF0D47A1);
}

class ClientTrackerMobilePayments extends StatefulWidget {
  const ClientTrackerMobilePayments({super.key});

  @override
  State<ClientTrackerMobilePayments> createState() =>
      _ClientTrackerMobilePaymentsState();
}

class _ClientTrackerMobilePaymentsState extends State<ClientTrackerMobilePayments> {
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaymentBloc>().add(LoadPaymentsEvent(_month, _year));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZaaturnUI.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                color: ZaaturnUI.accentOrange,
                onRefresh: () async {
                  context.read<PaymentBloc>().add(LoadPaymentsEvent(_month, _year));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // DROPDOWN FILTER LOGIC RESTORED
                    _MonthPicker(
                      month: _month,
                      year: _year,
                      onChanged: (m, y) {
                        setState(() {
                          _month = m;
                          _year = y;
                        });
                        context.read<PaymentBloc>().add(LoadPaymentsEvent(m, y));
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildBlocContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: Colors.blueAccent),
          ),
          Text(
            'Payments',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ZaaturnUI.headerBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlocContent() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoading || state is PaymentInitial) {
          return const Center(child: CircularProgressIndicator(color: ZaaturnUI.accentOrange));
        }
        if (state is PaymentError) {
          return _ErrorCard(
            message: state.message,
            onRetry: () => context.read<PaymentBloc>().add(LoadPaymentsEvent(_month, _year)),
          );
        }
        if (state is PaymentLoaded) {
          if (state.payments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text('No payments found.', style: GoogleFonts.manrope(color: Colors.brown)),
              ),
            );
          }
          return Column(
            children: state.payments.map((p) => _PaymentCard(payment: p)).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final int month;
  final int year;
  final void Function(int month, int year) onChanged;

  const _MonthPicker({required this.month, required this.year, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final months = List<int>.generate(12, (i) => i + 1);
    final years = List<int>.generate(6, (i) => DateTime.now().year - 3 + i);

    return Container(
      decoration: BoxDecoration(
        color: ZaaturnUI.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Month Dropdown
          Expanded(
            child: _styledDropdown<int>(
              value: month,
              items: months.map((m) => DropdownMenuItem(
                value: m,
                child: Text(DateFormat.MMM().format(DateTime(2024, m))),
              )).toList(),
              onChanged: (v) => v != null ? onChanged(v, year) : null,
            ),
          ),
          const SizedBox(width: 12),
          // Year Dropdown
          Expanded(
            child: _styledDropdown<int>(
              value: year,
              items: years.map((y) => DropdownMenuItem(
                value: y,
                child: Text('$y'),
              )).toList(),
              onChanged: (v) => v != null ? onChanged(month, v) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledDropdown<T>({required T value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ZaaturnUI.subBoxColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: ZaaturnUI.accentOrange),
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: ZaaturnUI.textMain),
          dropdownColor: ZaaturnUI.subBoxColor,
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZaaturnUI.cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payment.clientName ?? 'Client',
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w900, color: ZaaturnUI.textMain),
          ),
          const SizedBox(height: 16),
          _toggleRow(
            context,
            label: 'Invoice sent',
            value: payment.invoiceSent ?? false,
            onChanged: (v) => _update(context, inv: v, rec: payment.paymentReceived),
            onReset: () => _update(context, inv: null, rec: payment.paymentReceived),
          ),
          const SizedBox(height: 12),
          _toggleRow(
            context,
            label: 'Payment received',
            value: payment.paymentReceived ?? false,
            onChanged: (v) => _update(context, inv: payment.invoiceSent, rec: v),
            onReset: () => _update(context, inv: payment.invoiceSent, rec: null),
          ),
        ],
      ),
    );
  }

  void _update(BuildContext context, {bool? inv, bool? rec}) {
    context.read<PaymentBloc>().add(UpdatePaymentEvent(
      paymentId: payment.id,
      invoiceSent: inv,
      paymentReceived: rec,
    ));
  }

  Widget _toggleRow(BuildContext context, {required String label, required bool value, required ValueChanged<bool> onChanged, required VoidCallback onReset}) {
    return GestureDetector(
      onLongPress: onReset, // Clean UI: reset via long press
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ZaaturnUI.subBoxColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: ZaaturnUI.textMain)),
            Switch.adaptive(
              value: value,
              activeColor: ZaaturnUI.accentOrange,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: ZaaturnUI.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(message, style: GoogleFonts.inter(color: Colors.brown)),
          TextButton(onPressed: onRetry, child: const Text('Retry', style: TextStyle(color: ZaaturnUI.accentOrange))),
        ],
      ),
    );
  }
}