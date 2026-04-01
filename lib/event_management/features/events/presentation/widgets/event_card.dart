import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/core/utils/event_instant.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:my_app/event_management/shared/themes/event_management_fonts.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../../domain/entities/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final bool compact;

  const EventCard({required this.event, this.compact = false, super.key});

  Color get _color =>
      Color(int.parse('0xFF${event.displayColor.replaceAll('#', '')}'));

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete event?', style: EventManagementFonts.jakarta(fontWeight: FontWeight.w700)),
        content: Text('Delete "${event.title}"?', style: EventManagementFonts.cardMeta()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<EventBloc>().add(DeleteEventRequested(eventId: event.id));
    try {
      context.read<CalendarBloc>().add(CalendarRefreshRequested());
    } catch (_) {}
    try {
      context.read<DashboardBloc>().add(DashboardRefreshRequested());
    } catch (_) {}
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Event deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => EventDetailScreen(eventId: event.id),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.borderLight.withValues(alpha: 0.85),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                    child: compact
                        ? _CompactContent(event: event, color: _color)
                        : _FullContent(
                            event: event,
                            color: _color,
                            onDeleteTap: () => _confirmDelete(context),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullContent extends StatelessWidget {
  final Event event;
  final Color color;
  final VoidCallback onDeleteTap;

  const _FullContent({
    required this.event,
    required this.color,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = event.location?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                event.title,
                style: EventManagementFonts.cardTitle(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                event.type.label.toUpperCase(),
                style: EventManagementFonts.chipLabel().copyWith(color: color),
              ),
            ),
            FutureBuilder<String?>(
              future: SecureStorageService().readUserId(),
              builder: (ctx, snap) {
                final uid = snap.data;
                final pending = uid != null &&
                    uid.isNotEmpty &&
                    event.invitePendingForUser(uid);
                final mine = uid != null &&
                    uid.isNotEmpty &&
                    uid == event.createdBy.id.toString();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pending) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.reminderAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.reminderAmber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'RSVP',
                          style: EventManagementFonts.chipLabel().copyWith(
                            color: const Color(0xFFB45309),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (mine)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        icon: Icon(Icons.delete_outline_rounded,
                            size: 22, color: Colors.red.shade400),
                        tooltip: 'Delete',
                        onPressed: onDeleteTap,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.borderLight.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetaRow(
                icon: Icons.calendar_today_rounded,
                iconColor: AppTheme.primaryBlue,
                label: EventInstant.formatShortDate(event.startTime),
              ),
              const SizedBox(height: 10),
              _MetaRow(
                icon: Icons.schedule_rounded,
                iconColor: AppTheme.primaryBlue,
                label: EventInstant.formatTimeRange(
                  event.startTime,
                  event.endTime,
                  allDay: event.isAllDay,
                ),
                emphasis: true,
              ),
              if (loc.isNotEmpty) ...[
                const SizedBox(height: 10),
                _MetaRow(
                  icon: Icons.location_on_outlined,
                  iconColor: AppTheme.textSecondary,
                  label: loc,
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool emphasis;
  final int maxLines;

  const _MetaRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.emphasis = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: emphasis
                ? EventManagementFonts.cardMetaEmphasis()
                : EventManagementFonts.cardMeta(),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CompactContent extends StatelessWidget {
  final Event event;
  final Color color;

  const _CompactContent({required this.event, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            event.title,
            style: EventManagementFonts.jakarta(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          event.isAllDay
              ? 'All day'
              : DateFormat.jm().format(event.startTime.toLocal()),
          style: EventManagementFonts.cardMeta(),
        ),
      ],
    );
  }
}
