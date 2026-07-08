import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/leave_management/services/leave_holiday_repository.dart';
import 'package:my_app/leave_management/widgets/leave_holiday_month_calendar.dart';

/// Date picker dialog with public holidays highlighted on the month calendar.
class LeaveHolidayDatePickerDialog extends StatefulWidget {
  const LeaveHolidayDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title = 'Select date',
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String title = 'Select date',
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (_) => LeaveHolidayDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        title: title,
      ),
    );
  }

  @override
  State<LeaveHolidayDatePickerDialog> createState() =>
      _LeaveHolidayDatePickerDialogState();
}

class _LeaveHolidayDatePickerDialogState
    extends State<LeaveHolidayDatePickerDialog> {
  late DateTime _selected;
  late int _year;
  late int _month;
  final _repository = LeaveHolidayRepository();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _year = _selected.year;
    _month = _selected.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: EmployeeDashboardV2Theme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Orange dates are public holidays — tap to see details.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              LeaveHolidayMonthCalendar(
                year: _year,
                month: _month,
                selectedDay: _selected,
                compact: true,
                holidayRepository: _repository,
                onDaySelected: (day) {
                  if (day.isBefore(_stripTime(widget.firstDate)) ||
                      day.isAfter(_stripTime(widget.lastDate))) {
                    return;
                  }
                  setState(() => _selected = day);
                },
                onMonthChanged: (year, month) {
                  setState(() {
                    _year = year;
                    _month = month;
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: EmployeeDashboardV2Theme.greenMid,
                    ),
                    onPressed: () => Navigator.pop(context, _selected),
                    child: Text(
                      'Use ${DateFormat('d MMM yyyy').format(_selected)}',
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

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);
}
