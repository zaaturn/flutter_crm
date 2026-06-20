import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/analytics_bloc.dart';
import '../../bloc/analytics_event.dart';
import '../../bloc/analytics_state.dart';
import '../../theme/analytics_theme.dart';
import '../../utils/iso_week.dart';
import 'mobile/analytics_mobile_screen.dart';
import '../widgets/analytics_attendance_toolbar.dart';
import '../widgets/analytics_forbidden_view.dart';
import '../widgets/analytics_sidebar.dart';
import '../widgets/analytics_tab_body.dart';
import '../widgets/week_picker.dart';

class AnalyticsAdminScreen extends StatelessWidget {
  const AnalyticsAdminScreen({super.key});

  static const double _wideBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _wideBreakpoint) {
          return const AnalyticsMobileScreen();
        }
        return const _AnalyticsDesktopShell();
      },
    );
  }
}

class _AnalyticsDesktopShell extends StatelessWidget {
  const _AnalyticsDesktopShell();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AnalyticsDesktopTheme.scaffoldBg,
        colorScheme: ColorScheme.light(
          primary: AnalyticsDesktopTheme.purple,
          onPrimary: Colors.white,
          primaryContainer: AnalyticsDesktopTheme.purpleLight,
          onPrimaryContainer: AnalyticsDesktopTheme.purpleDark,
          surface: AnalyticsDesktopTheme.surface,
          onSurface: AnalyticsDesktopTheme.textMain,
        ),
      ),
      child: Scaffold(
        backgroundColor: AnalyticsDesktopTheme.scaffoldBg,
        body: BlocConsumer<AnalyticsBloc, AnalyticsState>(
          listenWhen: (p, c) =>
              p.errorMessage != c.errorMessage && c.errorMessage != null,
          listener: (context, state) {
            if (state.isForbidden) return;
            final msg = state.errorMessage;
            if (msg != null && msg.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(msg),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isForbidden) {
              return AnalyticsForbiddenView(
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnalyticsSidebar(
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AnalyticsDesktopTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AnalyticsDesktopTheme.cardRadius),
                        border: Border.all(color: AnalyticsDesktopTheme.border),
                        boxShadow: AnalyticsDesktopTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.tab == AnalyticsTab.weeklyAttendance)
                            AnalyticsAttendanceToolbar(state: state),
                          if (state.tab == AnalyticsTab.weeklyBusiness)
                            _BusinessWeekBar(state: state),
                          if (state.tab == AnalyticsTab.monthlyBilling)
                            _BillingYearBar(year: state.billingYear),
                          Expanded(child: AnalyticsTabBody(state: state)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BusinessWeekBar extends StatelessWidget {
  final AnalyticsState state;
  const _BusinessWeekBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WeekPickerBar(
          year: state.year,
          week: state.week,
          embedded: true,
          onYearChanged: (y) => _setWeek(context, y, state.week),
          onWeekChanged: (w) => _setWeek(context, state.year, w),
          onPrevious: () => _shift(context, -1),
          onNext: () => _shift(context, 1),
        ),
        const Divider(height: 1, color: AnalyticsDesktopTheme.border),
      ],
    );
  }

  void _setWeek(BuildContext context, int year, int week) {
    context.read<AnalyticsBloc>().add(
          AnalyticsWeekChanged(
            year: year,
            week: week.clamp(1, IsoWeek.weeksInYear(year)),
          ),
        );
  }

  void _shift(BuildContext context, int delta) {
    var week = state.week + delta;
    var year = state.year;
    if (week < 1) {
      year -= 1;
      week = IsoWeek.weeksInYear(year);
    } else if (week > IsoWeek.weeksInYear(year)) {
      year += 1;
      week = 1;
    }
    context.read<AnalyticsBloc>().add(
          AnalyticsWeekChanged(year: year, week: week),
        );
  }
}

class _BillingYearBar extends StatelessWidget {
  final int year;
  const _BillingYearBar({required this.year});

  @override
  Widget build(BuildContext context) {
    final years = List.generate(5, (i) => DateTime.now().year - 2 + i);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            children: [
              Text('Billing year', style: AnalyticsDesktopTheme.titleMd),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AnalyticsDesktopTheme.border),
                  borderRadius:
                      BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
                ),
                child: DropdownButton<int>(
                  value: year,
                  underline: const SizedBox.shrink(),
                  items: years
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      context
                          .read<AnalyticsBloc>()
                          .add(AnalyticsBillingYearChanged(v));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AnalyticsDesktopTheme.border),
      ],
    );
  }
}
