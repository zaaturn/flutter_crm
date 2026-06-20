import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/analytics_overview_model.dart';
import '../../../theme/analytics_theme.dart';
import '../analytics_kpi_card.dart';
import '../analytics_loading_widgets.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

class OverviewTab extends StatelessWidget {
  final AnalyticsOverviewModel? overview;
  final Future<void> Function()? onRefresh;
  final bool mobile;

  const OverviewTab({
    super.key,
    this.overview,
    this.onRefresh,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final o = overview;
    if (o == null) {
      return const Center(child: Text('No overview data'));
    }

    final asOf = o.asOf != null
        ? DateFormat('dd MMM yyyy').format(
            DateTime.tryParse(o.asOf!) ?? DateTime.now(),
          )
        : null;

    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (asOf != null)
            Text('As of $asOf', style: AnalyticsDesktopTheme.bodySm),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 900 ? 4 : (c.maxWidth > 600 ? 2 : 1);
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.45,
                children: [
                  AnalyticsKpiCard(
                    label: 'Total employees',
                    value: '${o.totalEmployees}',
                    icon: AnalyticsIconType.people,
                  ),
                  AnalyticsKpiCard(
                    label: 'Checked in today',
                    value: '${o.checkedInToday}',
                    icon: AnalyticsIconType.login,
                    accent: AnalyticsDesktopTheme.success,
                  ),
                  AnalyticsKpiCard(
                    label: 'On leave today',
                    value: '${o.onLeaveToday}',
                    icon: AnalyticsIconType.onLeave,
                    accent: AnalyticsDesktopTheme.warning,
                  ),
                  AnalyticsKpiCard(
                    label: 'Pending leaves',
                    value: '${o.pendingLeaveRequests}',
                    icon: AnalyticsIconType.pendingLeave,
                  ),
                  AnalyticsKpiCard(
                    label: 'Tasks pending',
                    value: '${o.pendingTasks}',
                    icon: AnalyticsIconType.tasks,
                  ),
                  AnalyticsKpiCard(
                    label: 'Invoices this month',
                    value: '${o.invoicesIssued}',
                    icon: AnalyticsIconType.receipt,
                  ),
                  AnalyticsKpiCard(
                    label: 'Amount received',
                    value: o.formatReceived(),
                    icon: AnalyticsIconType.payments,
                    accent: AnalyticsDesktopTheme.success,
                  ),
                  AnalyticsKpiCard(
                    label: 'Payroll paid',
                    value: o.formatPayrollPaid(),
                    icon: AnalyticsIconType.wallet,
                    accent: AnalyticsDesktopTheme.purple,
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
