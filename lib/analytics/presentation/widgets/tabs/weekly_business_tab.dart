import 'package:flutter/material.dart';

import '../../../models/weekly_business_model.dart';
import '../../../theme/analytics_theme.dart';
import '../../../utils/iso_week.dart';
import '../analytics_kpi_card.dart';
import '../analytics_loading_widgets.dart';

class WeeklyBusinessTab extends StatelessWidget {
  final WeeklyBusinessModel? data;
  final bool mobile;
  final Future<void> Function()? onRefresh;

  const WeeklyBusinessTab({
    super.key,
    this.data,
    this.mobile = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final model = data;
    if (model == null) {
      return const Center(child: Text('No business data'));
    }

    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            IsoWeek.weekPickerLabel(model.year, model.week),
            style: AnalyticsDesktopTheme.titleLg,
          ),
          const SizedBox(height: 4),
          Text(
            'Weekly business metrics',
            style: AnalyticsDesktopTheme.bodySm,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 500 ? 2 : 1);
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.45,
                children: [
                  AnalyticsKpiCard(
                    label: 'New CRM clients',
                    value: '${model.newCrmClients}',
                    icon: Icons.person_add_alt_1_rounded,
                  ),
                  AnalyticsKpiCard(
                    label: 'New billing clients',
                    value: '${model.newBillingClients}',
                    icon: Icons.business_outlined,
                  ),
                  AnalyticsKpiCard(
                    label: 'Clients invoiced',
                    value: '${model.billingClientsInvoiced}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  AnalyticsKpiCard(
                    label: 'Invoices issued',
                    value: '${model.invoicesIssued}',
                    icon: Icons.description_outlined,
                  ),
                  AnalyticsKpiCard(
                    label: 'Invoices paid',
                    value: '${model.invoicesPaid}',
                    icon: Icons.check_circle_outline_rounded,
                    accent: AnalyticsDesktopTheme.success,
                  ),
                  AnalyticsKpiCard(
                    label: 'Invoices pending',
                    value: '${model.invoicesPending}',
                    icon: Icons.pending_outlined,
                    accent: AnalyticsDesktopTheme.warning,
                  ),
                  AnalyticsKpiCard(
                    label: 'Amount invoiced',
                    value: model.formatInvoiced(),
                    icon: Icons.trending_up_rounded,
                  ),
                  AnalyticsKpiCard(
                    label: 'Amount received',
                    value: model.formatReceived(),
                    icon: Icons.payments_outlined,
                    accent: AnalyticsDesktopTheme.success,
                  ),
                  AnalyticsKpiCard(
                    label: 'Amount pending',
                    value: model.formatPending(),
                    icon: Icons.hourglass_empty_rounded,
                    accent: AnalyticsDesktopTheme.danger,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    if (onRefresh == null) return content;
    return AnalyticsRefreshable(
      mobile: mobile,
      onRefresh: onRefresh!,
      child: content,
    );
  }
}
