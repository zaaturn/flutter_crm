import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/admin_dashboard/repository/admin_repository.dart';

import '../repository/analytics_repository.dart';

import '../utils/analytics_date_utils.dart';

import '../utils/analytics_exceptions.dart';

import 'analytics_event.dart';

import 'analytics_state.dart';



class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {

  AnalyticsBloc({required AnalyticsRepository repository})

      : _repository = repository,

        super(AnalyticsState.initial()) {

    on<AnalyticsStarted>(_onStarted);

    on<AnalyticsTabChanged>(_onTabChanged);

    on<AnalyticsWeekChanged>(_onWeekChanged);

    on<AnalyticsBillingYearChanged>(_onBillingYearChanged);

    on<AnalyticsRefreshed>(_onRefreshed);

    on<AnalyticsSummaryPresetChanged>(_onSummaryPresetChanged);

    on<AnalyticsSummaryRangeApplied>(_onSummaryRangeApplied);

    on<AnalyticsAttendanceDayFilterChanged>(_onAttendanceDayFilterChanged);

    on<AnalyticsAttendanceSubviewChanged>(_onAttendanceSubviewChanged);

  }



  final AnalyticsRepository _repository;
  final AdminRepository _adminRepository = AdminRepository();



  Future<void> _onStarted(

    AnalyticsStarted event,

    Emitter<AnalyticsState> emit,

  ) async {

    await _loadTab(emit, state.tab, force: true);

  }



  Future<void> _onTabChanged(

    AnalyticsTabChanged event,

    Emitter<AnalyticsState> emit,

  ) async {

    if (event.tab == state.tab) return;

    final dayFilter = event.tab == AnalyticsTab.weeklyAttendance

        ? (state.attendanceDayFilter ??

            AnalyticsDateUtils.defaultDayKeyForIsoWeek(state.year, state.week))

        : state.attendanceDayFilter;

    emit(state.copyWith(

      tab: event.tab,

      attendanceDayFilter: dayFilter,

      clearError: true,

    ));

    await _loadTab(emit, event.tab);

  }



  Future<void> _onWeekChanged(

    AnalyticsWeekChanged event,

    Emitter<AnalyticsState> emit,

  ) async {

    emit(

      state.copyWith(

        year: event.year,

        week: event.week,

        clearError: true,

        clearAttendance: true,

        clearBusiness: true,

        attendanceDayFilter:

            AnalyticsDateUtils.defaultDayKeyForIsoWeek(event.year, event.week),

      ),

    );

    if (state.tab == AnalyticsTab.weeklyAttendance) {

      await _loadAttendance(emit, force: true);

    } else if (state.tab == AnalyticsTab.weeklyBusiness) {

      await _loadBusiness(emit, force: true);

    }

  }



  Future<void> _onBillingYearChanged(

    AnalyticsBillingYearChanged event,

    Emitter<AnalyticsState> emit,

  ) async {

    emit(

      state.copyWith(

        billingYear: event.year,

        clearError: true,

        clearBilling: true,

      ),

    );

    if (state.tab == AnalyticsTab.monthlyBilling) {

      await _loadBilling(emit, force: true);

    }

  }



  Future<void> _onRefreshed(

    AnalyticsRefreshed event,

    Emitter<AnalyticsState> emit,

  ) async {

    await _loadTab(emit, state.tab, force: true);

  }



  Future<void> _onSummaryPresetChanged(

    AnalyticsSummaryPresetChanged event,

    Emitter<AnalyticsState> emit,

  ) async {

    if (event.preset == DateRangePreset.custom) {

      emit(state.copyWith(summaryPreset: event.preset, clearError: true));

      return;

    }

    final range = event.preset.range;

    emit(

      state.copyWith(

        summaryPreset: event.preset,

        summaryStart: range.start,

        summaryEnd: range.end,

        clearError: true,

        clearSummary: true,

      ),

    );

    if (state.tab == AnalyticsTab.employeeSummary) {

      await _loadEmployeeSummary(emit, force: true);

    }

  }



  Future<void> _onSummaryRangeApplied(

    AnalyticsSummaryRangeApplied event,

    Emitter<AnalyticsState> emit,

  ) async {

    emit(

      state.copyWith(

        summaryPreset: DateRangePreset.custom,

        summaryStart: event.start,

        summaryEnd: event.end,

        clearError: true,

        clearSummary: true,

      ),

    );

    if (state.tab == AnalyticsTab.employeeSummary) {

      await _loadEmployeeSummary(emit, force: true);

    }

  }



