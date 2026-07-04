import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/calendar_grid_event.dart';
import '../../../domain/entities/calendar_holiday.dart';
import '../../../shared/calendar_date_utils.dart';
import '../../../shared/calendar_overlap_layout.dart';
import '../mobile_calendar_theme.dart';

typedef MobileWeekSlotTap = void Function(DateTime start, DateTime end);
typedef MobileWeekEventMove = void Function(
  CalendarGridEvent event,
  DateTime newStart,
  DateTime newEnd,
);

/// Mobile week time grid — cream background, horizontal lines, colored blocks.
class MobileCalendarWeekGrid extends StatefulWidget {
  const MobileCalendarWeekGrid({
    super.key,
    required this.days,
    required this.events,
    required this.holidaysByDate,
    required this.onSlotTap,
    required this.onEventTap,
    required this.onEventMove,
  });

  final List<DateTime> days;
  final List<CalendarGridEvent> events;
  final Map<String, List<CalendarHoliday>> holidaysByDate;
  final MobileWeekSlotTap onSlotTap;
  final ValueChanged<CalendarGridEvent> onEventTap;
  final MobileWeekEventMove onEventMove;

  @override
  State<MobileCalendarWeekGrid> createState() => _MobileCalendarWeekGridState();
}

class _MobileCalendarWeekGridState extends State<MobileCalendarWeekGrid> {
  static const double hourHeight = 48;
  static const int startHour = 0;
  static const int endHour = 24;
  static const double timeGutter = 46;

  final ScrollController _scroll = ScrollController();

  double get _gridHeight => (endHour - startHour) * hourHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  void _scrollToNow() {
    if (!_scroll.hasClients) return;
    final now = DateTime.now();
    final h = now.hour.clamp(startHour, endHour - 1);
    final offset = (h + now.minute / 60 - startHour) * hourHeight - 72;
    _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<CalendarGridEvent> _timedForDay(DateTime day) {
    return widget.events.where((e) {
      if (e.isAllDay || e.isTaskDeadline) return false;
      final s = e.startTime.toLocal();
      return CalendarDateUtils.isSameDay(
        DateTime(s.year, s.month, s.day),
        day,
      );
    }).toList();
  }

  List<CalendarGridEvent> _allDayForDay(DateTime day) {
    return widget.events.where((e) {
      if (!e.isAllDay && !e.isTaskDeadline) return false;
      final s = e.startTime.toLocal();
      return CalendarDateUtils.isSameDay(
        DateTime(s.year, s.month, s.day),
        day,
      );
    }).toList();
  }

  List<CalendarHoliday> _holidaysForDay(DateTime day) {
    return widget.holidaysByDate[CalendarDateUtils.dateKey(day)] ?? const [];
  }

  bool get _hasAllDay => widget.days.any(
        (d) => _allDayForDay(d).isNotEmpty || _holidaysForDay(d).isNotEmpty,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasAllDay) _buildAllDayRow(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.only(bottom: 88),
            child: SizedBox(
              height: _gridHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _timeGutter(),
                  Expanded(child: _gridBody()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeGutter() {
    return SizedBox(
      width: timeGutter,
      child: Column(
        children: List.generate(endHour - startHour, (i) {
          final hour = startHour + i;
          return SizedBox(
            height: hourHeight,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 6, top: 2),
                child: Text(
                  hour == 0
                      ? '12 AM'
                      : DateFormat('h a').format(DateTime(2000, 1, 1, hour)),
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: MobileCalendarTheme.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAllDayRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: timeGutter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: Text(
                'all-day',
                textAlign: TextAlign.right,
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: MobileCalendarTheme.textMuted,
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: widget.days.map((day) {
                final items = _allDayForDay(day);
                final holidays = _holidaysForDay(day);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...holidays.map(_holidayChip),
                        ...items.map(_allDayChip),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _holidayChip(CalendarHoliday h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF4A261),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          h.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _allDayChip(CalendarGridEvent e) {
    final fill = MobileCalendarTheme.weekBlockFill(e);
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: GestureDetector(
        onTap: () => widget.onEventTap(e),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            e.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _gridBody() {
    final now = DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidth = constraints.maxWidth / widget.days.length;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: List.generate(endHour - startHour, (i) {
                return SizedBox(
                  height: hourHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: MobileCalendarTheme.border.withValues(alpha: 0.7),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.days.map((day) {
                return SizedBox(
                  width: colWidth,
                  height: _gridHeight,
                  child: _dayColumn(day, colWidth, now),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _dayColumn(DateTime day, double colWidth, DateTime now) {
    final timed = _timedForDay(day);
    final layouts = layoutOverlappingEvents(timed);
    final showNow = CalendarDateUtils.isSameDay(day, now);
    final nowTop = (now.hour + now.minute / 60 - startHour) * hourHeight;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        if (_tapHitsEvent(details.localPosition, layouts, colWidth)) return;
        final y = details.localPosition.dy;
        final minutes = ((y / hourHeight) * 60 + startHour * 60).round();
        final snapped = (minutes / 30).round() * 30;
        final start = DateTime(
          day.year,
          day.month,
          day.day,
          (snapped ~/ 60).clamp(0, 23),
          snapped % 60,
        );
        widget.onSlotTap(start, start.add(const Duration(hours: 1)));
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...layouts.map((l) => _positionedEvent(l, colWidth)),
          if (showNow && now.hour >= startHour && now.hour <= 23)
            Positioned(
              top: nowTop.clamp(0.0, _gridHeight),
              left: 0,
              right: 0,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: MobileCalendarTheme.terracotta,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: MobileCalendarTheme.terracotta,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _positionedEvent(CalendarEventLayout layout, double colWidth) {
    final e = layout.event;
    final start = e.startTime.toLocal();
    final end = e.endTime.toLocal();

    var top = (start.hour + start.minute / 60 - startHour) * hourHeight;
    if (top < 0) top = 0;

    var height = ((end.difference(start).inMinutes) / 60 * hourHeight)
        .clamp(24.0, _gridHeight)
        .toDouble();
    if (top + height > _gridHeight) {
      height = (_gridHeight - top).clamp(24.0, _gridHeight);
    }

    final widthFrac = 1 / layout.columnCount;
    final left = layout.column * colWidth * widthFrac + 2;
    final width = (colWidth * widthFrac - 4).clamp(6.0, colWidth);

    final fill = MobileCalendarTheme.weekBlockFill(e);

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => widget.onEventTap(e),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          decoration: BoxDecoration(
            color: e.isCancelled ? fill.withValues(alpha: 0.45) : fill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.title,
                maxLines: height >= 44 ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: Colors.white,
                  decoration:
                      e.isCancelled ? TextDecoration.lineThrough : null,
                ),
              ),
              if (height >= 40) ...[
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(start),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _tapHitsEvent(
    Offset position,
    List<CalendarEventLayout> layouts,
    double colWidth,
  ) {
    for (final layout in layouts) {
      final e = layout.event;
      final start = e.startTime.toLocal();
      final end = e.endTime.toLocal();
      var top = (start.hour + start.minute / 60 - startHour) * hourHeight;
      if (top < 0) top = 0;
      var height = ((end.difference(start).inMinutes) / 60 * hourHeight)
          .clamp(24.0, _gridHeight)
          .toDouble();
      final widthFrac = 1 / layout.columnCount;
      final left = layout.column * colWidth * widthFrac + 2;
      final width = (colWidth * widthFrac - 4).clamp(6.0, colWidth);
      if (position.dx >= left &&
          position.dx <= left + width &&
          position.dy >= top &&
          position.dy <= top + height) {
        return true;
      }
    }
    return false;
  }
}
