import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/domain/repositories/event_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final EventRepository _events;

  DashboardRepositoryImpl(this._events);

  @override
  Future<Either<Failure, List<Event>>> getToday() => _events.getTodayEvents();

  @override
  Future<Either<Failure, List<Event>>> getUpcoming({int limit = 10}) =>
      _events.getUpcomingEvents(limit: limit);

  @override
  Future<Either<Failure, List<Event>>> getMissed({int limit = 10}) =>
      _events.getMissedEvents(limit: limit);
}
