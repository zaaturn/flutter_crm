import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/calendar/presentation/screen/calender_screen.dart';
import 'package:my_app/event_management/features/calendar/shared/calendar_ui_theme.dart';
import 'package:my_app/event_management/features/dashboard/presentation/screens/dashboard_screen.dart';

/// Desktop event management — dashboard + calendar rail.
class EventManagementDesktopShell extends StatefulWidget {
  const EventManagementDesktopShell({super.key});

  @override
  State<EventManagementDesktopShell> createState() =>
      _EventManagementDesktopShellState();
}

class _EventManagementDesktopShellState extends State<EventManagementDesktopShell> {
  int _sectionIndex = 0;

  void _selectSection(int index) {
    if (index == 1 && _sectionIndex != 1) {
      _focusCalendarOnToday();
    }
    setState(() => _sectionIndex = index);
  }

  void _focusCalendarOnToday() {
    final today = DateTime.now();
    try {
      final cal = context.read<CalendarBloc>();
      cal.add(MonthChanged(DateTime(today.year, today.month, 1)));
      cal.add(DateSelected(today));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const navItems = <({IconData icon, String tooltip})>[
      (icon: Icons.dashboard_outlined, tooltip: 'Dashboard'),
      (icon: Icons.calendar_month_outlined, tooltip: 'Calendar'),
    ];
    final sections = <Widget>[
      const SizedBox.expand(child: DashboardScreen()),
      const SizedBox.expand(child: CalendarScreen()),
    ];

    return Scaffold(
      backgroundColor: CalendarUiTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNavRail(navItems),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: CalendarUiTheme.pageBackground,
                    child: IndexedStack(
                      index: _sectionIndex,
                      children: sections,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavRail(
    List<({IconData icon, String tooltip})> navItems,
  ) {
    return Container(
      width: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CalendarUiTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Tooltip(
            message: 'Back',
            child: _railIconButton(
              icon: Icons.arrow_back,
              selected: false,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(navItems.length, (index) {
            final item = navItems[index];
            final selected = _sectionIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tooltip(
                message: item.tooltip,
                waitDuration: const Duration(milliseconds: 400),
                child: _railIconButton(
                  icon: item.icon,
                  selected: selected,
                  onTap: () => _selectSection(index),
                ),
              ),
            );
          }),
          const Spacer(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _railIconButton({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? CalendarUiTheme.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(
                    color: CalendarUiTheme.primary.withValues(alpha: 0.25),
                  )
                : null,
          ),
          child: Icon(
            icon,
            size: 22,
            color: selected
                ? CalendarUiTheme.primary
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
