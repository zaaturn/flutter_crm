import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';



import '../../../bloc/analytics_bloc.dart';

import '../../../bloc/analytics_event.dart';

import '../../../bloc/analytics_state.dart';

import '../../../theme/analytics_theme.dart';

import '../../../utils/analytics_date_utils.dart';
import '../../../utils/iso_week.dart';

import '../../widgets/analytics_forbidden_view.dart';

import '../../widgets/analytics_tab_body.dart';
import '../../widgets/attendance_day_filter.dart';
import '../../widgets/week_picker.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

class AnalyticsMobileScreen extends StatelessWidget {
  const AnalyticsMobileScreen({super.key});



  @override

  Widget build(BuildContext context) {

    return Theme(

      data: Theme.of(context).copyWith(

        scaffoldBackgroundColor: AnalyticsMobileTheme.background,

        textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),

      ),

      child: Scaffold(

        backgroundColor: AnalyticsMobileTheme.background,

        body: SafeArea(

          child: BlocConsumer<AnalyticsBloc, AnalyticsState>(

            listenWhen: (p, c) =>

                p.errorMessage != c.errorMessage && c.errorMessage != null,

            listener: (context, state) {

              if (state.isForbidden) return;

              final msg = state.errorMessage;

              if (msg != null && msg.isNotEmpty) {

                ScaffoldMessenger.of(context).showSnackBar(

                  SnackBar(

                    backgroundColor: AnalyticsMobileTheme.terracotta,

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



              return Column(

                children: [

                  _MobileHeader(

                    onBack: () => Navigator.of(context).maybePop(),

                    onRefresh: () => context

                        .read<AnalyticsBloc>()

                        .add(const AnalyticsRefreshed()),

                  ),

                  _MobileTabStrip(tab: state.tab),

                  if (state.tab == AnalyticsTab.weeklyAttendance ||

                      state.tab == AnalyticsTab.weeklyBusiness)

                    WeekPickerBar(

                      year: state.year,

                      week: state.week,

                      mobile: true,

                      onYearChanged: (y) => _setWeek(context, y, state.week),

                      onWeekChanged: (w) => _setWeek(context, state.year, w),

                      onPrevious: () => _shiftWeek(context, -1),

                      onNext: () => _shiftWeek(context, 1),

                    ),

                  if (state.tab == AnalyticsTab.weeklyAttendance) ...[

                    _MobileSubviewToggle(subview: state.attendanceSubview),

                    if (state.attendanceSubview == WeeklyAttendanceSubview.daily)

                      AttendanceDayFilter(

                        year: state.year,

                        week: state.week,

                        selectedDayKey: state.attendanceDayFilter ??

                            AnalyticsDateUtils.defaultDayKeyForIsoWeek(

                              state.year,

                              state.week,

                            ),

                        mobile: true,

                        onChanged: (key) => context.read<AnalyticsBloc>().add(

                              AnalyticsAttendanceDayFilterChanged(key),

                            ),

                      ),

                  ],

                  if (state.tab == AnalyticsTab.monthlyBilling)

                    _MobileYearPicker(

                      year: state.billingYear,

                      onChanged: (y) => context

                          .read<AnalyticsBloc>()

                          .add(AnalyticsBillingYearChanged(y)),

                    ),

                  Expanded(
                    child: AnalyticsTabBody(state: state, mobile: true),
                  ),

                ],

              );

            },

          ),

        ),

      ),

    );

  }



  void _setWeek(BuildContext context, int year, int week) {

    final clamped = week.clamp(1, IsoWeek.weeksInYear(year));

    context.read<AnalyticsBloc>().add(

          AnalyticsWeekChanged(year: year, week: clamped),

        );

  }



  void _shiftWeek(BuildContext context, int delta) {

    final state = context.read<AnalyticsBloc>().state;

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

class _MobileHeader extends StatelessWidget {

  final VoidCallback onBack;

  final VoidCallback onRefresh;



  const _MobileHeader({required this.onBack, required this.onRefresh});



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),

      child: Row(

        children: [

          IconButton(

            onPressed: onBack,

            icon: const AnalyticsIcon(
                type: AnalyticsIconType.arrowBack,
                color: AnalyticsMobileTheme.textDark,
                size: 20),

          ),

          Text(

            'Analytics',

            style: GoogleFonts.manrope(

              fontSize: 22,

              fontWeight: FontWeight.w900,

              color: AnalyticsMobileTheme.textDark,

            ),

          ),

          const Spacer(),

          IconButton(

            onPressed: onRefresh,

            icon: const AnalyticsIcon(
                type: AnalyticsIconType.refresh,
                color: AnalyticsMobileTheme.terracotta),

          ),

        ],

      ),

    );

  }

}



class _MobileTabStrip extends StatelessWidget {

