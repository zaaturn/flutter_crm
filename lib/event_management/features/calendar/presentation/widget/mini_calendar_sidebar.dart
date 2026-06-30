import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_holiday.dart';
import '../../shared/calendar_date_utils.dart';
import '../../shared/calendar_ui_theme.dart';
import '../../shared/holiday_ui_theme.dart';
import 'holiday_popover.dart';

/// Left panel: mini calendar card + Filters with checkboxes.
class MiniCalendarSidebar extends StatefulWidget {
  const MiniCalendarSidebar({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.enabledTypes,
    required this.onToggleType,
    required this.dotMap,
    required this.holidaysByDate,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final Set<String> enabledTypes;
  final ValueChanged<String> onToggleType;
  final Map<String, List<String>> dotMap;
  final Map<String, List<CalendarHoliday>> holidaysByDate;

  static const sidebarWidth = 248.0;

  static const _filterItems = <({String key, String label})>[
    (key: 'meeting', label: 'Meetings'),
    (key: 'task', label: 'Tasks'),
    (key: 'reminder', label: 'Reminders'),
    (key: 'personal', label: 'Personal'),
  ];

  @override
  State<MiniCalendarSidebar> createState() => _MiniCalendarSidebarState();
}

class _MiniCalendarSidebarState extends State<MiniCalendarSidebar> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Color _dotColor(String type) {
    if (type == 'holiday') return HolidayUiTheme.orange;
    return CalendarUiTheme.legendColor(type);
  }

  @override
  Widget build(BuildContext context) {
    final days = CalendarDateUtils.daysInMonthGrid(widget.focusedMonth);
    final today = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(widget.focusedMonth);

    return SizedBox(
      width: MiniCalendarSidebar.sidebarWidth,
      child: Scrollbar(
        controller: _scroll,
        thumbVisibility: true,
        interactive: true,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _card(
                child: Column(
                  children: [
                    _miniCalendarHeader(monthLabel),
                    const SizedBox(height: 10),
                    _weekdayRow(),
                    const SizedBox(height: 6),
                    _miniCalendarGrid(days, today),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CalendarUiTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...MiniCalendarSidebar._filterItems.map(_filterCheckbox),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CalendarUiTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CalendarUiTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _miniCalendarHeader(String monthLabel) {
    return Row(
      children: [
        _navBtn(Icons.chevron_left, () => widget.onMonthChanged(
              DateTime(widget.focusedMonth.year, widget.focusedMonth.month - 1, 1),
            )),
        Expanded(
          child: Text(
            monthLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CalendarUiTheme.textDark,
            ),
          ),
        ),
        _navBtn(Icons.chevron_right, () => widget.onMonthChanged(
              DateTime(widget.focusedMonth.year, widget.focusedMonth.month + 1, 1),
            )),
      ],
    );
  }

  Widget _weekdayRow() {
    return Row(
      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CalendarUiTheme.textMuted,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _miniCalendarGrid(List<DateTime> days, DateTime today) {
    // Fixed row height — avoids bottom overflow when date + dot indicators are shown.
    const rowHeight = 40.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        mainAxisExtent: rowHeight,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final inMonth = day.month == widget.focusedMonth.month;
        final isSelected = CalendarDateUtils.isSameDay(day, widget.selectedDate);
        final key = CalendarDateUtils.dateKey(day);
        final dots = widget.dotMap[key] ?? const [];
        final dayHolidays = widget.holidaysByDate[key] ?? const [];
        final hasHoliday = dayHolidays.isNotEmpty;
        final tooltip = hasHoliday
            ? dayHolidays.map((h) => h.name).join(', ')
            : null;

        Widget cell = SizedBox(
          height: rowHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? CalendarUiTheme.primary : null,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: isSelected
                        ? Colors.white
                        : (hasHoliday
                            ? HolidayUiTheme.orange
                            : (inMonth
                                ? CalendarUiTheme.textDark
                                : const Color(0xFFD1D5DB))),
                  ),
                ),
              ),
              if (dots.isNotEmpty)
                Positioned(
                  bottom: 1,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dots.take(3).map((type) {
                      return Container(
                        width: 3.5,
                        height: 3.5,
                        margin: const EdgeInsets.symmetric(horizontal: 0.8),
                        decoration: BoxDecoration(
                          color: _dotColor(type),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );

        if (tooltip != null) {
          cell = Tooltip(message: tooltip, child: cell);
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (hasHoliday && dayHolidays.length == 1) {
                showHolidayPopover(context, holiday: dayHolidays.first);
              }
              widget.onDateSelected(day);
            },
            borderRadius: BorderRadius.circular(20),
            child: cell,
          ),
        );
      },
    );
  }

  Widget _filterCheckbox(({String key, String label}) item) {
    final checked = widget.enabledTypes.contains(item.key);
    final color = CalendarUiTheme.legendColor(item.key);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => widget.onToggleType(item.key),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: checked,
                  onChanged: (_) => widget.onToggleType(item.key),
                  activeColor: color,
                  side: BorderSide(color: color.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: CalendarUiTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: CalendarUiTheme.textMuted),
        ),
      ),
    );
  }
}
