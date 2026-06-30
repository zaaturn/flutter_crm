import '../domain/entities/calendar_grid_event.dart';

class CalendarEventLayout {
  const CalendarEventLayout({
    required this.event,
    required this.column,
    required this.columnCount,
  });

  final CalendarGridEvent event;
  final int column;
  final int columnCount;
}

bool calendarEventsOverlap(CalendarGridEvent a, CalendarGridEvent b) =>
    a.startTime.isBefore(b.endTime) && b.startTime.isBefore(a.endTime);

/// Assigns column indices for overlapping timed events (Google Calendar style).
List<CalendarEventLayout> layoutOverlappingEvents(
  List<CalendarGridEvent> events,
) {
  if (events.isEmpty) return [];

  final sorted = List<CalendarGridEvent>.from(events)
    ..sort((a, b) {
      final byStart = a.startTime.compareTo(b.startTime);
      if (byStart != 0) return byStart;
      return b.endTime.compareTo(a.endTime);
    });

  final columnEnds = <DateTime>[];
  final placements = <({CalendarGridEvent event, int column})>[];

  for (final e in sorted) {
    var col = -1;
    for (var i = 0; i < columnEnds.length; i++) {
      if (!columnEnds[i].isAfter(e.startTime)) {
        col = i;
        columnEnds[i] = e.endTime;
        break;
      }
    }
    if (col < 0) {
      col = columnEnds.length;
      columnEnds.add(e.endTime);
    }
    placements.add((event: e, column: col));
  }

  return placements.map((p) {
    var maxCol = p.column;
    for (final other in placements) {
      if (calendarEventsOverlap(p.event, other.event) && other.column > maxCol) {
        maxCol = other.column;
      }
    }
    return CalendarEventLayout(
      event: p.event,
      column: p.column,
      columnCount: maxCol + 1,
    );
  }).toList();
}
