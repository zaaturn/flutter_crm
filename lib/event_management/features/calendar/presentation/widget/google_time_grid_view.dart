import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_grid_event.dart';
import '../../domain/entities/calendar_holiday.dart';
import '../../shared/calendar_date_utils.dart';
import '../../shared/calendar_overlap_layout.dart';
import '../../shared/calendar_ui_theme.dart';
import '../../shared/holiday_ui_theme.dart';
import 'holiday_chip.dart';
import 'holiday_popover.dart';

typedef CalendarSlotTap = void Function(DateTime start, DateTime end);
typedef CalendarEventMove = void Function(
  CalendarGridEvent event,
  DateTime newStart,
  DateTime newEnd,
);

class GoogleTimeGridView extends StatefulWidget {
  const GoogleTimeGridView({
    super.key,
    required this.days,
    required this.events,
    required this.holidaysByDate,
    required this.onSlotTap,
    required this.onEventTap,
    required this.onEventMove,
    this.onEventResize,
  });

  final List<DateTime> days;
  final List<CalendarGridEvent> events;
  final Map<String, List<CalendarHoliday>> holidaysByDate;
  final CalendarSlotTap onSlotTap;
  final ValueChanged<CalendarGridEvent> onEventTap;
  final CalendarEventMove onEventMove;
  final CalendarEventMove? onEventResize;

  @override
  State<GoogleTimeGridView> createState() => _GoogleTimeGridViewState();
}

