import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event_state.dart';
import '../model/payment_model.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';

class PaymentTrackerScreen extends StatefulWidget {
  const PaymentTrackerScreen({super.key});

  @override
  State<PaymentTrackerScreen> createState() => _PaymentTrackerScreenState();
}

class _PaymentTrackerScreenState extends State<PaymentTrackerScreen> {
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _load();
  }

  void _load() => context.read<PaymentBloc>().add(LoadPaymentsEvent(_month, _year));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MonthBar(
            month: _month,
            year: _year,
            onChanged: (m, y) {
              setState(() {
                _month = m;
                _year = y;
              });
              _load();
            },
          ),
          const SizedBox(height: 20),
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (ctx, state) {
              if (state is PaymentLoading) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator()));
              }
              if (state is PaymentError) {
                return _ErrorBox(msg: state.message, onRetry: _load);
              }
              if (state is PaymentLoaded) {
                return _PaymentTable(
                    payments: state.payments, month: _month, year: _year);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  final int month, year;
  final Function(int, int) onChanged;

  const _MonthBar({required this.month, required this.year, required this.onChanged});

  @override
  Widget build(BuildContext context) => CrmCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Select Period:',
              style: AppTextStyles.bodyMed.copyWith(color: AppColors.textMuted)),
          _StyledDropdown<int>(
            value: month,
            items: List.generate(12, (i) {
              final mIndex = i + 1;
              return DropdownMenuItem(
                value: mIndex,
                child: Text(monthNames[mIndex] ?? ''),
              );
            }),
            onChanged: (v) => v != null ? onChanged(v, year) : null,
          ),
          _StyledDropdown<int>(
            value: year,
            items: List.generate(5, (i) {
              final y = DateTime.now().year - 2 + i;
              return DropdownMenuItem(value: y, child: Text('$y'));
            }),
            onChanged: (v) => v != null ? onChanged(month, v) : null,
          ),
        ],
      ),
    ),
  );
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F4F9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border, width: 1.5),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: AppTextStyles.bodyMed,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 20),
        dropdownColor: AppColors.surface,
      ),
    ),
  );
}

class _PaymentTable extends StatelessWidget {
  final List<PaymentModel> payments;
  final int month, year;

  const _PaymentTable({required this.payments, required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    final invoiced = payments.where((p) => p.invoiceSent == true).length;
    final paid = payments.where((p) => p.paymentReceived == true).length;
    
    // 💡 We only count as pending if specifically set to false and modified
    final pending = payments.where((p) => p.paymentReceived == false).length;

    return CrmCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                Expanded(
                  child: Text('${monthNames[month]} $year — Payment Status', style: AppTextStyles.subheading),
                ),
                _SummaryPill('$invoiced Invoiced', const Color(0xFFE8F5E9), const Color(0xFF137333)),
                const SizedBox(width: 8),
                _SummaryPill('$paid Paid', const Color(0xFFE3F2FD), const Color(0xFF1976D2)),
                const SizedBox(width: 8),
                _SummaryPill('$pending Pending', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
              ],
            ),
          ),
          Container(
            color: AppColors.tableHead,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 32),
                Expanded(flex: 3, child: Text('# CLIENT NAME', style: AppTextStyles.tableHdr)),
                Expanded(flex: 2, child: Text('INVOICE SENT', style: AppTextStyles.tableHdr)),
                Expanded(flex: 2, child: Text('PAYMENT RECEIVED', style: AppTextStyles.tableHdr)),
                Expanded(flex: 2, child: Text('LAST UPDATED', style: AppTextStyles.tableHdr)),
              ],
            ),
          ),
          if (payments.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Text('No clients found for this period.'))
          else
            ...payments.asMap().entries.map((e) => _PaymentRow(payment: e.value, key: ValueKey('${e.value.id}_${e.value.invoiceSent}_${e.value.paymentReceived}'), index: e.key + 1)),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatefulWidget {
  final PaymentModel payment;
  final int index;

  const _PaymentRow({required this.payment, required this.index, super.key});

  @override
  State<_PaymentRow> createState() => _PaymentRowState();
}

class _PaymentRowState extends State<_PaymentRow> {
  bool? invoiceValue;
  bool? paymentValue;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  void _initValues() {
    // 💡 FORCE "Select" as default if value is null OR false (on first load)
    // We only show true if it's explicitly true.
    invoiceValue = widget.payment.invoiceSent == true ? true : (widget.payment.invoiceSent == false ? false : null);
    paymentValue = widget.payment.paymentReceived == true ? true : (widget.payment.paymentReceived == false ? false : null);
  }

  @override
  void didUpdateWidget(_PaymentRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payment.invoiceSent != widget.payment.invoiceSent || 
        oldWidget.payment.paymentReceived != widget.payment.paymentReceived) {
      setState(() {
        invoiceValue = widget.payment.invoiceSent;
        paymentValue = widget.payment.paymentReceived;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final index = widget.index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${index < 10 ? '0' : ''}$index',
              style: AppTextStyles.small.copyWith(fontFamily: 'DM Mono', color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Text(
                    payment.clientName.isNotEmpty ? payment.clientName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(payment.clientName, style: AppTextStyles.bodyMed, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: StatusPillDropdown(
                value: invoiceValue,
                isInvoice: true,
                onChanged: (v) {
                  setState(() => invoiceValue = v);
                  context.read<PaymentBloc>().add(UpdatePaymentEvent(
                        paymentId: payment.id,
                        invoiceSent: v,
                        paymentReceived: paymentValue,
                      ));
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: StatusPillDropdown(
                value: paymentValue,
                isInvoice: false,
                onChanged: (v) {
                  setState(() => paymentValue = v);
                  context.read<PaymentBloc>().add(UpdatePaymentEvent(
                        paymentId: payment.id,
                        invoiceSent: invoiceValue,
                        paymentReceived: v,
                      ));
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${monthNames[payment.updatedAt.month]} ${payment.updatedAt.day} ${payment.updatedAt.year}',
              style: AppTextStyles.mono.copyWith(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPillDropdown extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  final bool isInvoice;

  const StatusPillDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isInvoice,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Colors for 3 states
    final Color bgColor = value == null
        ? const Color(0xFFF5F5F5) 
        : (value! ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0));

    final Color textColor = value == null
        ? Colors.grey.shade600
        : (value! ? const Color(0xFF2E7D32) : const Color(0xFFE65100));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 34,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: value == null ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor, size: 18),
          selectedItemBuilder: (context) {
            return [null, true, false].map((e) {
              final String text = e == null ? "Select" : (e ? (isInvoice ? "Sent" : "Received") : "Pending");
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(text,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
              );
            }).toList();
          },
          items: [
            const DropdownMenuItem<bool?>(value: null, child: Text("Select")),
            DropdownMenuItem<bool?>(value: true, child: Text(isInvoice ? "Sent" : "Received")),
            const DropdownMenuItem<bool?>(value: false, child: Text("Pending")),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final Color bg, text;
  const _SummaryPill(this.label, this.bg, this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: AppTextStyles.small.copyWith(color: text, fontWeight: FontWeight.bold)),
  );
}

class _ErrorBox extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorBox({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        Text(msg, style: const TextStyle(color: Colors.red)),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