  void _onAttendanceDayFilterChanged(

    AnalyticsAttendanceDayFilterChanged event,

    Emitter<AnalyticsState> emit,

  ) {

    emit(

      state.copyWith(

        attendanceDayFilter: event.dayKey,

        clearError: true,

      ),

    );

  }



  void _onAttendanceSubviewChanged(

    AnalyticsAttendanceSubviewChanged event,

    Emitter<AnalyticsState> emit,

  ) {

    emit(

      state.copyWith(

        attendanceSubview: event.subview,

        attendanceDayFilter: event.subview == WeeklyAttendanceSubview.daily

            ? (state.attendanceDayFilter ??

                AnalyticsDateUtils.defaultDayKeyForIsoWeek(

                  state.year,

                  state.week,

                ))

            : state.attendanceDayFilter,

        clearError: true,

      ),

    );

  }



  Future<void> _loadTab(

    Emitter<AnalyticsState> emit,

    AnalyticsTab tab, {

    bool force = false,

  }) async {

    switch (tab) {

      case AnalyticsTab.overview:

        await _loadOverview(emit, force: force);

      case AnalyticsTab.employeeSummary:

        await _loadEmployeeSummary(emit, force: force);

      case AnalyticsTab.weeklyAttendance:

        await _loadAttendance(emit, force: force);

      case AnalyticsTab.weeklyBusiness:

        await _loadBusiness(emit, force: force);

      case AnalyticsTab.monthlyBilling:

        await _loadBilling(emit, force: force);

      case AnalyticsTab.leaves:

        await _loadLeaves(emit, force: force);

    }

  }



  Future<void> _loadOverview(

    Emitter<AnalyticsState> emit, {

    bool force = false,

  }) async {

    if (!force && state.overview != null) return;

    emit(state.copyWith(overviewLoading: true, clearError: true));

    try {

      final overview = await _repository.loadOverview();

      emit(

        state.copyWith(

          overviewLoading: false,

          overview: overview,

        ),

      );

      // Overview panel also surfaces who's on leave today, this week's
      // attendance, and overdue tasks — all pulled from their own modules
      // so this stays supplementary and never blocks the core KPI load.
      await _loadLeaves(emit, force: force);

      await _loadAttendance(emit, force: force);

      await _loadOverdueTasks(emit, force: force);

    } on AnalyticsApiException catch (e) {

      emit(

        state.copyWith(

          overviewLoading: false,

          errorMessage: e.message,

          errorKind: e.kind,

        ),

      );

    } catch (e) {

      emit(

        state.copyWith(

          overviewLoading: false,

          errorMessage: e.toString(),

          errorKind: AnalyticsErrorKind.unknown,

        ),

      );

    }

  }



  Future<void> _loadEmployeeSummary(

    Emitter<AnalyticsState> emit, {

    bool force = false,

  }) async {

    final startKey = AnalyticsDateUtils.toApiDate(state.summaryStart);

    final endKey = AnalyticsDateUtils.toApiDate(state.summaryEnd);

    if (!force &&

        state.attendanceSummary != null &&

        state.attendanceSummary!.start == startKey &&

        state.attendanceSummary!.end == endKey) {

      return;

    }

    emit(state.copyWith(summaryLoading: true, clearError: true));

    try {

      final data = await _repository.loadAttendanceSummary(

        start: startKey,

        end: endKey,

      );

      emit(state.copyWith(summaryLoading: false, attendanceSummary: data));

    } on AnalyticsApiException catch (e) {

      emit(

        state.copyWith(

          summaryLoading: false,

          errorMessage: e.message,

          errorKind: e.kind,

        ),

      );

    } catch (e) {

      emit(

        state.copyWith(

          summaryLoading: false,

          errorMessage: e.toString(),

          errorKind: AnalyticsErrorKind.unknown,

        ),

      );

    }

  }



