import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/screen/mobile/event_detail_screen_mobile.dart';
import 'package:my_app/services/secure_storage_service.dart';
import '../../domain/entities/event.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0);
  static const Color cardBeige = Color(0xFFEADBC8);
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textMuted = Color(0xFF8D6E63);
  static const Color alertAmber = Color(0xFFB45309);
}

class EventCardMobile extends StatelessWidget {
  final Event event;
  final bool compact;

  const EventCardMobile({
    required this.event,
    this.compact = false,
    super.key,
  });

  Color get _categoryColor =>
      Color(int.parse('0xFF${event.displayColor.replaceAll('#', '')}'));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ZaaturnUI.cardBeige,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailMobileScreen(eventId: event.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: compact ? _buildCompact() : _buildFull(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final startTime = DateFormat.jm().format(event.startTime.toLocal());
    final endTime = DateFormat.jm().format(event.endTime.toLocal());
    final date = DateFormat('MMM dd').format(event.startTime.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event.title,
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ZaaturnUI.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Dynamic Action Section (RSVP Badge + More/Delete Icon)
            _DynamicCardActions(event: event),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Badge(
              icon: Icons.calendar_today_rounded,
              label: date,
            ),
            _Badge(
              icon: Icons.access_time_filled_rounded,
              label: event.isAllDay ? "All Day" : "$startTime - $endTime",
            ),
            if (event.location?.isNotEmpty ?? false)
              _Badge(
                icon: Icons.location_on_rounded,
                label: event.location!.trim(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompact() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _categoryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            event.title,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ZaaturnUI.textDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          event.isAllDay ? "All Day" : DateFormat.jm().format(event.startTime.toLocal()),
          style: GoogleFonts.inter(
            fontSize: 12,
            color: ZaaturnUI.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ZaaturnUI.accentOrange),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ZaaturnUI.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DynamicCardActions extends StatelessWidget {
  final Event event;
  const _DynamicCardActions({required this.event});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SecureStorageService().readUserId(),
      builder: (ctx, snap) {
        final uid = snap.data;
        if (uid == null || uid.isEmpty) return const SizedBox.shrink();

        final bool isPending = event.invitePendingForUser(uid);
        final bool isOwner = uid == event.createdBy.id.toString();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPending) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ZaaturnUI.alertAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ZaaturnUI.alertAmber.withOpacity(0.3)),
                ),
                child: Text(
                  'RSVP',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: ZaaturnUI.alertAmber,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (isOwner)
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              )
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: ZaaturnUI.background,
        title: Text('Delete Event?',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: ZaaturnUI.textDark)
        ),
        content: Text('Do you want to remove "${event.title}"?',
            style: GoogleFonts.inter(color: ZaaturnUI.textDark)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.manrope(color: ZaaturnUI.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      try {
        context.read<DashboardBloc>().add(DashboardRemoveEventById(event.id));
        context.read<EventBloc>().add(DeleteEventRequested(eventId: event.id));
        context.read<CalendarBloc>().add(CalendarRefreshRequested());
      } catch (_) {}
    }
  }
}