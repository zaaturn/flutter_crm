import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// App Constants
import 'package:my_app/event_management/core/constants/app_colors.dart';

// Bloc Imports
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

// Mobile Specific Widgets
import '../widgets/calendar_view.dart';
import '../widgets/event_details_modal.dart' hide EventTypeColor;
import '../widgets/event_modal.dart';

// Domain/Data Layers
import '../../calendar/data/repositories/event_repository_impl.dart';
import '../../calendar/data/datasources/event_remote_datasource_impl.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/update_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/get_events.dart';

class CalendarScreenMobile extends StatefulWidget {
  final int? focusEventId;

  const CalendarScreenMobile({
    super.key,
    this.focusEventId,
  });

  @override
  State<CalendarScreenMobile> createState() => _CalendarScreenMobileState();
}

class _CalendarScreenMobileState extends State<CalendarScreenMobile> {
  bool _eventAutoFocused = false;

  @override
  Widget build(BuildContext context) {
    final repo = EventRepositoryImpl(EventRemoteDatasourceImpl());

    return BlocProvider(
      create: (_) => EventBloc(
        createEvent: CreateEvent(repo),
        updateEvent: UpdateEvent(repo),
        deleteEvent: DeleteEvent(repo),
        getEvents: GetEvents(repo),
      )..add(
        FetchEventsRequested(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now().add(const Duration(days: 30)),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        // --- MOBILE TOP BAR ---
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'C',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          title: BlocBuilder<EventBloc, EventState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CRM Calendar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(state.focusedDay),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            Builder(builder: (ctx) {
              return IconButton(
                icon: const Icon(Icons.today_outlined, color: Color(0xFF4B5563)),
                onPressed: () => ctx.read<EventBloc>().add(NavigateCalendar(DateTime.now())),
              );
            }),
            const SizedBox(width: 8),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<EventBloc, EventState>(
                    listenWhen: (prev, curr) =>
                    curr is EventActionSuccess || curr is EventError,
                    listener: (ctx, state) {
                      if (state is EventActionSuccess) {
                        _showSnackBar(ctx, state.message, const Color(0xFF10B981));
                      } else if (state is EventError) {
                        _showSnackBar(ctx, state.message, const Color(0xFFEF4444));
                      }
                    },
                  ),
                  BlocListener<EventBloc, EventState>(
                    listener: (ctx, state) {
                      if (state is CreateModalOpen) {
                        _showMobileCreateModal(ctx, state.selectedDateTime);
                      } else if (state is DetailModalOpen) {
                        _showMobileDetailModal(ctx, state.selectedEvent);
                      }
                    },
                  ),
                ],
                child: BlocBuilder<EventBloc, EventState>(
                  builder: (ctx, state) {
                    // Logic for focusing specific event on load
                    if (!_eventAutoFocused &&
                        widget.focusEventId != null &&
                        state.events.isNotEmpty) {
                      for (final event in state.events) {
                        if (event.id == widget.focusEventId) {
                          _eventAutoFocused = true;
                          ctx.read<EventBloc>().add(NavigateCalendar(event.start));
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ctx.read<EventBloc>().add(EventTapped(event));
                          });
                          break;
                        }
                      }
                    }

                    if (state is EventLoading && state.events.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                      );
                    }

                    return CalendarView(
                      events: state.events,
                      format: state.calendarFormat,
                      focusedDay: state.focusedDay,
                      onDayTapped: (dt) => ctx.read<EventBloc>().add(SlotTapped(dt)),
                      onEventTapped: (ev) => ctx.read<EventBloc>().add(EventTapped(ev)),
                    );
                  },
                ),
              ),
            ),
            // --- MOBILE LEGEND ---
            const _CalendarLegend(),
          ],
        ),
        floatingActionButton: Builder(builder: (ctx) {
          return FloatingActionButton(
            backgroundColor: const Color(0xFF6366F1),
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => ctx.read<EventBloc>().add(SlotTapped(DateTime.now())),
          );
        }),
      ),
    );
  }

  static void _showMobileCreateModal(BuildContext ctx, DateTime? dt) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventModal(
        selectedDateTime: dt,
        onSave: (entity) {
          ctx.read<EventBloc>().add(CreateEventRequested(entity));
        },
      ),
    ).then((_) => ctx.read<EventBloc>().add(ModalDismissed()));
  }

  static void _showMobileDetailModal(BuildContext ctx, dynamic event) async {
    final ds = EventRemoteDatasourceImpl();
    await ds.ensureUsersLoaded();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventDetailsModal(
        event: event,
        usersById: ds.usersById,
        onEdit: (ev) {
          Navigator.pop(ctx);
          _showMobileCreateModal(ctx, ev.start);
        },
        onDelete: (id) {
          ctx.read<EventBloc>().add(DeleteEventRequested(id.toString()));
          Navigator.pop(ctx);
        },
      ),
    ).then((_) => ctx.read<EventBloc>().add(ModalDismissed()));
  }

  void _showSnackBar(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "LEGEND",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9CA3AF),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _legendItem('Meeting', const Color(0xFF6366F1)),
              _legendItem('Call', const Color(0xFF10B981)),
              _legendItem('Task', const Color(0xFFF59E0B)),
              _legendItem('Deadline', const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}