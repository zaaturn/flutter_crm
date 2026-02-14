import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Bloc and Shared Imports
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

// Device Specific Imports
import 'package:my_app/event_management/features/presentation/widgets/device_specific/calendar_view_desktop.dart';
import 'package:my_app/event_management/features/presentation/widgets/device_specific/event_detail_modal_desktop.dart';
import 'package:my_app/event_management/features/presentation/widgets/device_specific/event_modal_desktop.dart';

// Domain/Data Layers
import '../../calendar/data/repositories/event_repository_impl.dart';
import '../../calendar/data/datasources/event_remote_datasource_impl.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/update_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/get_events.dart';

// App Constants
import 'package:my_app/event_management/core/constants/app_colors.dart';

class CalendarScreenDesktop extends StatefulWidget {
  final int? focusEventId;

  const CalendarScreenDesktop({
    super.key,
    this.focusEventId,
  });

  @override
  State<CalendarScreenDesktop> createState() =>
      _CalendarScreenDesktopState();
}

class _CalendarScreenDesktopState extends State<CalendarScreenDesktop> {
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
        body: Column(
          children: [
            const _TopBar(),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<EventBloc, EventState>(
                    listenWhen: (prev, curr) =>
                    curr is EventActionSuccess || curr is EventError,
                    listener: (ctx, state) {
                      if (state is EventActionSuccess) {
                        _showNotification(
                          ctx,
                          state.message,
                          const Color(0xFF10B981),
                        );
                      } else if (state is EventError) {
                        _showNotification(
                          ctx,
                          state.message,
                          const Color(0xFFEF4444),
                        );
                      }
                    },
                  ),
                  BlocListener<EventBloc, EventState>(
                    listener: (ctx, state) {
                      if (state is CreateModalOpen) {
                        _showDesktopCreateModal(
                          ctx,
                          state.selectedDateTime,
                        );
                      } else if (state is DetailModalOpen) {
                        _showDesktopDetailModal(
                          ctx,
                          state.selectedEvent,
                        );
                      }
                    },
                  ),
                ],
                child: BlocBuilder<EventBloc, EventState>(
                  builder: (ctx, state) {

                    if (!_eventAutoFocused &&
                        widget.focusEventId != null &&
                        state.events.isNotEmpty) {
                      for (final event in state.events) {
                        if (event.id == widget.focusEventId) {
                          _eventAutoFocused = true;

                          ctx.read<EventBloc>().add(
                            NavigateCalendar(event.start),
                          );

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ctx.read<EventBloc>().add(EventTapped(event));
                          });
                          break;
                        }
                      }
                    }

                    if (state is EventLoading &&
                        state.events.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                      );
                    }

                    return CalendarViewDesktop(
                      events: state.events,
                      format: state.calendarFormat,
                      focusedDay: state.focusedDay,
                      onDayTapped: (dt) =>
                          ctx.read<EventBloc>().add(SlotTapped(dt)),
                      onEventTapped: (ev) =>
                          ctx.read<EventBloc>().add(EventTapped(ev)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDesktopCreateModal(
      BuildContext ctx, DateTime? dt) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => EventModalDesktop(
        selectedDateTime: dt,
        onSave: (entity) {
          ctx.read<EventBloc>().add(CreateEventRequested(entity));
        },
      ),
    ).then((_) => ctx.read<EventBloc>().add(ModalDismissed()));
  }

  static void _showDesktopDetailModal(
      BuildContext ctx, dynamic event) async {
    final ds = EventRemoteDatasourceImpl();
    await ds.ensureUsersLoaded();

    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => EventDetailsModalDesktop(
        event: event,
        usersById: ds.usersById,
        onEdit: (ev) {
          Navigator.pop(ctx);
          _showDesktopCreateModal(ctx, ev.start);
        },
        onDelete: (id) {
          ctx
              .read<EventBloc>()
              .add(DeleteEventRequested(id.toString()));
          Navigator.pop(ctx);
        },
      ),
    ).then((_) => ctx.read<EventBloc>().add(ModalDismissed()));
  }

  static void _showNotification(
      BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        width: 400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        final displayDate = state.focusedDay;

        return Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'CRM Calendar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 40),

              // ⬅ Previous
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  context.read<EventBloc>().add(
                    NavigateCalendar(
                      displayDate.subtract(const Duration(days: 30)),
                    ),
                  );
                },
              ),

              // Month text
              Text(
                DateFormat('MMMM yyyy').format(displayDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // ➡ Next
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  context.read<EventBloc>().add(
                    NavigateCalendar(
                      displayDate.add(const Duration(days: 30)),
                    ),
                  );
                },
              ),

              const Spacer(),

              // 🔽 Schedule Dropdown
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == "month") {
                      context.read<EventBloc>().add(
                         FormatChanged(CalendarFormat.month),
                      );
                    } else if (value == "week") {
                      context.read<EventBloc>().add(
                         FormatChanged(CalendarFormat.week),
                      );
                    } else if (value == "day") {
                      context.read<EventBloc>().add(
                         FormatChanged(CalendarFormat.twoWeeks),
                      );
                    } else if (value == "new") {
                      context.read<EventBloc>().add(
                        SlotTapped(DateTime.now()),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "month",
                      child: _buildMenuItem(
                        "Month",
                        state.calendarFormat == CalendarFormat.month,
                      ),
                    ),
                    PopupMenuItem(
                      value: "week",
                      child: _buildMenuItem(
                        "Week",
                        state.calendarFormat == CalendarFormat.week,
                      ),
                    ),
                    PopupMenuItem(
                      value: "day",
                      child: _buildMenuItem(
                        "Day",
                        state.calendarFormat ==
                            CalendarFormat.twoWeeks,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: "new",
                      child: Text(
                        "New Event",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  child: Row(
                    children: const [
                      Text(
                        "Schedule",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildMenuItem(String text, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? const Color(0xFF2563EB) : const Color(0xFF111827),
        ),
      ),
    );
  }
}

