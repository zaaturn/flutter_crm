import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/calendar_ui_theme.dart';
import '../bloc/calender_state.dart';

class CalendarToolbar extends StatelessWidget {
  const CalendarToolbar({
    super.key,
    required this.calState,
    required this.onPrev,
    required this.onNext,
    required this.onViewChanged,
    required this.onSearch,
    required this.reminderCount,
    required this.onRemindersTap,
    required this.onNewEvent,
  });

  final CalendarState calState;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<CalendarView> onViewChanged;
  final VoidCallback onSearch;
  final int reminderCount;
  final VoidCallback onRemindersTap;
  final VoidCallback onNewEvent;

  String _dateLabel() {
    final anchor = calState.selectedDate ?? calState.focusedMonth;
    switch (calState.view) {
      case CalendarView.month:
        return DateFormat('MMMM, yyyy').format(calState.focusedMonth);
      case CalendarView.week:
        return DateFormat('MMMM, d yyyy').format(anchor);
      case CalendarView.day:
        return DateFormat('MMMM, d yyyy').format(anchor);
      case CalendarView.agenda:
        return DateFormat('MMMM, yyyy').format(anchor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CalendarUiTheme.pageBackground,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _searchField(),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left),
                color: CalendarUiTheme.textMuted,
              ),
              Text(
                _dateLabel(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CalendarUiTheme.textDark,
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
                color: CalendarUiTheme.textMuted,
              ),
            ],
          ),
          const SizedBox(width: 16),
          _viewPills(),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onRemindersTap,
                icon: const Icon(Icons.notifications_outlined),
                color: CalendarUiTheme.textMuted,
              ),
              if (reminderCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: CalendarUiTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onNewEvent,
            style: FilledButton.styleFrom(
              backgroundColor: CalendarUiTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Create Event',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSearch,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CalendarUiTheme.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: Colors.grey.shade400),
              const SizedBox(width: 10),
              Text(
                'Search events…',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewPills() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CalendarUiTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(CalendarView.day, 'Daily'),
          _pill(CalendarView.week, 'Weekly'),
          _pill(CalendarView.month, 'Monthly'),
        ],
      ),
    );
  }

  Widget _pill(CalendarView view, String label) {
    final active = calState.view == view ||
        (view == CalendarView.day && calState.view == CalendarView.agenda);
    return Material(
      color: active ? CalendarUiTheme.primaryLight : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onViewChanged(view),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? CalendarUiTheme.primary : CalendarUiTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
