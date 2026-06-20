import 'package:flutter/material.dart';

import '../../../models/monthly_billing_model.dart';
import '../../../theme/analytics_theme.dart';
import '../../../utils/analytics_money.dart';
import '../analytics_enterprise_table.dart';
import '../analytics_loading_widgets.dart';

class MonthlyBillingTab extends StatelessWidget {
  final MonthlyBillingModel? data;
  final bool mobile;
  final Future<void> Function()? onRefresh;

  const MonthlyBillingTab({
    super.key,
    this.data,
    this.mobile = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final model = data;
    if (model == null) {
      return const Center(child: Text('No billing data'));
    }

    final monthRows = model.months.map(_monthRow).toList();
    final pinned = [_totalsRow(model.totals)];

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(mobile ? 16 : 20, mobile ? 12 : 16, mobile ? 16 : 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Year ${model.year}', style: AnalyticsDesktopTheme.titleLg),
              const SizedBox(height: 4),
              Text(
                '${model.months.length} months',
                style: AnalyticsDesktopTheme.bodySm,
              ),
            ],
          ),
        ),
        Expanded(
          child: model.months.isEmpty
              ? const Center(child: Text('No monthly billing data'))
              : SizedBox.expand(
                  child: AnalyticsEnterpriseTable(
                    mobile: mobile,
                    pageSize: 12,
                    columnFlex: billingColumnFlex,
                    columns: const [
                      'Month',
                      'Issued',
                      'Paid',
                      'Invoiced',
                      'Received',
                      'Pending',
                    ],
                    rows: monthRows,
                    pinnedRows: pinned,
                  ),
                ),
        ),
      ],
    );

    if (onRefresh == null || !mobile) return body;
    return AnalyticsRefreshable(
      mobile: mobile,
      onRefresh: onRefresh!,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(child: body)],
      ),
    );
  }

  AnalyticsTableRow _monthRow(MonthlyBillingMonth m) {
    return AnalyticsTableRow([
      Text(
        m.monthLabel.isNotEmpty ? m.monthLabel : 'Month ${m.month}',
        style: AnalyticsDesktopTheme.tableCellBold,
      ),
      Text('${m.invoicesIssued}', style: AnalyticsDesktopTheme.tableCellStyle),
      Text('${m.invoicesPaid}', style: AnalyticsDesktopTheme.tableCellStyle),
      Text(
        AnalyticsMoney.format(m.amountInvoiced),
        style: AnalyticsDesktopTheme.tableCellStyle,
      ),
      Text(
        AnalyticsMoney.format(m.amountReceived),
        style: AnalyticsDesktopTheme.tableCellStyle,
      ),
      Text(
        AnalyticsMoney.format(m.amountPending),
        style: AnalyticsDesktopTheme.tableCellStyle,
      ),
    ]);
  }

  AnalyticsTableRow _totalsRow(MonthlyBillingTotals t) {
    return AnalyticsTableRow(
      [
        Text('Year total', style: AnalyticsDesktopTheme.tableCellBold),
        Text('${t.invoicesIssued}', style: AnalyticsDesktopTheme.tableCellBold),
        Text('${t.invoicesPaid}', style: AnalyticsDesktopTheme.tableCellBold),
        Text(
          AnalyticsMoney.format(t.amountInvoiced),
          style: AnalyticsDesktopTheme.tableCellBold,
        ),
        Text(
          AnalyticsMoney.format(t.amountReceived),
          style: AnalyticsDesktopTheme.tableCellBold,
        ),
        Text(
          AnalyticsMoney.format(t.amountPending),
          style: AnalyticsDesktopTheme.tableCellBold,
        ),
      ],
      highlight: true,
    );
  }
}
