import 'employee.dart';

/// Today's live attendance plus total staff count for dashboard summaries.
class LiveAttendanceSnapshot {
  final int totalEmployees;
  final List<Employee> todayLoggedIn;

  const LiveAttendanceSnapshot({
    required this.totalEmployees,
    this.todayLoggedIn = const [],
  });

  int get loggedInToday => todayLoggedIn.length;

  int get workingCount =>
      todayLoggedIn.where((e) => e.liveStatus == LiveStatus.working).length;

  int get breakCount =>
      todayLoggedIn.where((e) => e.liveStatus == LiveStatus.breakTime).length;

  int get loggedOutCount =>
      todayLoggedIn.where((e) => e.liveStatus == LiveStatus.loggedOut).length;
}
