import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_app/event_management/features/domain/entities/event_entity.dart';
import '../widgets/event_chip.dart';

class CalendarViewMobile extends StatefulWidget {
  final List<EventEntity> events;
  final CalendarFormat format;
  final DateTime focusedDay;
  final void Function(DateTime) onDayTapped;
  final void Function(EventEntity) onEventTapped;
  final void Function(DateTime) onPageChanged;

  const CalendarViewMobile({
    super.key,
    required this.events,
    required this.format,
    required this.focusedDay,
    required this.onDayTapped,
    required this.onEventTapped,
    required this.onPageChanged,
  });

  @override
  State<CalendarViewMobile> createState() => _CalendarViewMobileState();
}

class _CalendarViewMobileState extends State<CalendarViewMobile> {
  Timer? _timer;
  final double _hourHeight = 75.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: widget.format == CalendarFormat.twoWeeks
          ? _buildHourlyView()
          : _buildGridView(),
    );
  }

  // ── GRID VIEW ──────────────────────────────────────────────────────────────
  Widget _buildGridView() {
    return Expanded(
      child: TableCalendar<EventEntity>(
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: widget.focusedDay,
        calendarFormat: widget.format,
        headerVisible: false,
        rowHeight: 120,
        daysOfWeekHeight: 40,
        onPageChanged: widget.onPageChanged,
        eventLoader: (day) {
          return widget.events.where((e) {
            return e.start.year == day.year &&
                e.start.month == day.month &&
                e.start.day == day.day;
          }).toList();
        },
        calendarStyle: _calendarStyle(),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, Colors.black87),
          outsideBuilder: (context, day, focusedDay) => _buildDayCell(day, Colors.grey[400]!),
          todayBuilder: (context, day, focusedDay) => _buildSelectedDayCell(day, const Color(0xFF00796B)),
          selectedBuilder: (context, day, focusedDay) => _buildSelectedDayCell(day, Colors.black),
          markerBuilder: (context, date, events) => _buildEventMarkers(events),
        ),
        onDaySelected: (selected, focused) => widget.onDayTapped(selected),
      ),
    );
  }

  // ── HOURLY VIEW ────────────────────────────────────────────────────────────
  Widget _buildHourlyView() {
    final dayEvents = widget.events.where((e) => isSameDay(e.start, widget.focusedDay)).toList();
    return Expanded(
      child: SingleChildScrollView(
        child: SizedBox(
          height: 24 * _hourHeight,
          child: Row(
            children: [
              _timeGutter(),
              Expanded(
                child: Stack(
                  children: [
                    _gridBackground(),
                    ...dayEvents.map((ev) => _positionEventInTimeline(ev)),
                    _currentTimeLine(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── EVENT DETAILS MODAL ────────────────────────────────────────────────────
  void _showEventDetails(EventEntity event) {
    final eventColor = _parseColor(event.color);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailSheet(event: event, eventColor: eventColor),
    );
  }

  // ── HELPER UI BUILDERS (THE STRUCTURE) ─────────────────────────────────────

  CalendarStyle _calendarStyle() => CalendarStyle(
    outsideDaysVisible: true,
    tableBorder: TableBorder.all(color: Colors.grey[200]!, width: 0.5),
    cellMargin: EdgeInsets.zero,
    cellPadding: EdgeInsets.zero,
  );

  Widget _buildDayCell(DateTime day, Color textColor) => Container(
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 8),
    child: Text("${day.day}", style: TextStyle(color: textColor, fontSize: 14)),
  );

  Widget _buildSelectedDayCell(DateTime day, Color bgColor) => Container(
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 4),
    child: CircleAvatar(
      radius: 14,
      backgroundColor: bgColor,
      child: Text("${day.day}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildEventMarkers(List<EventEntity> events) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 38),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: events.take(3).map((event) => _eventStrip(event)).toList(),
      ),
    );
  }

  Widget _eventStrip(EventEntity event) => GestureDetector(
    onTap: () => _showEventDetails(event),
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _parseColor(event.color).withOpacity(0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        event.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _positionEventInTimeline(EventEntity ev) {
    final top = (ev.start.hour * _hourHeight) + ((ev.start.minute / 60) * _hourHeight);
    final h = (ev.end.difference(ev.start).inMinutes / 60) * _hourHeight;
    return Positioned(
      top: top + 2, left: 4, right: 8, height: h - 4,
      child: GestureDetector(
        onTap: () => _showEventDetails(ev),
        child: EventChip(event: ev, onTap: () => _showEventDetails(ev)),
      ),
    );
  }

  Widget _timeGutter() => SizedBox(width: 60, child: Column(children: List.generate(24, (i) => SizedBox(height: _hourHeight, child: Center(child: Text(_formatHour(i), style: const TextStyle(fontSize: 10, color: Colors.grey)))))));
  Widget _gridBackground() => Column(children: List.generate(24, (i) => Container(height: _hourHeight, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!), left: BorderSide(color: Colors.grey[200]!))))));
  Widget _currentTimeLine() {
    final now = DateTime.now();
    if (!isSameDay(now, widget.focusedDay)) return const SizedBox.shrink();
    return Positioned(top: (now.hour * _hourHeight) + (now.minute / 60 * _hourHeight), left: 0, right: 0, child: Container(height: 2, color: Colors.red));
  }

  // ── UTILITIES ──────────────────────────────────────────────────────────────
  Color _parseColor(String hex) {
    try { return Color(int.parse(hex.replaceAll('#', '0xFF'))); }
    catch (e) { return const Color(0xFF039BE5); }
  }

  String _formatHour(int i) => i == 0 ? "12 AM" : i > 12 ? "${i - 12} PM" : "$i ${i == 12 ? 'PM' : 'AM'}";
}

// ── EXTRACTED COMPONENT: EVENT DETAIL SHEET ──────────────────────────────────
class _EventDetailSheet extends StatelessWidget {
  final EventEntity event;
  final Color eventColor;
  const _EventDetailSheet({required this.event, required this.eventColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          _buildHeader(context),
          Text(event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _row(Icons.access_time_rounded, "${DateFormat('EEEE, MMM dd').format(event.start)} • ${DateFormat('hh:mm a').format(event.start)}"),
          const Divider(height: 32),
          _buildParticipants(),
          const SizedBox(height: 20),
          const Text("DESCRIPTION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
          const SizedBox(height: 8),
          Text(event.description.isEmpty ? "No description." : event.description, style: const TextStyle(fontSize: 15, height: 1.4)),
          if (event.meetingLink.isNotEmpty) _joinButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Row(children: [
    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: eventColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(event.eventType.toUpperCase(), style: TextStyle(color: eventColor, fontWeight: FontWeight.w800, fontSize: 10))),
    const Spacer(),
    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
  ]);

  Widget _buildParticipants() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("ATTENDEES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
      const SizedBox(height: 12),
      if (event.participants?.isNotEmpty ?? false)
        ...event.participants!.map((p) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundColor: eventColor.withOpacity(0.1), child: Text(p.name[0], style: TextStyle(color: eventColor))),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(p.email),
          trailing: const Icon(Icons.check_circle, color: Colors.green, size: 18),
        ))
      else
        const Text("No attendees", style: TextStyle(color: Colors.grey)),
    ],
  );

  Widget _joinButton() => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: ElevatedButton.icon(
      onPressed: () => launchUrl(Uri.parse(event.meetingLink)),
      style: ElevatedButton.styleFrom(backgroundColor: eventColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
      icon: const Icon(Icons.videocam),
      label: const Text("Join Video Call"),
    ),
  );

  Widget _row(IconData icon, String text) => Row(children: [Icon(icon, size: 18, color: Colors.grey[600]), const SizedBox(width: 10), Text(text, style: const TextStyle(fontSize: 15))]);
}