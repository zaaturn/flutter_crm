import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';

import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/calendar/presentation/screen/calender_screen.dart';
import 'package:my_app/event_management/features/calendar/shared/calendar_ui_theme.dart';
import 'package:my_app/event_management/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:my_app/event_management/features/dashboard/presentation/screens/mobile/event_dashboard_mobile_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_create_screen_mobile.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0);
  static const Color navBackground = Color(0xFFD6E4EF); // Light blue from image
  static const Color activeHighlight = Color(0xFFEAF1F8); // Capsule highlight
  static const Color textDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF0D6EFD); // FAB Blue
}

class EventManagementShell extends StatefulWidget {
  const EventManagementShell({super.key});

  @override
  State<EventManagementShell> createState() => _EventManagementShellState();
}

class _EventManagementShellState extends State<EventManagementShell> {
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
    final mobileUi = AdaptiveLayout.useMobileUi(context);
    if (!mobileUi) {
      return _buildDesktopShell();
    }

    final sections = <Widget>[
      const SizedBox.expand(child: EventDashboardMobileScreen()),
      const SizedBox.expand(child: SafeArea(child: CalendarScreen())),
    ];

    return Scaffold(
      backgroundColor: CalendarUiTheme.pageBackground,
      body: IndexedStack(
        index: _sectionIndex,
        children: sections,
      ),
      floatingActionButton: _sectionIndex == 0
          ? Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EventCreateScreenMobile()),
          ),
          backgroundColor: ZaaturnUI.primaryBlue,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Create Event',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      )
          : null,
      bottomNavigationBar: _buildFlushBottomNav(),
    );
  }

  Widget _buildDesktopShell() {
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

  /// Narrow icon-only rail (reference: slim white nav with symbols only).
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

  Widget _buildFlushBottomNav() {
    return Container(
      height: 95 + MediaQuery.of(context).padding.bottom,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ZaaturnUI.navBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.grid_view_rounded, "DASHBOARD"),
            _navItem(1, Icons.calendar_today_rounded, "CALENDAR"),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final bool isSelected = _sectionIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectSection(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? ZaaturnUI.activeHighlight : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 26,
              color: ZaaturnUI.textDark.withOpacity(isSelected ? 1.0 : 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: ZaaturnUI.textDark.withOpacity(isSelected ? 1.0 : 0.7),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}