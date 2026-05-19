import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/event_management/features/calendar/presentation/widget/day_view.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/month_view.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/week_view.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_state.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_create_screen.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/quick_add_sheet.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/notification_screen.dart';
import 'package:my_app/event_management/shared/themes/event_adaptive_theme.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';
import 'package:my_app/services/api_client.dart' as app_api;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  // Subtle animation controller for view toggle
  late final AnimationController _toggleAnim;

  @override
  void initState() {
    super.initState();
    _toggleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadMonthEvents();
    });
  }

  @override
  void dispose() {
    _toggleAnim.dispose();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────────

  void _loadMonthEvents() {
    final now = DateTime.now();
    context.read<EventBloc>().add(FetchEventsRequested(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
    ));
  }

  void _loadEventsForMonth(DateTime month) {
    context.read<EventBloc>().add(FetchEventsRequested(
      startDate: DateTime(month.year, month.month, 1),
      endDate: DateTime(month.year, month.month + 1, 0),
    ));
  }

  Future<void> _refreshTokenIfNeeded() async {
    try {
      await app_api.ApiClient().refreshSession();
    } catch (_) {}
  }

  void _shiftMonth(int delta) {
    final m = context.read<CalendarBloc>().state.focusedMonth;
    final next = DateTime(m.year, m.month + delta, 1);
    context.read<CalendarBloc>().add(MonthChanged(next));
  }

  bool _isWide(BuildContext context) => AdaptiveLayout.isWide(context);

  void _openNotifications(BuildContext context) {
    try {
      final bloc = context.read<NotificationBloc>();
      bloc.add(NotificationLoadRequested());
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const NotificationScreen(),
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications unavailable')),
      );
    }
  }

  void _openNewEvent() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const EventCreateScreen(),
      ),
    );
  }

  // ── Day tap ───────────────────────────────────────────────────────────────

  void _onDayTapped(BuildContext context, DateTime date) {
    context.read<CalendarBloc>().add(DateSelected(date));
    context.read<EventBloc>().add(FetchEventsRequested(
      startDate: date,
      endDate: date,
    ));
    // Show quick-add sheet on day tap (matches square-box UX)
    QuickAddSheet.show(context, date);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);
    return Scaffold(
      backgroundColor: EventAdaptiveTheme.bg(context),
      body: BlocListener<CalendarBloc, CalendarState>(
        listenWhen: (prev, curr) =>
            prev.focusedMonth.month != curr.focusedMonth.month ||
            prev.focusedMonth.year != curr.focusedMonth.year,
        listener: (_, state) => _loadEventsForMonth(state.focusedMonth),
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (ctx, calState) {
            return BlocBuilder<EventBloc, EventState>(
              builder: (ctx2, eventState) {
                final List<Event> events = eventState is EventsLoaded
                    ? eventState.events
                    : <Event>[];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPageHeader(ctx, wide),
                    _buildMonthToolbar(ctx, calState, wide),
                    const _HairlineDivider(),
                    Expanded(
                      child: RefreshIndicator(
                        color: EventAdaptiveTheme.primary(ctx),
                        onRefresh: () async {
                          await _refreshTokenIfNeeded();
                          _loadEventsForMonth(calState.focusedMonth);
                        },
                        child: _buildBody(ctx, calState, events),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: wide ? null : _buildFAB(),
    );
  }

  Widget _buildPageHeader(BuildContext context, bool wide) {
    final compact = MediaQuery.sizeOf(context).width < 420;
    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 28 : 16, wide ? 20 : 16, wide ? 28 : 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Calendar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: EventAdaptiveTheme.text(context),
                    fontSize: wide ? 28 : 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Material(
                color: EventAdaptiveTheme.header(context),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => _openNotifications(context),
                  borderRadius: BorderRadius.circular(10),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF374151),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _openNewEvent,
              icon: Icon(Icons.add, size: 18, color: EventAdaptiveTheme.text(context)),
              label: Text(
                compact ? 'New' : 'New event',
                style: TextStyle(
                  color: EventAdaptiveTheme.text(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: EventAdaptiveTheme.text(context),
                side: BorderSide(color: EventAdaptiveTheme.border(context), width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthToolbar(
    BuildContext context,
    CalendarState calState,
    bool wide,
  ) {
    final monthLabel = DateFormat('MMMM yyyy').format(calState.focusedMonth);
    final monthNav = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChromeIconBtn(
          icon: Icons.chevron_left_rounded,
          tooltip: 'Previous month',
          onTap: () => _shiftMonth(-1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            monthLabel,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        _ChromeIconBtn(
          icon: Icons.chevron_right_rounded,
          tooltip: 'Next month',
          onTap: () => _shiftMonth(1),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            final now = DateTime.now();
            context.read<CalendarBloc>().add(DateSelected(now));
            context.read<CalendarBloc>().add(MonthChanged(now));
            _loadMonthEvents();
          },
          style: TextButton.styleFrom(
            foregroundColor: EventAdaptiveTheme.primary(context),
          ),
          child: const Text('Today'),
        ),
        IconButton(
          tooltip: 'Search events',
          onPressed: () => _showSearch(context),
          icon: const Icon(Icons.search_rounded, size: 22, color: Color(0xFF374151)),
        ),
      ],
    );

    final toggle = _buildViewToggle(context, calState);

    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 4, wide ? 28 : 16, 12),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                monthNav,
                const Spacer(),
                SizedBox(width: 280, child: toggle),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                monthNav,
                const SizedBox(height: 12),
                toggle,
              ],
            ),
    );
  }

  Widget _buildViewToggle(BuildContext context, CalendarState state) {
    final primary = EventAdaptiveTheme.primary(context);
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: CalendarView.values.map((view) {
          final isActive = state.view == view;
          return Expanded(
            child: Material(
              color: isActive ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () =>
                    context.read<CalendarBloc>().add(ViewChanged(view)),
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Text(
                    _viewLabel(view),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _viewLabel(CalendarView view) {
    switch (view) {
      case CalendarView.month: return 'Month';
      case CalendarView.week:  return 'Week';
      case CalendarView.day:   return 'Day';
    }
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(
      BuildContext context,
      CalendarState calState,
      List<Event> events,
      ) {
    switch (calState.view) {
      case CalendarView.month:
        return MonthView(
          calState: calState,
          events: events,
          rootContext: context,
          onDaySelected: (date) => _onDayTapped(context, date),
          onMonthChanged: (month) {
            context.read<CalendarBloc>().add(MonthChanged(month));
          },
        );

      case CalendarView.week:
        return WeekView(
          selectedDate: calState.selectedDate ?? DateTime.now(),
          events: events,
          onDayTapped: (date) => _onDayTapped(context, date),
        );

      case CalendarView.day:
        return DayView(
          selectedDate: calState.selectedDate ?? DateTime.now(),
          events: events,
          onSlotTapped: (date) => _onDayTapped(context, date),
        );
    }
  }

  // ── FAB ───────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      heroTag: 'calendar_new_event_fab',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EventCreateScreen()),
      ),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: const Icon(Icons.add, size: 18),
      label: const Text(
        'New event',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _EventSearchDelegate(
        events: context.read<EventBloc>().state is EventsLoaded
            ? (context.read<EventBloc>().state as EventsLoaded).events
            : [],
      ),
    );
  }
}

// ── _ChromeIconBtn ────────────────────────────────────────────────────────────

class _ChromeIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ChromeIconBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: const Color(0xFF374151), size: 22),
          ),
        ),
      ),
    );
  }
}

// ── _HairlineDivider ───────────────────────────────────────────────────────────

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: const Color(0xFFD3D1C7),
    );
  }
}

