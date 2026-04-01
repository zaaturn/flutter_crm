import 'package:equatable/equatable.dart';
import '../../../events/domain/entities/event.dart';

/// Aggregated dashboard data returned from the use case.
class DashboardData extends Equatable {
  final List<Event> todayEvents;
  final List<Event> upcomingEvents;
  final List<Event> missedEvents;

  const DashboardData({
    required this.todayEvents,
    required this.upcomingEvents,
    required this.missedEvents,
  });

  int get totalToday => todayEvents.length;
  int get totalUpcoming => upcomingEvents.length;
  int get totalMissed => missedEvents.length;

  DashboardData copyWith({
    List<Event>? todayEvents,
    List<Event>? upcomingEvents,
    List<Event>? missedEvents,
  }) {
    return DashboardData(
      todayEvents: todayEvents ?? this.todayEvents,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      missedEvents: missedEvents ?? this.missedEvents,
    );
  }

  @override
  List<Object?> get props => [todayEvents, upcomingEvents, missedEvents];
}