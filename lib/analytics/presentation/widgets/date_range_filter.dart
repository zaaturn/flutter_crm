import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/analytics_bloc.dart';
import '../../bloc/analytics_event.dart';
import '../../theme/analytics_theme.dart';
import '../../utils/analytics_date_utils.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

class DateRangeFilter extends StatelessWidget {
  final DateRangePreset preset;
  final DateTime start;
  final DateTime end;
  final bool mobile;

  const DateRangeFilter({
    super.key,
    required this.preset,
    required this.start,
    required this.end,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final purple = mobile ? AnalyticsMobileTheme.terracotta : AnalyticsDesktopTheme.purple;
    final surface = mobile ? AnalyticsMobileTheme.card : AnalyticsDesktopTheme.surface;
    final muted = mobile ? AnalyticsMobileTheme.textMuted : AnalyticsDesktopTheme.textMuted;

    return Container(
      margin: mobile ? const EdgeInsets.symmetric(horizontal: 16, vertical: 6) : null,
      padding: EdgeInsets.fromLTRB(mobile ? 14 : 24, mobile ? 10 : 12, mobile ? 14 : 24, 12),
      color: mobile ? null : AnalyticsDesktopTheme.surface,
      decoration: mobile
          ? BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14))
          : null,
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownButton<DateRangePreset>(
            value: preset,
            underline: const SizedBox.shrink(),
            items: DateRangePreset.values
                .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                .toList(),
            onChanged: (p) {
              if (p != null) {
                context.read<AnalyticsBloc>().add(AnalyticsSummaryPresetChanged(p));
              }
            },
          ),
          OutlinedButton(
            onPressed: () => _pickDate(context, isStart: true),
            style: OutlinedButton.styleFrom(foregroundColor: purple),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnalyticsIcon(type: AnalyticsIconType.calendar, size: 16, color: purple),
                const SizedBox(width: 8),
                Text(fmt.format(start)),
              ],
            ),
          ),
          const Text('to'),
          OutlinedButton(
            onPressed: () => _pickDate(context, isStart: false),
            style: OutlinedButton.styleFrom(foregroundColor: purple),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnalyticsIcon(type: AnalyticsIconType.calendar, size: 16, color: purple),
                const SizedBox(width: 8),
                Text(fmt.format(end)),
              ],
            ),
          ),
          if (preset == DateRangePreset.custom)
            FilledButton(
              onPressed: () {
                context.read<AnalyticsBloc>().add(
                      AnalyticsSummaryRangeApplied(start: start, end: end),
                    );
              },
              style: FilledButton.styleFrom(backgroundColor: purple),
              child: const Text('Apply'),
            ),
          Text(
            '${AnalyticsDateUtils.toApiDate(start)} → ${AnalyticsDateUtils.toApiDate(end)}',
            style: GoogleFonts.inter(fontSize: 12, color: muted),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final initial = isStart ? start : end;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !context.mounted) return;

    final bloc = context.read<AnalyticsBloc>();
    final state = bloc.state;
    if (isStart) {
      final endDate = picked.isAfter(state.summaryEnd) ? picked : state.summaryEnd;
      bloc.add(AnalyticsSummaryRangeApplied(start: picked, end: endDate));
    } else {
      final startDate =
          picked.isBefore(state.summaryStart) ? picked : state.summaryStart;
      bloc.add(AnalyticsSummaryRangeApplied(start: startDate, end: picked));
    }
  }
}
