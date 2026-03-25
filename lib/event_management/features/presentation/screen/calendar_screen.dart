import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../widgets/calendar_view.dart';
import '../widgets/event_details_modal.dart' hide EventTypeColor;
import '../widgets/event_modal.dart';

import '../../calendar/data/repositories/event_repository_impl.dart';
import '../../calendar/data/datasources/event_remote_datasource_impl.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/update_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/get_events.dart';

class CalendarScreenMobile extends StatefulWidget {
  final int? focusEventId;
  const CalendarScreenMobile({super.key, this.focusEventId});

  @override
  State<CalendarScreenMobile> createState() => _CalendarScreenMobileState();
}

class _CalendarScreenMobileState extends State<CalendarScreenMobile> {
  // Remote source kept at state level to persist across rebuilds
  final EventRemoteDatasourceImpl _dataSource = EventRemoteDatasourceImpl();

  @override
  Widget build(BuildContext context) {
    final repo = EventRepositoryImpl(_dataSource);

    return BlocProvider(
      create: (_) => EventBloc(
        createEvent: CreateEvent(repo),
        updateEvent: UpdateEvent(repo),
        deleteEvent: DeleteEvent(repo),
        getEvents: GetEvents(repo),
      )..add(FetchEventsRequested(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now().add(const Duration(days: 30)),
      )),
      child: _CalendarScaffold(dataSource: _dataSource),
    );
  }
}

class _CalendarScaffold extends StatelessWidget {
  final EventRemoteDatasourceImpl dataSource;
  const _CalendarScaffold({required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _CalendarHeader(),
          Expanded(child: _CalendarBody(dataSource: dataSource)),
        ],
      ),
      floatingActionButton: const _CalendarFAB(),
    );
  }
}

// ── HEADER MODULE ────────────────────────────────────────────────────────────
class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 8, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  _navBackButton(context),
                  const _BrandLogo(),
                  const SizedBox(width: 16),
                  _headerTitle(state.focusedDay),
                  _todayButton(context),
                ],
              ),
              const SizedBox(height: 20),
              _ViewFilters(currentFormat: state.calendarFormat),
            ],
          );
        },
      ),
    );
  }

  Widget _navBackButton(BuildContext context) => IconButton(
    onPressed: () => Navigator.canPop(context)
        ? Navigator.pop(context)
        : Navigator.pushReplacementNamed(context, '/employeeDashboard'),
    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A202C), size: 20),
  );

  Widget _headerTitle(DateTime focusedDay) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Calendar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A202C))),
        Text(DateFormat('MMMM yyyy').format(focusedDay), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    ),
  );

  Widget _todayButton(BuildContext context) => Container(
    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
    child: IconButton(
      onPressed: () => context.read<EventBloc>().add(NavigateCalendar(DateTime.now())),
      icon: const Icon(Icons.today_rounded, color: Color(0xFF6366F1), size: 22),
    ),
  );
}

// ── BODY MODULE ──────────────────────────────────────────────────────────────
class _CalendarBody extends StatelessWidget {
  final EventRemoteDatasourceImpl dataSource;
  const _CalendarBody({required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EventBloc, EventState>(
          listenWhen: (p, c) => c is EventActionSuccess || c is EventError,
          listener: (ctx, state) {
            if (state is EventActionSuccess) _showSnack(ctx, state.message, const Color(0xFF10B981));
            if (state is EventError) _showSnack(ctx, state.message, const Color(0xFFEF4444));
          },
        ),
        BlocListener<EventBloc, EventState>(
          listener: (ctx, state) {
            if (state is CreateModalOpen) _showCreateModal(ctx, state.selectedDateTime);
            if (state is DetailModalOpen) _showDetailModal(ctx, state.selectedEvent);
          },
        ),
      ],
      child: BlocBuilder<EventBloc, EventState>(
        builder: (ctx, state) {
          if (state is EventLoading && state.events.isEmpty) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)));
          }
          return CalendarViewMobile(
            events: state.events,
            format: state.calendarFormat,
            focusedDay: state.focusedDay,
            onDayTapped: (dt) => ctx.read<EventBloc>().add(SlotTapped(dt)),
            onEventTapped: (ev) => ctx.read<EventBloc>().add(EventTapped(ev)),
            onPageChanged: (focusedDay) => ctx.read<EventBloc>().add(NavigateCalendar(focusedDay)),
          );
        },
      ),
    );
  }

  void _showCreateModal(BuildContext ctx, DateTime? dt) async {
    await dataSource.ensureUsersLoaded();
    if (!ctx.mounted) return;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventModal(
        selectedDateTime: dt,
        usersById: dataSource.usersById,
        onSave: (entity) => ctx.read<EventBloc>().add(CreateEventRequested(entity)),
      ),
    ).then((_) {
      if (ctx.mounted) ctx.read<EventBloc>().add(ModalDismissed());
    });
  }

  void _showDetailModal(BuildContext ctx, dynamic event) async {
    await dataSource.ensureUsersLoaded();
    if (!ctx.mounted) return;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventDetailsModal(
        event: event,
        usersById: dataSource.usersById,
        onEdit: (ev) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _showCreateModal(ctx, ev.start);
          });
        },
        onDelete: (id) => ctx.read<EventBloc>().add(DeleteEventRequested(id.toString())),
      ),
    ).then((_) {
      if (ctx.mounted) ctx.read<EventBloc>().add(ModalDismissed());
    });
  }

  void _showSnack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}

// ── SUB-COMPONENTS ───────────────────────────────────────────────────────────

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();
  @override
  Widget build(BuildContext context) => Container(
    height: 40, width: 40,
    decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(12)),
    child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
  );
}

class _ViewFilters extends StatelessWidget {
  final CalendarFormat currentFormat;
  const _ViewFilters({required this.currentFormat});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42, padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _filterBtn(context, "Month", CalendarFormat.month),
          _filterBtn(context, "Week", CalendarFormat.week),
          _filterBtn(context, "Day", CalendarFormat.twoWeeks),
        ],
      ),
    );
  }

  Widget _filterBtn(BuildContext context, String label, CalendarFormat target) {
    final bool isSelected = target == currentFormat;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<EventBloc>().add(ChangeCalendarFormat(target)),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B)
            )),
          ),
        ),
      ),
    );
  }
}

class _CalendarFAB extends StatelessWidget {
  const _CalendarFAB();
  @override
  Widget build(BuildContext context) => FloatingActionButton(
    backgroundColor: const Color(0xFF6366F1),
    onPressed: () => context.read<EventBloc>().add(SlotTapped(DateTime.now())),
    child: const Icon(Icons.add, color: Colors.white),
  );
}