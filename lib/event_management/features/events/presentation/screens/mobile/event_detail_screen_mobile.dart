import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/events/presentation/utils/event_snackbar.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/mobile/mobile_event_theme.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_edit_screen_mobile.dart';
import 'package:my_app/services/secure_storage_service.dart';

class EventDetailMobileScreen extends StatefulWidget {
  final String eventId;

  const EventDetailMobileScreen({required this.eventId, super.key});

  @override
  State<EventDetailMobileScreen> createState() => _EventDetailMobileScreenState();
}

class _EventDetailMobileScreenState extends State<EventDetailMobileScreen> {
  bool _rsvpBusy = false;
  Event? _resolvedEvent;
  String? _pendingRsvpAction; // 'accept' | 'decline'

  /// Read event from the current bloc state (must run in [build] — listener runs after build).
  static Event? _eventFromState(EventState state, String eventId) {
    final id = eventId.trim();
    if (state is EventsLoaded) {
      for (final e in state.events) {
        if (e.id.trim() == id) return e;
      }
    }
    if (state is EventUpdated && state.event.id.trim() == id) {
      return state.event;
    }
    if (state is EventSearchResults) {
      for (final e in state.results) {
        if (e.id.trim() == id) return e;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EventBloc>().add(LoadEventByIdRequested(widget.eventId));
    });
  }

  @override
  void didUpdateWidget(covariant EventDetailMobileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventId != widget.eventId) {
      _resolvedEvent = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<EventBloc>().add(LoadEventByIdRequested(widget.eventId));
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final normalized = _normalizeWebUrl(url);
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $normalized')),
      );
    }
  }

  String _normalizeWebUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;
    final lower = v.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return v;
    // Common case: user entered "meet.google.com/xxx" or "www.domain.com"
    return 'https://$v';
  }

  @override
  Widget build(BuildContext context) {
    return MobileEventTheme.wrap(
      context,
      BlocConsumer<EventBloc, EventState>(
      listener: (context, state) {
        if (!mounted) return;
        final fromState = _eventFromState(state, widget.eventId);
        if (fromState != null) {
          setState(() => _resolvedEvent = fromState);
        }
        if ((state is EventUpdated || state is EventsLoaded) && _rsvpBusy) {
          setState(() => _rsvpBusy = false);
          _refreshLogic(context);
          final action = _pendingRsvpAction;
          if (action != null) {
            _pendingRsvpAction = null;
            final msg = action == 'accept' ? 'Event accepted' : 'Event declined';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
        if (state is EventError && _resolvedEvent != null) {
          EventSnackBars.show(state.message);
        }
      },
      builder: (context, state) {
        // Keep a synchronous cache so EventUpdating (listener runs *after* build) still has data.
        final fromState = _eventFromState(state, widget.eventId);
        if (fromState != null) {
          _resolvedEvent = fromState;
        }
        final display = _resolvedEvent;

        final inFlight =
            state is EventUpdating || state is EventLoading || _rsvpBusy;

        if (state is EventLoading && display == null) {
          return const Scaffold(
            backgroundColor: MobileEventTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: MobileEventTheme.terracotta),
            ),
          );
        }

        // RSVP / accept in progress: never flash "Event not found" while the API runs.
        if (display == null && inFlight) {
          return const Scaffold(
            backgroundColor: MobileEventTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: MobileEventTheme.terracotta),
            ),
          );
        }

        if (display == null) {
          return Scaffold(
            backgroundColor: MobileEventTheme.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state is EventError
                      ? 'Unable to load this event.'
                      : 'Event not found',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    color: MobileEventTheme.textDark,
                  ),
                ),
              ),
            ),
          );
        }

        final event = display;
        return Scaffold(
          backgroundColor: MobileEventTheme.background,
          body: Stack(
            children: [
              _buildBody(context, event),
              if (state is EventUpdating)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: MobileEventTheme.terracotta,
                    backgroundColor: Colors.transparent,
                  ),
                ),
            ],
          ),
        );
      },
      ),
    );
  }

  Widget _buildBody(BuildContext context, Event event) {
    return FutureBuilder<String?>(
      future: SecureStorageService().readUserId(),
      builder: (context, snap) {
        final uid = snap.data;
        final isOwner = event.isOwnedBy(uid);
        final isPending = event.invitePendingForUser(uid ?? "");

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, event, isOwner),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleHeader(event),
                        const SizedBox(height: 24),

                        // Meeting Link Section
                        if (event.meetingLink != null && event.meetingLink!.isNotEmpty)
                          _buildMeetingLinkCard(event.meetingLink!),

                        _buildInfoRow(Icons.calendar_today_rounded, "Date", DateFormat('EEEE, MMM dd, yyyy').format(event.startTime.toLocal())),
                        _buildInfoRow(Icons.access_time_rounded, "Time", "${DateFormat('hh:mm a').format(event.startTime.toLocal())} - ${DateFormat('hh:mm a').format(event.endTime.toLocal())}"),
                        _buildInfoRow(Icons.location_on_rounded, "Location", event.location ?? "Remote"),

                        const SizedBox(height: 32),
                        _buildParticipantsList(event),

                        const SizedBox(height: 32),
                        Text("Description", style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: MobileEventTheme.textDark)),
                        const SizedBox(height: 12),
                        Text(
                          event.description.trim().isEmpty
                              ? "No description provided."
                              : event.description.trim(),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: MobileEventTheme.textMuted,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isPending) _buildRsvpDock(context, event.id),
          ],
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Event event, bool canDelete) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: MobileEventTheme.background,
      foregroundColor: MobileEventTheme.textDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (canDelete)
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => EventEditScreenMobile(
                    eventId: event.id,
                    event: event,
                  ),
                ),
              );
            },
          ),
        if (canDelete)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () => _handleDelete(context, event),
          ),
      ],
    );
  }

  Widget _buildTitleHeader(Event event) {
    final typeColor =
        Color(int.parse('0xFF${event.displayColor.replaceAll('#', '')}'));
    final typeIcon = switch (event.type) {
      EventType.meeting => Icons.videocam_rounded,
      EventType.task => Icons.task_alt_rounded,
      EventType.reminder => Icons.notifications_active_rounded,
      EventType.personal => Icons.person_rounded,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: typeColor.withOpacity(0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(typeIcon, size: 16, color: typeColor),
              const SizedBox(width: 8),
              Text(
                event.type.label.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: MobileEventTheme.textDark,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          event.title,
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: MobileEventTheme.textDark,
            height: 1.15,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 6),
        Text("Hosted by ${event.createdBy.username}", style: GoogleFonts.inter(fontSize: 14, color: MobileEventTheme.textMuted, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMeetingLinkCard(String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: MobileEventTheme.terracotta,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Meeting link',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: MobileEventTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _launchUrl(url),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Icon(Icons.videocam_rounded, color: MobileEventTheme.terracotta, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    url,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: MobileEventTheme.terracotta,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(Icons.open_in_new_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList(Event event) {
    final participants = event.participants;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Participants (${participants.length})",
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: MobileEventTheme.textDark,
                ),
              ),
            ),
            if (participants.isNotEmpty)
              TextButton(
                onPressed: () => _ParticipantsSheet.show(context, participants),
                style: TextButton.styleFrom(
                  foregroundColor: MobileEventTheme.terracotta,
                  textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w900),
                ),
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (participants.isEmpty)
          Text(
            "No participants",
            style: GoogleFonts.inter(
              color: MobileEventTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          _ParticipantsPreview(
            participants: participants,
            onTap: () => _ParticipantsSheet.show(context, participants),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MobileEventTheme.terracotta, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.manrope(fontSize: 11, color: MobileEventTheme.textMuted, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: MobileEventTheme.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRsvpDock(BuildContext context, String id) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: MobileEventTheme.background,
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _rsvpBusy = true;
                    _pendingRsvpAction = 'decline';
                  });
                  context.read<EventBloc>().add(DeclineEventInviteRequested(id));
                },
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56), side: const BorderSide(color: MobileEventTheme.terracotta), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Decline", style: TextStyle(color: MobileEventTheme.terracotta, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _rsvpBusy = true;
                    _pendingRsvpAction = 'accept';
                  });
                  context.read<EventBloc>().add(AcceptEventInviteRequested(id));
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 56), backgroundColor: MobileEventTheme.terracotta, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Accept", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Event?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(onPressed: () {
            context.read<EventBloc>().add(DeleteEventRequested(eventId: event.id));
            Navigator.pop(ctx);
            Navigator.pop(context);
          }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _refreshLogic(BuildContext context) {
    context.read<CalendarBloc>().add(CalendarRefreshRequested());
    context.read<DashboardBloc>().add(DashboardRefreshRequested());
  }
}

