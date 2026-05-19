import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/screen/MOBILE/event_detail_screen_mobile.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_create_screen_mobile.dart';

class EventCalendarMobileScreen extends StatefulWidget {
  const EventCalendarMobileScreen({super.key});

  @override
  State<EventCalendarMobileScreen> createState() => _EventCalendarMobileScreenState();
}

class _EventCalendarMobileScreenState extends State<EventCalendarMobileScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();

  static const Color earthyGreen = Color(0xFF94A664);
  static const Color creamBg = Color(0xFFFAF3E0);
  static const Color beigeCard = Color(0xFFEADBC8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonth(_focused);
      _loadDay(_selected);
    });
  }

  void _loadMonth(DateTime month) {
    context.read<EventBloc>().add(FetchEventsRequested(
      startDate: DateTime(month.year, month.month, 1),
      endDate: DateTime(month.year, month.month + 1, 0),
    ));
  }

  void _loadDay(DateTime day) {
    context.read<EventBloc>().add(FetchEventsRequested(startDate: day, endDate: day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: earthyGreen,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopHeader(),
                _buildCalendarSection(),
                const SizedBox(height: 20),
              ],
            ),
            _buildEventSheet(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'event_calendar_create_fab',
        backgroundColor: const Color(0xFFFFC67A),
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // FIXED: Header now has the Back button and Title next to each other
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMMM yyyy').format(_focused),
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        final events = state is EventsLoaded ? state.events : <Event>[];
        return TableCalendar<Event>(
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: _focused,
          selectedDayPredicate: (d) => isSameDay(d, _selected),
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerVisible: false,
          rowHeight: 45,
          eventLoader: (day) => _eventsForDay(events, day),
          onDaySelected: (selected, focused) {
            setState(() {
              _selected = selected;
              _focused = focused;
            });
            _loadDay(selected);
          },
          onPageChanged: (focused) {
            setState(() {
              _focused = focused;
            });
            _loadMonth(focused);
          },
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: true,
            outsideTextStyle: TextStyle(color: Colors.white24),
            defaultTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            weekendTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            selectedDecoration: BoxDecoration(color: Color(0x44000000), shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            markerDecoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            markersMaxCount: 1,
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
            weekendStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildEventSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: creamBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: BlocBuilder<EventBloc, EventState>(
            builder: (context, state) {
              final events = state is EventsLoaded ? state.events : <Event>[];
              final dayEvents = _eventsForDay(events, _selected);

              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(30),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isSameDay(_selected, DateTime.now()) ? "Today" : DateFormat('EEEE, d MMM').format(_selected),
                    style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFF3E2723)),
                  ),
                  const SizedBox(height: 24),
                  if (state is EventLoading)
                    const Center(child: CircularProgressIndicator(color: earthyGreen))
                  else if (dayEvents.isEmpty)
                    _buildEmptyState()
                  else
                    ...dayEvents.map((e) => _buildTimelineTile(e)),
                  const SizedBox(height: 100),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ADDED NAVIGATION: Clicking the event now moves to EventDetailMobileScreen
  Widget _buildTimelineTile(Event event) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventDetailMobileScreen(eventId: event.id),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: beigeCard,
                    border: Border.all(color: earthyGreen, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 12, color: earthyGreen),
                ),
                Container(width: 2, height: 50, color: beigeCard),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A1A)),
                  ),
                  Text(
                    "${DateFormat('hh:mm a').format(event.startTime.toLocal())} - ${DateFormat('hh:mm a').format(event.endTime.toLocal())}",
                    style: GoogleFonts.manrope(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            _buildStatusChip(event),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Event event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "View",
        style: GoogleFonts.manrope(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text("No events for this day", style: GoogleFonts.manrope(color: Colors.black26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Event> _eventsForDay(List<Event> events, DateTime day) {
    final matches = events.where((e) => isSameDay(e.startTime.toLocal(), day)).toList();
    matches.sort((a, b) => a.startTime.toLocal().compareTo(b.startTime.toLocal()));
    return matches;
  }

  void _openCreate(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EventCreateScreenMobile(prefillDate: _selected),
    ));
  }
}