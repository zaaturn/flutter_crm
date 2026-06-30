import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import 'package:my_app/event_management/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:my_app/event_management/features/calendar/domain/entities/calendar_holiday.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/domain/repositories/event_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._events, this._calendar);

  final EventRepository _events;
  final CalendarRemoteDataSource _calendar;

  @override
  Future<Either<Failure, List<Event>>> getToday() => _events.getTodayEvents();

  @override
  Future<Either<Failure, List<Event>>> getUpcoming({int limit = 10}) =>
      _events.getUpcomingEvents(limit: limit);

  @override
  Future<Either<Failure, List<Event>>> getMissed({int limit = 10}) =>
      _events.getMissedEvents(limit: limit);

  @override
  Future<Either<Failure, List<CalendarHoliday>>> getMonthHolidays(
    DateTime month,
  ) async {
    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0);
      final data = await _calendar.getCalendarRange(
        start: start,
        end: end,
        includeHolidays: true,
      );
      final sorted = List<CalendarHoliday>.from(data.holidays)
        ..sort((a, b) => a.date.compareTo(b.date));
      return Right(sorted);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
