import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../../domain/entities/event.dart';
import '../bloc/event_bloc.dart';
import '../widgets/event_detail/event_detail_view.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({required this.eventId, super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _rsvpBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EventBloc>().add(LoadEventByIdRequested(widget.eventId));
    });
  }

  void _refreshDashboardAndCalendar(BuildContext context) {
    try {
      context.read<CalendarBloc>().add(CalendarRefreshRequested());
    } catch (_) {}
    try {
      context.read<DashboardBloc>().add(DashboardRefreshRequested());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        void finishInviteOk() {
          if (!_rsvpBusy || !context.mounted) return;
          setState(() => _rsvpBusy = false);
          _refreshDashboardAndCalendar(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invitation updated')),
          );
        }

        if (state is EventUpdated &&
            state.event.id == widget.eventId &&
            _rsvpBusy) {
          finishInviteOk();
          return;
        }
        if (state is EventError && _rsvpBusy) {
          setState(() => _rsvpBusy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          return;
        }
        // Refetch path emits EventsLoaded; ensure spinner stops if RSVP cleared.
        if (state is EventsLoaded && _rsvpBusy) {
          SecureStorageService().readUserId().then((uid) {
            if (!context.mounted || uid == null || uid.isEmpty) return;
            try {
              final ev =
                  state.events.firstWhere((e) => e.id == widget.eventId);
              if (!ev.invitePendingForUser(uid)) {
                finishInviteOk();
              }
            } catch (_) {}
          });
        }
      },
      child: BlocBuilder<EventBloc, EventState>(
        builder: (ctx, state) {
          if (state is EventError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Event Detail')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ctx
                            .read<EventBloc>()
                            .add(LoadEventByIdRequested(widget.eventId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          Event? event;
          if (state is EventsLoaded) {
            try {
              event = state.events.firstWhere((e) => e.id == widget.eventId);
            } catch (_) {}
          }

          if (event == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Event Detail')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return FutureBuilder<String?>(
            future: SecureStorageService().readUserId(),
            builder: (context, snap) {
              final uid = snap.data;
              final mine = uid != null &&
                  uid.isNotEmpty &&
                  uid == event!.createdBy.id.toString();
              final pendingInvite = uid != null &&
                  uid.isNotEmpty &&
                  event!.invitePendingForUser(uid);

              return EventDetailView(
                event: event!,
                canDelete: mine,
                onDelete: () => _confirmDelete(context, event!),
                showPendingInviteActions: pendingInvite,
                inviteActionBusy: _rsvpBusy,
                onAcceptInvite: pendingInvite
                    ? () {
                        setState(() => _rsvpBusy = true);
                        context.read<EventBloc>().add(
                              AcceptEventInviteRequested(event!.id),
                            );
                      }
                    : null,
                onDeclineInvite: pendingInvite
                    ? () {
                        setState(() => _rsvpBusy = true);
                        context.read<EventBloc>().add(
                              DeclineEventInviteRequested(event!.id),
                            );
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('Delete "${event.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              try {
                context.read<DashboardBloc>().add(
                      DashboardRemoveEventById(event.id),
                    );
              } catch (_) {}
              context.read<EventBloc>().add(
                    DeleteEventRequested(eventId: event.id),
                  );
              try {
                context.read<CalendarBloc>().add(CalendarRefreshRequested());
              } catch (_) {}
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
