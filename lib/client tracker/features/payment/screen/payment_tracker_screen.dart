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

  const _MonthBar({
    required this.month,
    required this.year,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => CrmCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Select Period:',
            style: AppTextStyles.bodyMed.copyWith(color: AppColors.textMuted),
          ),

          _StyledDropdown<int>(
            value: month,
            items: List.generate(
                12,
                    (i) => DropdownMenuItem(
                    value: i + 1, child: Text(monthNames[i + 1]))),
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

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(kRadiusSm),
      border: Border.all(color: AppColors.border, width: 1.5),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: AppTextStyles.bodyMed,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted, size: 20),
        dropdownColor: AppColors.surface,
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
    ),
  );
}

class _PaymentTable extends StatelessWidget {
  final List<PaymentModel> payments;
  final int month, year;

  const _PaymentTable({
    required this.payments,
    required this.month,
    required this.year,
  });

  int get _invoiced => payments.where((p) => p.invoiceSent).length;
  int get _paid => payments.where((p) => p.paymentReceived).length;
  int get _pending => payments.where((p) => !p.paymentReceived).length;

  @override
  Widget build(BuildContext context) => CrmCard(
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${monthNames[month]} $year — Payment Status',
                  style: AppTextStyles.subheading,
                ),
              ),
              _SummaryPill('$_invoiced Invoiced', AppColors.accentLight,
                  const Color(0xFF137333)),
              const SizedBox(width: 8),
              _SummaryPill(
                  '$_paid Paid', AppColors.primaryLight, AppColors.primary),
              const SizedBox(width: 8),
              _SummaryPill(
                  '$_pending Pending', AppColors.dangerLight, AppColors.danger),
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
          Padding(
            padding: const EdgeInsets.all(40),
            child: Text('No clients found for this period.',
                style: AppTextStyles.small),
          )
        else
          ...payments.asMap().entries.map((e) =>
              _PaymentRow(payment: e.value, index: e.key + 1)),
      ],
    ),
  );
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final Color bg, fg;

  const _SummaryPill(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: AppTextStyles.small.copyWith(
            color: fg, fontWeight: FontWeight.w700, fontSize: 11.5)),
  );
}

class _PaymentRow extends StatefulWidget {
  final PaymentModel payment;
  final int index;

  const _PaymentRow({required this.payment, required this.index});

  @override
  State<_PaymentRow> createState() => _PaymentRowState();
}

class _PaymentRowState extends State<_PaymentRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.bg : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${widget.index < 10 ? '0' : ''}${widget.index}',
                style: AppTextStyles.small.copyWith(fontFamily: 'DM Mono'),
              ),
            ),

            Expanded(
              flex: 3,
              child: Row(
                children: [
                  ClientAvatar(
                    name: p.clientName,
                    size: 32,
                    gradient: ClientAvatar.gradientFor(p.clientName),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      p.clientName,
                      style: AppTextStyles.bodyMed,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: StatusPillDropdown(
                value: p.invoiceSent,
                onChanged: (v) {
                  context.read<PaymentBloc>().add(UpdatePaymentEvent(
                    paymentId: p.id,
                    invoiceSent: v,
                    paymentReceived: p.paymentReceived,
                  ));
                },
              ),
            ),

            Expanded(
              flex: 2,
              child: StatusPillDropdown(
                value: p.paymentReceived,
                onChanged: (v) {
                  context.read<PaymentBloc>().add(UpdatePaymentEvent(
                    paymentId: p.id,
                    invoiceSent: p.invoiceSent,
                    paymentReceived: v,
                  ));
                },
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                '${monthNames[p.month]} ${p.year}',
                style: AppTextStyles.mono.copyWith(
                    fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;

  const _ErrorBox({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(msg, style: AppTextStyles.body.copyWith(color: AppColors.danger)),
        const SizedBox(height: 12),
        CrmButton('Retry', onTap: onRetry),
      ],
    ),
  );
}