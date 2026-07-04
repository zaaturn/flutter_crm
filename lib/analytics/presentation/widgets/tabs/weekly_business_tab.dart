import 'package:flutter/material.dart';

import '../../../models/weekly_business_model.dart';
import '../../../theme/analytics_theme.dart';
import '../../../utils/iso_week.dart';
import '../analytics_compact_stat_card.dart';
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

    final tiles = <({String label, String value, Color color})>[
      (
        label: 'New CRM clients',
        value: '${model.newCrmClients}',
        color: AnalyticsOverviewPalette.mutedTeal,
      ),
      (
        label: 'New billing clients',
        value: '${model.newBillingClients}',
        color: AnalyticsOverviewPalette.slateBlue,
      ),
      (
        label: 'Clients invoiced',
        value: '${model.billingClientsInvoiced}',
        color: AnalyticsOverviewPalette.softMauve,
      ),
      (
        label: 'Invoices issued',
        value: '${model.invoicesIssued}',
        color: AnalyticsOverviewPalette.warmBeige,
      ),
      (
        label: 'Invoices paid',
        value: '${model.invoicesPaid}',
        color: AnalyticsOverviewPalette.sageGreen,
      ),
      (
        label: 'Invoices pending',
        value: '${model.invoicesPending}',
        color: AnalyticsOverviewPalette.mustard,
      ),
      (
        label: 'Amount invoiced',
        value: model.formatInvoiced(),
        color: AnalyticsOverviewPalette.berry,
      ),
      (
        label: 'Amount received',
        value: model.formatReceived(),
        color: AnalyticsOverviewPalette.terracotta,
      ),
      (
        label: 'Amount pending',
        value: model.formatPending(),
        color: AnalyticsOverviewPalette.charcoal,
      ),
    ];

    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(mobile ? 14 : 20),
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
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, c) {
              final cols = mobile ? 2 : (c.maxWidth > 900 ? 3 : 2);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: mobile ? 86 : 92,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  return AnalyticsCompactStatCard(
                    label: tile.label,
                    value: tile.value,
                    background: tile.color,
                  );
                },
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
