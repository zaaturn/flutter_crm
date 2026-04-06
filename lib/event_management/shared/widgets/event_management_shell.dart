import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/event_management/features/calendar/presentation/screen/calender_screen.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_create_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/events_list_screen.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

/// Shell: full-height black sidebar + Dashboard / Calendar / Events.
class EventManagementShell extends StatefulWidget {
  const EventManagementShell({super.key});

  @override
  State<EventManagementShell> createState() => _EventManagementShellState();
}

class _EventManagementShellState extends State<EventManagementShell> {
  int _sectionIndex = 0;

  static const double _kSidebarWidth = 240;

  bool _isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 900;

  void _openNewEvent() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const EventCreateScreen(),
      ),
    );
  }

  void _selectSection(int index) {
    setState(() => _sectionIndex = index);
  }

  void _goBackIfPossible() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);
    final content = BlocListener<EventBloc, EventState>(
      listenWhen: (_, s) => s is EventDeleted,
      listener: (ctx, _) {
        try {
          ctx.read<DashboardBloc>().add(DashboardRefreshRequested());
        } catch (_) {}
      },
      child: IndexedStack(
        index: _sectionIndex,
        children: const [
          DashboardScreen(),
          CalendarScreen(),
          EventsListScreen(),
        ],
      ),
    );

    if (wide) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _kSidebarWidth,
              child: Material(
                color: Colors.black,
                child: _EventFlowSidebar(
                  sectionIndex: _sectionIndex,
                  onSelectSection: _selectSection,
                  onBack: _goBackIfPossible,
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: ColoredBox(
                  color: const Color(0xFFF8F9FB),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canPop)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _goBackIfPossible,
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back',
                ),
              ),
            Expanded(child: content),
          ],
        ),
      ),
      floatingActionButton: _sectionIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openNewEvent,
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
              backgroundColor: AppTheme.primaryBlue,
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sectionIndex,
        backgroundColor: Colors.white,
        onDestinationSelected: _selectSection,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}

class _EventFlowSidebar extends StatelessWidget {
  final int sectionIndex;
  final ValueChanged<int> onSelectSection;
  final VoidCallback onBack;

  const _EventFlowSidebar({
    required this.sectionIndex,
    required this.onSelectSection,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    const activeBg = Color(0xFF1A1A1A);
    const textDim = Color(0xFFB0B0B0);

    final canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canPop)
            IconButton(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(bottom: 8),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 22),
              tooltip: 'Back',
            ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Event Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SidebarTile(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Dashboard',
            selected: sectionIndex == 0,
            activeBg: activeBg,
            textDim: textDim,
            onTap: () => onSelectSection(0),
          ),
          const SizedBox(height: 4),
          _SidebarTile(
            icon: Icons.calendar_month_outlined,
            selectedIcon: Icons.calendar_month_rounded,
            label: 'Calendar',
            selected: sectionIndex == 1,
            activeBg: activeBg,
            textDim: textDim,
            onTap: () => onSelectSection(1),
          ),
          const SizedBox(height: 4),
          _SidebarTile(
            icon: Icons.event_note_outlined,
            selectedIcon: Icons.event_note_rounded,
            label: 'Events',
            selected: sectionIndex == 2,
            activeBg: activeBg,
            textDim: textDim,
            onTap: () => onSelectSection(2),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final Color activeBg;
  final Color textDim;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.activeBg,
    required this.textDim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppTheme.primaryBlue : textDim;
    return Material(
      color: selected ? activeBg : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.white.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 22,
                color: fg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : textDim,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
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