  final AnalyticsTab tab;



  const _MobileTabStrip({required this.tab});



  @override

  Widget build(BuildContext context) {

    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: Row(

        children: [

          _chip(context, AnalyticsTab.overview, 'Overview'),
          _chip(context, AnalyticsTab.weeklyAttendance, 'Attendance'),

          _chip(context, AnalyticsTab.weeklyBusiness, 'Business'),

          _chip(context, AnalyticsTab.leaves, 'Leaves'),

          _chip(context, AnalyticsTab.monthlyBilling, 'Billing'),

        ],

      ),

    );

  }



  Widget _chip(BuildContext context, AnalyticsTab t, String label) {

    final selected = tab == t;

    return Padding(

      padding: const EdgeInsets.only(right: 8),

      child: FilterChip(

        label: Text(label),

        selected: selected,

        showCheckmark: true,

        selectedColor: AnalyticsMobileTheme.terracotta,

        backgroundColor: AnalyticsMobileTheme.card,

        checkmarkColor: Colors.white,

        labelStyle: GoogleFonts.manrope(

          fontWeight: FontWeight.w800,

          color: selected ? Colors.white : AnalyticsMobileTheme.textDark,

          fontSize: 12,

        ),

        onSelected: (selected) {

          if (!selected) return;

          context.read<AnalyticsBloc>().add(AnalyticsTabChanged(t));

        },

      ),

    );

  }

}



class _MobileSubviewToggle extends StatelessWidget {

  final WeeklyAttendanceSubview subview;



  const _MobileSubviewToggle({required this.subview});



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      child: SegmentedButton<WeeklyAttendanceSubview>(

        style: ButtonStyle(

          foregroundColor: WidgetStateProperty.resolveWith(

            (s) => s.contains(WidgetState.selected)

                ? Colors.white

                : AnalyticsMobileTheme.textDark,

          ),

          backgroundColor: WidgetStateProperty.resolveWith(

            (s) => s.contains(WidgetState.selected)

                ? AnalyticsMobileTheme.terracotta

                : AnalyticsMobileTheme.card,

          ),

        ),

        segments: const [

          ButtonSegment(

            value: WeeklyAttendanceSubview.daily,

            label: Text('Daily'),

          ),

          ButtonSegment(

            value: WeeklyAttendanceSubview.weeklySummary,

            label: Text('Summary'),

          ),

        ],

        selected: {subview},

        onSelectionChanged: (s) {

          context.read<AnalyticsBloc>().add(

                AnalyticsAttendanceSubviewChanged(s.first),

              );

        },

      ),

    );

  }

}



class _MobileYearPicker extends StatelessWidget {

  final int year;

  final ValueChanged<int> onChanged;



  const _MobileYearPicker({required this.year, required this.onChanged});



  @override

  Widget build(BuildContext context) {

    final years = List.generate(5, (i) => DateTime.now().year - 2 + i);

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(

        color: AnalyticsMobileTheme.card,

        borderRadius: BorderRadius.circular(14),

      ),

      child: Row(

        children: [

          Text(

            'Year',

            style: GoogleFonts.manrope(

              fontWeight: FontWeight.w800,

              color: AnalyticsMobileTheme.textMuted,

            ),

          ),

          const SizedBox(width: 12),

          DropdownButton<int>(

            value: year,

            underline: const SizedBox.shrink(),

            items: years

                .map((y) => DropdownMenuItem(value: y, child: Text('$y')))

                .toList(),

            onChanged: (v) {

              if (v != null) onChanged(v);

            },

          ),

        ],

      ),

    );

  }

}