class _ParticipantsPreview extends StatelessWidget {
  final List<Participant> participants;
  final VoidCallback onTap;

  const _ParticipantsPreview({
    required this.participants,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shown = participants.take(6).toList(growable: false);
    final extra = participants.length - shown.length;
    final double avatarStackWidth =
        34.0 + (shown.isEmpty ? 0.0 : (shown.length - 1) * 22.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: avatarStackWidth,
              height: 34,
              child: Stack(
                children: [
                  for (int i = 0; i < shown.length; i++)
                    Positioned(
                      left: i * 22.0,
                      child: _AvatarBubble(username: shown[i].username),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                extra > 0
                    ? '${shown.length} shown • +$extra more'
                    : '${participants.length} participant(s)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MobileEventTheme.textMuted,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: MobileEventTheme.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  final String username;
  const _AvatarBubble({required this.username});

  @override
  Widget build(BuildContext context) {
    final u = username.trim().isEmpty ? 'U' : username.trim();
    final letter = u.characters.first.toUpperCase();
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        shape: BoxShape.circle,
        border: Border.all(color: MobileEventTheme.background, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.manrope(
          color: MobileEventTheme.terracotta,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ParticipantsSheet extends StatefulWidget {
  final List<Participant> participants;
  const _ParticipantsSheet({required this.participants});

  static Future<void> show(BuildContext context, List<Participant> participants) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ParticipantsSheet(participants: participants),
    );
  }

  @override
  State<_ParticipantsSheet> createState() => _ParticipantsSheetState();
}

class _ParticipantsSheetState extends State<_ParticipantsSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? widget.participants
        : widget.participants
            .where((p) => p.username.toLowerCase().contains(q))
            .toList(growable: false);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (ctx, controller) {
        return Container(
          decoration: BoxDecoration(
            color: MobileEventTheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: MobileEventTheme.terracotta.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: MobileEventTheme.textMuted.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Participants',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: MobileEventTheme.textDark,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.participants.length}',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        color: MobileEventTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: MobileEventTheme.field,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: MobileEventTheme.terracotta.withOpacity(0.14)),
                  ),
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: MobileEventTheme.terracotta),
                      hintText: 'Search username',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      hintStyle: GoogleFonts.inter(
                        color: MobileEventTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      color: MobileEventTheme.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = list[i];
                    final name = p.username.trim().isEmpty ? 'Unknown' : p.username.trim();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: MobileEventTheme.field,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: MobileEventTheme.terracotta.withOpacity(0.10)),
                      ),
                      child: Row(
                        children: [
                          _AvatarBubble(username: name),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SelectableText(
                              name,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: MobileEventTheme.textDark,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              Clipboard.setData(ClipboardData(text: name));
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied')),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 18, color: MobileEventTheme.textMuted),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}