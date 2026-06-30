import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import 'package:my_app/event_management/features/calendar/domain/entities/calendar_holiday.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<Event>>> getToday();
  Future<Either<Failure, List<Event>>> getUpcoming({int limit = 10});
  Future<Either<Failure, List<Event>>> getMissed({int limit = 10});
  Future<Either<Failure, List<CalendarHoliday>>> getMonthHolidays(
    DateTime month,
  );
}
