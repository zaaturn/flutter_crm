import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import 'package:my_app/event_management/features/calendar/domain/entities/calendar_holiday.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import '../repositories/dashboard_repository.dart';

class FetchDashboardUseCase {
  final DashboardRepository repository;

  FetchDashboardUseCase(this.repository);

  Future<Either<Failure, List<Event>>> getToday() => repository.getToday();

  Future<Either<Failure, List<Event>>> getUpcoming({int limit = 10}) =>
      repository.getUpcoming(limit: limit);

  Future<Either<Failure, List<Event>>> getMissed({int limit = 10}) =>
      repository.getMissed(limit: limit);

  Future<Either<Failure, List<CalendarHoliday>>> getMonthHolidays(
    DateTime month,
  ) =>
      repository.getMonthHolidays(month);
}