  Future<void> _loadAttendance(

    Emitter<AnalyticsState> emit, {

    bool force = false,

  }) async {

    if (!force &&

        state.attendance != null &&

        state.attendance!.year == state.year &&

        state.attendance!.week == state.week) {

      return;

    }

    emit(state.copyWith(attendanceLoading: true, clearError: true));

    try {

      final data = await _repository.loadWeeklyAttendance(

        year: state.year,

        week: state.week,

      );

      emit(state.copyWith(attendanceLoading: false, attendance: data));

    } on AnalyticsApiException catch (e) {

      emit(

        state.copyWith(

          attendanceLoading: false,

          errorMessage: e.message,

          errorKind: e.kind,

        ),

      );

    } catch (e) {

      emit(

        state.copyWith(

          attendanceLoading: false,

          errorMessage: e.toString(),

          errorKind: AnalyticsErrorKind.unknown,

        ),

      );

    }

  }



  Future<void> _loadBusiness(

    Emitter<AnalyticsState> emit, {

    bool force = false,

  }) async {

    if (!force &&

        state.business != null &&

        state.business!.year == state.year &&

        state.business!.week == state.week) {

      return;

    }

    emit(state.copyWith(businessLoading: true, clearError: true));

    try {

      final data = await _repository.loadWeeklyBusiness(

        year: state.year,

        week: state.week,

      );

      emit(state.copyWith(businessLoading: false, business: data));

    } on AnalyticsApiException catch (e) {

      emit(

        state.copyWith(

          businessLoading: false,

          errorMessage: e.message,

          errorKind: e.kind,

        ),

      );

    } catch (e) {

      emit(

        state.copyWith(

          businessLoading: false,

          errorMessage: e.toString(),

          errorKind: AnalyticsErrorKind.unknown,

        ),

      );

    }

  }



  Future<void> _loadBilling(

    Emitter<AnalyticsState> emit, {

    bool force = false,

  }) async {

    if (!force &&

        state.billing != null &&

        state.billing!.year == state.billingYear) {

      return;

    }

    emit(state.copyWith(billingLoading: true, clearError: true));

    try {

      final data = await _repository.loadMonthlyBilling(year: state.billingYear);

      emit(state.copyWith(billingLoading: false, billing: data));

    } on AnalyticsApiException catch (e) {

      emit(

        state.copyWith(

          billingLoading: false,

          errorMessage: e.message,

          errorKind: e.kind,

        ),

      );

    } catch (e) {

      emit(

        state.copyWith(

          billingLoading: false,

          errorMessage: e.toString(),

          errorKind: AnalyticsErrorKind.unknown,

        ),

      );

    }

  }



  Future<void> _loadLeaves(

    Emitter<AnalyticsState> emit, {

    bool force = false,

  }) async {

    final now = DateTime.now();

    if (!force &&

        state.leaveAnalytics != null &&

        state.leaveAnalytics!.year == now.year &&

        state.leaveAnalytics!.month == now.month) {

      return;

    }

    emit(state.copyWith(leaveLoading: true, clearError: true));

    try {

      final data = await _repository.loadLeaveAnalytics(

        year: now.year,

        month: now.month,

      );

      emit(state.copyWith(leaveLoading: false, leaveAnalytics: data));

    } on AnalyticsApiException catch (e) {

      emit(

        state.copyWith(

          leaveLoading: false,

          errorMessage: e.message,

          errorKind: e.kind,

        ),

      );

    } catch (e) {

      emit(

        state.copyWith(

          leaveLoading: false,

          errorMessage: e.toString(),

          errorKind: AnalyticsErrorKind.unknown,

        ),

      );

    }

  }



  /// Overdue = due date before today and not completed. Pulled from the
  /// admin tasks queue (not an analytics endpoint), so failures here are
  /// swallowed rather than surfaced as an Overview-wide error.
  Future<void> _loadOverdueTasks(
    Emitter<AnalyticsState> emit, {
    bool force = false,
  }) async {
    if (!force && state.overdueTasks != null) return;
    emit(state.copyWith(tasksLoading: true));
    try {
      final tasks = await _adminRepository.fetchTasks();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final overdue = tasks.where((t) {
        if (t.status == 'completed') return false;
        final due = DateTime.tryParse(t.dueDate ?? '');
        if (due == null) return false;
        return DateTime(due.year, due.month, due.day).isBefore(today);
      }).toList()
        ..sort((a, b) => (a.dueDate ?? '').compareTo(b.dueDate ?? ''));
      emit(state.copyWith(tasksLoading: false, overdueTasks: overdue));
    } catch (_) {
      emit(
        state.copyWith(
          tasksLoading: false,
          overdueTasks: state.overdueTasks ?? const [],
        ),
      );
    }
  }
}


