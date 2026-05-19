import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';

import 'package:my_app/event_management/features/calendar/presentation/screen/mobile_screen/event_calendar_mobile_screen.dart';
import 'package:my_app/event_management/features/calendar/presentation/screen/calender_screen.dart';
import 'package:my_app/event_management/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:my_app/event_management/features/dashboard/presentation/screens/mobile/event_dashboard_mobile_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/events_list_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_list_screen_mobile.dart';
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
    setState(() => _sectionIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final mobileUi = AdaptiveLayout.useMobileUi(context);
    if (!mobileUi) {
      return _buildDesktopShell();
    }

    final sections = <Widget>[
      const EventDashboardMobileScreen(),
      const EventCalendarMobileScreen(),
      const SafeArea(child: EventsListScreenMobile()),
    ];

    return Scaffold(
      backgroundColor: ZaaturnUI.background,
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
    const navItems = <({IconData icon, String label})>[
      (icon: Icons.dashboard_outlined, label: 'Dashboard'),
      (icon: Icons.calendar_month_outlined, label: 'Calendar'),
      (icon: Icons.event_note_outlined, label: 'Events'),
    ];
    final sections = <Widget>[
      const DashboardScreen(),
      const CalendarScreen(),
      const SafeArea(child: EventsListScreen()),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Row(
        children: [
          Container(
            width: 250,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A), // Dark sidebar
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ── Back Button ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Events',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Navigation Items ────────────────────────────────
                  ...List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final selected = _sectionIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        selected: selected,
                        // Subtle highlight for selected item
                        selectedTileColor: Colors.white.withOpacity(0.08),
                        leading: Icon(
                          item.icon,
                          size: 20,
                          color: selected ? Colors.white : Colors.white54,
                        ),
                        title: Text(
                          item.label,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? Colors.white : Colors.white54,
                          ),
                        ),
                        onTap: () => _selectSection(index),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _sectionIndex,
              children: sections,
            ),
          ),
        ],
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
            _navItem(1, Icons.calendar_today_rounded, "CALENDER"),
            _navItem(2, Icons.chat_bubble_outline_rounded, "EVENT"),

          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final bool isSelected = _sectionIndex == (index > 2 ? 0 : index);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index < 3) _selectSection(index);
      },
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