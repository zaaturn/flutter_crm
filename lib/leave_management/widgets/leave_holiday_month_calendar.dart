import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/leave_management/models/public_holiday.dart';
import 'package:my_app/leave_management/services/leave_holiday_repository.dart';

/// Month grid with highlighted public holidays and a list below the calendar.
class LeaveHolidayMonthCalendar extends StatefulWidget {
  const LeaveHolidayMonthCalendar({
    super.key,
    required this.year,
    required this.month,
    this.selectedDay,
    this.onDaySelected,
    this.onMonthChanged,
    this.showHolidayList = true,
    this.compact = false,
    this.holidayRepository,
  });

  final int year;
  final int month;
  final DateTime? selectedDay;
  final ValueChanged<DateTime>? onDaySelected;
  final void Function(int year, int month)? onMonthChanged;
  final bool showHolidayList;
  final bool compact;
  final LeaveHolidayRepository? holidayRepository;

  @override
  State<LeaveHolidayMonthCalendar> createState() =>
      _LeaveHolidayMonthCalendarState();
}

class _LeaveHolidayMonthCalendarState extends State<LeaveHolidayMonthCalendar> {
  static const _holidayBg = Color(0xFFFFF7ED);
  static const _holidayBorder = Color(0xFFEA580C);
  static const _holidayText = Color(0xFFC2410C);

  late DateTime _focusedDay;
  late LeaveHolidayRepository _repository;

  bool _loading = true;
  String? _error;
  List<PublicHoliday> _monthHolidays = [];
  Map<DateTime, PublicHoliday> _holidayMap = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.holidayRepository ?? LeaveHolidayRepository();
    _focusedDay = DateTime(widget.year, widget.month, 1);
    _loadHolidays(widget.year, widget.month);
  }

  @override
  void didUpdateWidget(covariant LeaveHolidayMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      _focusedDay = DateTime(widget.year, widget.month, 1);
      _loadHolidays(widget.year, widget.month);
    }
  }

  Future<void> _loadHolidays(int year, int month) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repository.holidaysForMonth(year, month);
      if (!mounted) return;
      setState(() {
        _monthHolidays = list;
        _holidayMap = _repository.holidaysByDate(list);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  PublicHoliday? _holidayOn(DateTime day) {
    return _holidayMap[DateTime(day.year, day.month, day.day)];
  }

  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final holiday = _holidayOn(selectedDay);
    if (holiday != null) {
      _showHolidaySheet(holiday);
    }
    widget.onDaySelected?.call(selectedDay);
    setState(() => _focusedDay = focusedDay);
  }

  void _showHolidaySheet(PublicHoliday holiday) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _holidayBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _holidayBorder.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(
                      Icons.celebration_rounded,
                      color: _holidayBorder,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holiday.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: EmployeeDashboardV2Theme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          holiday.listLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: EmployeeDashboardV2Theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(
            color: EmployeeDashboardV2Theme.green,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Could not load holidays',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => _loadHolidays(widget.year, widget.month), child: const Text('Retry')),
          ],
        ),
      );
    }

    final rowHeight = widget.compact ? 40.0 : 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar<void>(
          firstDay: DateTime(widget.year, 1, 1),
          lastDay: DateTime(widget.year, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: widget.selectedDay == null
              ? null
              : (day) => isSameDay(day, widget.selectedDay),
          startingDayOfWeek: StartingDayOfWeek.monday,
          rowHeight: rowHeight,
          daysOfWeekHeight: widget.compact ? 24 : 28,
          onDaySelected: _handleDaySelected,
          onPageChanged: (focusedDay) {
            final changed = focusedDay.month != _focusedDay.month ||
                focusedDay.year != _focusedDay.year;
            setState(() => _focusedDay = focusedDay);
            if (changed) {
              widget.onMonthChanged?.call(focusedDay.year, focusedDay.month);
              _loadHolidays(focusedDay.year, focusedDay.month);
            }
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: GoogleFonts.plusJakartaSans(
              fontSize: widget.compact ? 15 : 17,
              fontWeight: FontWeight.w800,
              color: EmployeeDashboardV2Theme.textDark,
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left_rounded,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right_rounded,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
            weekendStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: BoxDecoration(
              color: EmployeeDashboardV2Theme.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            todayTextStyle: GoogleFonts.plusJakartaSans(
              color: EmployeeDashboardV2Theme.greenMid,
              fontWeight: FontWeight.w800,
            ),
            selectedDecoration: const BoxDecoration(
              color: EmployeeDashboardV2Theme.greenMid,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            defaultTextStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: EmployeeDashboardV2Theme.textDark,
              fontSize: 13,
            ),
            weekendTextStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: EmployeeDashboardV2Theme.textBody,
              fontSize: 13,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) =>
                _buildDayCell(day, isSelected: false),
            todayBuilder: (context, day, focusedDay) =>
                _buildDayCell(day, isToday: true, isSelected: false),
            selectedBuilder: (context, day, focusedDay) =>
                _buildDayCell(day, isSelected: true),
            outsideBuilder: (context, day, focusedDay) => const SizedBox.shrink(),
          ),
        ),
        if (widget.showHolidayList) ...[
          const SizedBox(height: 20),
          _buildHolidayList(),
        ],
      ],
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final holiday = _holidayOn(day);
    final isHoliday = holiday != null;

    if (isHoliday) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _holidayBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? EmployeeDashboardV2Theme.greenMid : _holidayBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: GoogleFonts.plusJakartaSans(
            color: _holidayText,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      );
    }

    if (isSelected) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: EmployeeDashboardV2Theme.greenMid,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      );
    }

    if (isToday) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: EmployeeDashboardV2Theme.green.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: GoogleFonts.plusJakartaSans(
            color: EmployeeDashboardV2Theme.greenMid,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      );
    }

    return Center(
      child: Text(
        '${day.day}',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: EmployeeDashboardV2Theme.textDark,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildHolidayList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Holidays in ${DateFormat('MMMM yyyy').format(_focusedDay)}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: EmployeeDashboardV2Theme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (_monthHolidays.isEmpty)
          Text(
            'No public holidays this month.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          )
        else
          ..._monthHolidays.map(_buildHolidayListTile),
      ],
    );
  }

  Widget _buildHolidayListTile(PublicHoliday holiday) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showHolidaySheet(holiday),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _holidayBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _holidayBorder.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_rounded, size: 18, color: _holidayBorder),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  holiday.listLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: EmployeeDashboardV2Theme.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
