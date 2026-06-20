import 'package:equatable/equatable.dart';



import '../utils/analytics_date_utils.dart';



enum AnalyticsTab {

  overview,

  employeeSummary,

  weeklyAttendance,

  weeklyBusiness,

  monthlyBilling,

  leaves,

}



enum WeeklyAttendanceSubview { daily, weeklySummary }



abstract class AnalyticsEvent extends Equatable {

  const AnalyticsEvent();



  @override

  List<Object?> get props => [];

}



class AnalyticsStarted extends AnalyticsEvent {

  const AnalyticsStarted();

}



class AnalyticsTabChanged extends AnalyticsEvent {

  final AnalyticsTab tab;

  const AnalyticsTabChanged(this.tab);



  @override

  List<Object?> get props => [tab];

}



class AnalyticsWeekChanged extends AnalyticsEvent {

  final int year;

  final int week;

  const AnalyticsWeekChanged({required this.year, required this.week});



  @override

  List<Object?> get props => [year, week];

}



class AnalyticsBillingYearChanged extends AnalyticsEvent {

  final int year;

  const AnalyticsBillingYearChanged(this.year);



  @override

  List<Object?> get props => [year];

}



class AnalyticsRefreshed extends AnalyticsEvent {

  const AnalyticsRefreshed();

}



class AnalyticsSummaryPresetChanged extends AnalyticsEvent {

  final DateRangePreset preset;

  const AnalyticsSummaryPresetChanged(this.preset);



  @override

  List<Object?> get props => [preset];

}



class AnalyticsSummaryRangeApplied extends AnalyticsEvent {

  final DateTime start;

  final DateTime end;

  const AnalyticsSummaryRangeApplied({

    required this.start,

    required this.end,

  });



  @override

  List<Object?> get props => [start, end];

}



class AnalyticsAttendanceDayFilterChanged extends AnalyticsEvent {

  final String dayKey;

  const AnalyticsAttendanceDayFilterChanged(this.dayKey);



  @override

  List<Object?> get props => [dayKey];

}



class AnalyticsAttendanceSubviewChanged extends AnalyticsEvent {

  final WeeklyAttendanceSubview subview;

  const AnalyticsAttendanceSubviewChanged(this.subview);



  @override

  List<Object?> get props => [subview];

}


