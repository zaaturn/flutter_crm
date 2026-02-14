import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/domain/entities/event_entity.dart';
import 'package:my_app/event_management/features/presentation/widgets/device_specific/event_chip_desktop.dart';



class CalendarViewDesktop extends StatelessWidget {
  final List<EventEntity> events;
  final CalendarFormat format;
  final DateTime focusedDay;
  final void Function(DateTime) onDayTapped;
  final void Function(EventEntity) onEventTapped;

  const CalendarViewDesktop({
    super.key,
    required this.events,
    required this.format,
    required this.focusedDay,
    required this.onDayTapped,
    required this.onEventTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (format == CalendarFormat.twoWeeks) {
      return _buildHourlyView();
    }
    return _buildGridView();
  }

  // ── MONTH / WEEK GRID ────────────────────────────────────────────────
  Widget _buildGridView() {
    return SizedBox.expand(
        child: TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: focusedDay,
          calendarFormat: format,
          headerVisible: false,
          shouldFillViewport: true,
          rowHeight: 90,


      calendarStyle: CalendarStyle(
        tableBorder: TableBorder.all(color: const Color(0xFFE5E7EB), width: 1),
        defaultDecoration: const BoxDecoration(shape: BoxShape.rectangle),
        weekendDecoration: const BoxDecoration(shape: BoxShape.rectangle),
        outsideDecoration: const BoxDecoration(shape: BoxShape.rectangle),
        markersMaxCount: 0,
        todayDecoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          shape: BoxShape.rectangle,
          border: Border.all(color: const Color(0xFF6366F1), width: 1),
        ),
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF6366F1),
          shape: BoxShape.rectangle,
        ),
      ),


      calendarBuilders: CalendarBuilders(
        prioritizedBuilder: (context, date, focusedDay) {
          final dayEvents =
          events.where((e) => isSameDay(e.start, date)).toList();

          return Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                ...dayEvents.take(3).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: EventChipCompact(
                    event: e,
                    onTap: () => onEventTapped(e),
                  ),
                )),
              ],
            ),
          );
        },
      ),





      onDaySelected: (selected, focused) => onDayTapped(selected),
      eventLoader: (day) =>
          events.where((e) => isSameDay(e.start, day)).toList(),
    ));
  }

  // ── HOURLY DAY VIEW ──────────────────────────────────────────────────
  Widget _buildHourlyView() {
    const double hourHeight = 100.0;
    final double totalHeight = 24 * hourHeight;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: SizedBox(
          height: totalHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeGutter(hourHeight),

              Expanded(
                child: Stack(
                  children: [
                    _buildGridBackground(hourHeight),
                    _buildEventLayer(hourHeight),
                    _buildCurrentTimeLine(hourHeight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTimeGutter(double h) {
    return Container(
      width: 80,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: List.generate(24, (i) {
          final hour = i == 0
              ? "12 AM"
              : i < 12
              ? "$i AM"
              : i == 12
              ? "12 PM"
              : "${i - 12} PM";

          return SizedBox(
            height: h,
            child: Center(
              child: Text(
                hour,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridBackground(double h) {
    return Column(
      children: List.generate(
        24,
            (i) => Container(
          height: h,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeLine(double h) {
    final now = DateTime.now().toLocal();

    if (!isSameDay(now, focusedDay)) {
      return const SizedBox.shrink();
    }

    final top = (now.hour * h) + ((now.minute / 60) * h);
    final timeText = DateFormat('hh:mm a').format(now);

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: timeText,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(color: Colors.white),
          child: Row(
            children: [
              const CircleAvatar(radius: 5, backgroundColor: Colors.red),
              Expanded(
                child: Container(height: 2, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildEventLayer(double h) {
    final dayEvents =
    events.where((e) => isSameDay(e.start, focusedDay)).toList();

    return Stack(
      children: dayEvents.map((ev) {
        final startPos =
            (ev.start.hour * h) + ((ev.start.minute / 60) * h);
        final height =
            (ev.end.difference(ev.start).inMinutes / 60) * h;

        return Positioned(
          top: startPos,
          left: 10,
          right: 20,
          height: height,
          child: ClipRect(
          child: EventChipDesktop(
            event: ev,
            onTap: () => onEventTapped(ev),
            availableHeight: height,
          ),
        ));
      }).toList(),
    );
  }
}
