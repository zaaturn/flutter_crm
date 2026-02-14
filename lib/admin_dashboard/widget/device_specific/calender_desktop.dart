import 'dart:async'; // Added for short-polling timer
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_app/admin_dashboard/model/events.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({super.key});

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends State<DashboardCalendar> {
  final AdminRepository _repository = AdminRepository();

  // Polling State
  Timer? _pollingTimer;
  bool _isSyncing = false; // For the subtle "Live" indicator

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DashboardEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Initial data fetch
    _loadEvents();

    // Initialize short-polling every 20 seconds
    _startPolling();
  }

  @override
  void dispose() {
    // IMPORTANT: Cancel timer to prevent memory leaks and unnecessary API hits
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _loadEvents(isPolling: true);
    });
  }

  Future<void> _loadEvents({bool isPolling = false}) async {
    if (!mounted) return;

    setState(() {
      if (isPolling) {
        _isSyncing = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final data = await _repository.fetchEvents();
      if (mounted) {
        setState(() {
          _events = data;
          _isLoading = false;
          _isSyncing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSyncing = false;
        });
      }
    }
  }

  List<DashboardEvent> _getEventsForDay(DateTime day) {
    // Strict comparison ensures event on 5th doesn't show on 12th
    return _events.where((e) => isSameDay(e.start, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF0D3199),
        ),
      );
    }

    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildCalendarHeader(), // New: Header with "Live" indicator
          _buildCalendar(),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEDF2F7)),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selectedEvents.isNotEmpty
                    ? _buildAgenda(selectedEvents)
                    : _buildEmptyState(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SaaS header with a status indicator for the polling
  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: _isSyncing ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: Row(
              children: [
                Icon(
                  Icons.sync,
                  size: 12,
                  color: _isSyncing ? const Color(0xFF0D3199) : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _isSyncing ? "Syncing..." : "Live",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _isSyncing ? const Color(0xFF0D3199) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<DashboardEvent>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: _getEventsForDay,
      rowHeight: 52,
      daysOfWeekHeight: 32,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: false,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF64748B), size: 20),
        rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
        headerPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 12),
        weekendStyle: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 12),
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        markerDecoration: BoxDecoration(color: Color(0xFF0D3199), shape: BoxShape.circle),
        todayDecoration: BoxDecoration(
          color: Color(0xFFE2E8F0),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(color: Color(0xFF0D3199), fontWeight: FontWeight.bold),
        selectedDecoration: BoxDecoration(
          color: Color(0xFF0D3199),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildAgenda(List<DashboardEvent> events) {
    return ListView(
      key: ValueKey("agenda_${_selectedDay.toString()}"),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text(
              "Schedule",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey[800],
                  letterSpacing: 0.5),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3199).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${events.length} Events",
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3199)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...events.map(_buildEventTile).toList(),
      ],
    );
  }

  Widget _buildEventTile(DashboardEvent e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF0D3199),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF1E293B))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 6),
                              Text(
                                "${e.start.hour.toString().padLeft(2, '0')}:${e.start.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_vert,
                        color: Color(0xFFCBD5E1), size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey("empty"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 48, color: Colors.blueGrey[100]),
          const SizedBox(height: 16),
          const Text(
            "No events today",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          const Text(
            "You're all caught up!",
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}