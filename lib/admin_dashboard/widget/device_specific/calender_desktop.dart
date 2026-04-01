import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Ensure these paths match your project structure
import 'package:my_app/event_management/features/events/data/datasources/event_remote_datasource.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/services/api_client.dart';

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({super.key});

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends State<DashboardCalendar> with WidgetsBindingObserver {
  late final EventRemoteDataSource _events = EventRemoteDataSourceImpl(ApiClient().dio);

  // --- Premium SaaS Purple Palette ---
  static const Color _primaryPurple = Color(0xFF7C3AED);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textMain = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _successGreen = Color(0xFF10B981);

  Timer? _pollingTimer;
  bool _isSyncing = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Event> _eventsMonth = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedDay = DateTime.now();
    _loadEvents();
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (!ApiClient().isAuthenticated) {
        _pollingTimer?.cancel();
        return;
      }
      await _loadEvents(isPolling: true);
    });
  }

  Future<void> _loadEvents({bool isPolling = false}) async {
    if (!mounted || !ApiClient().isAuthenticated) return;
    setState(() => isPolling ? _isSyncing = true : _isLoading = true);

    try {
      final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      final data = await _events.getEventsInRange(startDate: start, endDate: end);

      if (!mounted) return;
      setState(() {
        _eventsMonth = List<Event>.from(data);
        _isLoading = false;
        _isSyncing = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = _isSyncing = false);
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _eventsMonth.where((e) => isSameDay(e.startTime.toLocal(), day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(strokeWidth: 3, color: _primaryPurple)),
      );
    }

    final selectedDate = _selectedDay ?? DateTime.now();
    final todayEvents = _getEventsForDay(selectedDate);

    // Filter for events occurring after the current selected day
    final upcomingEvents = _eventsMonth.where((e) {
      final eventDate = e.startTime.toLocal();
      final endOfCurrentDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
      return eventDate.isAfter(endOfCurrentDay);
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. CALENDAR SECTION
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                border: Border(bottom: BorderSide(color: _primaryPurple.withOpacity(0.05))),
              ),
              child: Column(
                children: [
                  _buildSyncIndicator(),
                  _buildCalendar(),
                ],
              ),
            ),
          ),

          // 2. SELECTED DAY EVENTS
          _buildSectionHeader(
            title: isSameDay(selectedDate, DateTime.now()) ? "Today's Schedule" : "Schedule",
            subtitle: DateFormat('EEEE, MMM d').format(selectedDate),
          ),

          todayEvents.isNotEmpty
              ? SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildModernEventCard(todayEvents[index]),
                childCount: todayEvents.length,
              ),
            ),
          )
              : SliverToBoxAdapter(child: _buildEmptyState("No events scheduled for this day")),

          // 3. UPCOMING EVENTS SECTION (Always visible title)
          _buildSectionHeader(
            title: "Upcoming Events",
            subtitle: "Coming up soon",
            showFilter: false,
          ),

          upcomingEvents.isNotEmpty
              ? SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildModernEventCard(upcomingEvents[index], showDate: true),
                childCount: upcomingEvents.length > 5 ? 5 : upcomingEvents.length,
              ),
            ),
          )
              : SliverToBoxAdapter(child: _buildEmptyState("No upcoming events this month")),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle, bool showFilter = true}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _textMain, letterSpacing: -0.5),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: _textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Spacer(),
            if (showFilter) _buildHeaderAction(Icons.tune_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildModernEventCard(Event e, {bool showDate = false}) {
    final eventColor = Color(int.parse('0xFF${e.displayColor.replaceAll('#', '')}'));
    final timeStr = DateFormat.jm().format(e.startTime.toLocal());
    final dateStr = DateFormat('MMM d').format(e.startTime.toLocal());

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailScreen(eventId: e.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(color: _primaryPurple.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                  width: 4,
                  decoration: BoxDecoration(
                      color: eventColor,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20))
                  )
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: eventColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6)
                            ),
                            child: Text(
                              showDate ? "$dateStr • $timeStr" : timeStr,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: eventColor),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 16, color: _textMuted),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textMain),
                      ),
                      if (e.location != null && e.location!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: _textMuted),
                            const SizedBox(width: 4),
                            Expanded(child: Text(e.location!, style: const TextStyle(fontSize: 11, color: _textMuted), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _isSyncing ? _primaryPurple.withOpacity(0.1) : _successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(_isSyncing ? Icons.sync : Icons.check_circle_rounded, size: 10, color: _isSyncing ? _primaryPurple : _successGreen),
                const SizedBox(width: 4),
                Text(_isSyncing ? 'SYNCING' : 'LIVE', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<Event>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: _getEventsForDay,
      rowHeight: 48,
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _loadEvents();
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textMain),
        leftChevronIcon: Icon(Icons.chevron_left_rounded, color: _textMuted),
        rightChevronIcon: Icon(Icons.chevron_right_rounded, color: _textMuted),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: _primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
        todayTextStyle: const TextStyle(color: _primaryPurple, fontWeight: FontWeight.bold),
        selectedDecoration: const BoxDecoration(color: _primaryPurple, shape: BoxShape.circle),
        markerDecoration: const BoxDecoration(color: _primaryPurple, shape: BoxShape.circle),
        markersMaxCount: 1,
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: _textMain, fontSize: 13),
      ),
      onDaySelected: (selectedDay, focusedDay) => setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      }),
    );
  }

  Widget _buildHeaderAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: _bgSoft, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: _textMuted, size: 18),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_note_rounded, size: 28, color: _textMuted.withOpacity(0.2)),
            const SizedBox(height: 8),
            Text(msg, style: TextStyle(color: _textMuted.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}