class _GoogleTimeGridViewState extends State<GoogleTimeGridView> {
  static const double hourHeight = 64;
  static const int startHour = 6;
  static const int endHour = 22;
  static const double columnGap = 10;
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
    final offset = (h + now.minute / 60 - startHour) * hourHeight - 80;
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hasAllDay = widget.days.any(
      (d) => _allDayForDay(d).isNotEmpty || _holidaysForDay(d).isNotEmpty,
    );
    final dayBannerHolidays = widget.days.length == 1
        ? _holidaysForDay(widget.days.first)
        : const <CalendarHoliday>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (dayBannerHolidays.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
            child: _HolidayDayBanner(holidays: dayBannerHolidays),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
          child: _buildDayHeader(now),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 16, 8),
            child: Scrollbar(
              controller: _scroll,
              thumbVisibility: true,
              interactive: true,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                controller: _scroll,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasAllDay) ...[
                    _buildAllDayRow(),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    height: _gridHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 52,
                          child: Column(
                            children: List.generate(endHour - startHour, (i) {
                              final hour = startHour + i;
                              return SizedBox(
                                height: hourHeight,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 8,
                                      top: 4,
                                    ),
                                    child: Text(
                                      DateFormat('hh a').format(
                                        DateTime(2000, 1, 1, hour),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: CalendarUiTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < widget.days.length; i++) ...[
                                if (i > 0) const SizedBox(width: columnGap),
                                Expanded(
                                  child: _dayColumn(widget.days[i], now),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildDayHeader(DateTime now) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 52),
        ...widget.days.asMap().entries.map((entry) {
          final i = entry.key;
          final day = entry.value;
          final isToday = CalendarDateUtils.isSameDay(day, now);
          final hasHoliday = _holidaysForDay(day).isNotEmpty;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i > 0 ? columnGap : 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: hasHoliday ? HolidayUiTheme.dayTint : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasHoliday
                        ? HolidayUiTheme.orange.withValues(alpha: 0.35)
                        : CalendarUiTheme.border,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('EEEE').format(day),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hasHoliday
                            ? HolidayUiTheme.orange
                            : (isToday
                                ? CalendarUiTheme.primary
                                : CalendarUiTheme.textMuted),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: hasHoliday
                            ? HolidayUiTheme.orange
                            : (isToday
                                ? CalendarUiTheme.primary
                                : CalendarUiTheme.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAllDayRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 52,
          child: Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'All day',
              style: TextStyle(fontSize: 10, color: CalendarUiTheme.textMuted),
            ),
          ),
        ),
        ...widget.days.asMap().entries.map((entry) {
          final i = entry.key;
          final day = entry.value;
          final items = _allDayForDay(day);
          final holidays = _holidaysForDay(day);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i > 0 ? columnGap : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...holidays.map((h) => HolidayAllDayChip(holiday: h)),
                  if (items.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: items.map(_allDayChip).toList(),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _allDayChip(CalendarGridEvent e) {
    final fill = CalendarUiTheme.weekBlockFill(
      e.eventType,
      isTaskDeadline: e.isTaskDeadline,
    );
    final text = CalendarUiTheme.weekBlockText(
      e.eventType,
      isTaskDeadline: e.isTaskDeadline,
    );
    return GestureDetector(
      onTap: () => widget.onEventTap(e),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          e.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: text,
          ),
        ),
      ),
    );
  }

  Widget _dayColumn(DateTime day, DateTime now) {
    final timed = _timedForDay(day);
    final layouts = layoutOverlappingEvents(timed);
    final showNowLine = CalendarDateUtils.isSameDay(day, now);
    final nowTop = (now.hour + now.minute / 60 - startHour) * hourHeight;
    final hasHoliday = _holidaysForDay(day).isNotEmpty;

    return SizedBox(
      height: _gridHeight,
      child: Container(
        decoration: BoxDecoration(
          color: hasHoliday ? HolidayUiTheme.dayTint : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasHoliday
                ? HolidayUiTheme.orange.withValues(alpha: 0.25)
                : CalendarUiTheme.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final colWidth = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  if (_tapHitsEvent(
                    details.localPosition,
                    layouts,
                    colWidth,
                  )) {
                    return;
                  }
                  final y = details.localPosition.dy;
                  final minutes =
                      ((y / hourHeight) * 60 + startHour * 60).round();
                  final snapped = (minutes / 30).round() * 30;
                  final start = DateTime(
                    day.year,
                    day.month,
                    day.day,
                    (snapped ~/ 60).clamp(startHour, endHour - 1),
                    snapped % 60,
                  );
                  widget.onSlotTap(
                    start,
                    start.add(const Duration(hours: 1)),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Column(
                      children: List.generate(endHour - startHour, (_) {
                        return SizedBox(
                          height: hourHeight,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF0F4F2),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    ...layouts.map(
                      (layout) => _positionedEvent(layout, colWidth),
                    ),
                    if (showNowLine &&
                        now.hour >= startHour &&
                        now.hour < endHour)
                      Positioned(
                        top: nowTop.clamp(0.0, _gridHeight),
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE24B4A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: const Color(0xFFE24B4A),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _positionedEvent(CalendarEventLayout layout, double colWidth) {
    final bounds = _eventBounds(layout, colWidth);

    return Positioned(
      top: bounds.top,
      left: bounds.left,
      width: bounds.width,
      height: bounds.height,
      child: _WeekEventBlock(
        event: layout.event,
        onTap: () => widget.onEventTap(layout.event),
        onMoved: (deltaMinutes) {
          final e = layout.event;
          final newStart = e.startTime.add(Duration(minutes: deltaMinutes));
          final newEnd = e.endTime.add(Duration(minutes: deltaMinutes));
          widget.onEventMove(e, newStart, newEnd);
        },
        onResized: widget.onEventResize == null
            ? null
            : (deltaMinutes) {
                final e = layout.event;
                final newEnd = e.endTime.add(Duration(minutes: deltaMinutes));
                if (newEnd.isAfter(
                    e.startTime.add(const Duration(minutes: 15)))) {
                  widget.onEventResize!(e, e.startTime, newEnd);
                }
              },
      ),
    );
  }

  _EventBlockBounds _eventBounds(CalendarEventLayout layout, double colWidth) {
    final e = layout.event;
    final start = e.startTime.toLocal();
    final end = e.endTime.toLocal();

    var top = (start.hour + start.minute / 60 - startHour) * hourHeight;
    if (top < 0) top = 0;

    var height = ((end.difference(start).inMinutes) / 60 * hourHeight)
        .clamp(28.0, _gridHeight)
        .toDouble();

    if (top + height > _gridHeight) {
      height = (_gridHeight - top).clamp(28.0, _gridHeight);
    }

    final widthFrac = 1 / layout.columnCount;
    final left = layout.column * colWidth * widthFrac + 4;
    final width = (colWidth * widthFrac - 8).clamp(8.0, colWidth);

    return _EventBlockBounds(
      top: top,
      left: left,
      width: width,
      height: height,
    );
  }

  bool _tapHitsEvent(
    Offset position,
    List<CalendarEventLayout> layouts,
    double colWidth,
  ) {
    for (final layout in layouts) {
      final b = _eventBounds(layout, colWidth);
      if (position.dx >= b.left &&
          position.dx <= b.left + b.width &&
          position.dy >= b.top &&
          position.dy <= b.top + b.height) {
        return true;
      }
    }
    return false;
  }
}

class _EventBlockBounds {
  const _EventBlockBounds({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  final double top;
  final double left;
  final double width;
  final double height;
}

class _WeekEventBlock extends StatefulWidget {
  const _WeekEventBlock({
    required this.event,
    required this.onTap,
    required this.onMoved,
    this.onResized,
  });

  final CalendarGridEvent event;
  final VoidCallback onTap;
  final ValueChanged<int> onMoved;
  final ValueChanged<int>? onResized;

  @override
  State<_WeekEventBlock> createState() => _WeekEventBlockState();
}

class _WeekEventBlockState extends State<_WeekEventBlock> {
  double _dragDy = 0;
  bool _isDragging = false;
  bool get _canEdit => !widget.event.isTaskApiId;

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final start = e.startTime.toLocal();
    final end = e.endTime.toLocal();
    final fill = CalendarUiTheme.weekBlockFill(
      e.eventType,
      isTaskDeadline: e.isTaskDeadline,
    );
    final textColor = CalendarUiTheme.weekBlockText(
      e.eventType,
      isTaskDeadline: e.isTaskDeadline,
    );
    final timeRange =
        '${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end)}';

    return Transform.translate(
      offset: Offset(0, _dragDy),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onPanStart: !_canEdit ? null : (_) => _isDragging = false,
        onPanUpdate: !_canEdit
            ? null
            : (d) {
                if (d.delta.dy.abs() > 3) _isDragging = true;
                if (_isDragging) setState(() => _dragDy += d.delta.dy);
              },
        onPanEnd: !_canEdit
            ? null
            : (_) {
                if (_isDragging) {
                  final minutes =
                      ((_dragDy / _GoogleTimeGridViewState.hourHeight) * 60)
                          .round();
                  if (minutes != 0) widget.onMoved(minutes);
                }
                setState(() {
                  _dragDy = 0;
                  _isDragging = false;
                });
              },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: e.isCancelled ? fill.withValues(alpha: 0.5) : fill,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: textColor.withValues(alpha: 0.12),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showTime = constraints.maxHeight >= 42;
                  final titleLines = constraints.maxHeight >= 54 ? 2 : 1;
                  return ClipRect(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          e.title,
                          maxLines: titleLines,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: textColor,
                            decoration: e.isCancelled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (showTime) ...[
                          const SizedBox(height: 2),
                          Text(
                            timeRange,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HolidayDayBanner extends StatelessWidget {
  const _HolidayDayBanner({required this.holidays});

  final List<CalendarHoliday> holidays;

  @override
  Widget build(BuildContext context) {
    final h = holidays.first;
    final local = h.localName.trim();
    final parts = <String>[
      '${HolidayUiTheme.flag} ${h.name}',
      if (local.isNotEmpty) local,
      'National Holiday',
    ];

    return GestureDetector(
      onTap: () => showHolidayPopover(context, holiday: h),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: HolidayUiTheme.bannerGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          parts.join('  •  '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