// ── Event Search Delegate ──────────────────────────────────────────────────────

class _EventSearchDelegate extends SearchDelegate<Event?> {
  final List<Event> events;

  _EventSearchDelegate({required this.events});

  @override
  String get searchFieldLabel => 'Search events…';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Color(0xFF888780)),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back, size: 20),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 40, color: Color(0xFFD3D1C7)),
            const SizedBox(height: 12),
            Text(
              'Search by event title',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final results = events
        .where((e) =>
    e.title.toLowerCase().contains(query.toLowerCase()) ||
        (e.description.toLowerCase().contains(query.toLowerCase())) ||
        (e.location?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No events matching "$query"',
          style: const TextStyle(color: Color(0xFF888780), fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) {
        final e = results[i];
        return _SearchResultTile(
          event: e,
          onTap: () => close(ctx, e),
        );
      },
    );
  }
}

// ── Search result tile ─────────────────────────────────────────────────────────

class _SearchResultTile extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _SearchResultTile({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Resolve event color
    Color solidColor;
    try {
      solidColor = Color(
        int.parse('0xFF${event.displayColor.replaceAll('#', '')}'),
      );
    } catch (_) {
      solidColor = const Color(0xFF888780);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: solidColor, width: 3)),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: ListTile(
          dense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          title: Text(
            event.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            DateFormat('EEE, MMM d  ·  h:mm a')
                .format(event.startTime.toLocal()),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888780),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: solidColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              event.type.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: solidColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}