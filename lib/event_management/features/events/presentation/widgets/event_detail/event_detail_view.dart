import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/event.dart';
import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:my_app/event_management/shared/themes/event_management_fonts.dart';

import '../../screens/event_edit_screen.dart';
import 'event_detail_constants.dart';
import 'event_detail_description_card.dart';
import 'event_detail_hero.dart';
import 'event_detail_location_card.dart';
import 'event_detail_participants_card.dart';
import 'event_detail_invite_bar.dart';
import 'event_detail_schedule_card.dart';

/// Full-page layout: hero, two-column (wide) or stacked content.
class EventDetailView extends StatelessWidget {
  final Event event;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onDelete;
  final bool showPendingInviteActions;
  final bool inviteActionBusy;
  final VoidCallback? onAcceptInvite;
  final VoidCallback? onDeclineInvite;

  const EventDetailView({
    super.key,
    required this.event,
    required this.canEdit,
    required this.canDelete,
    required this.onDelete,
    this.showPendingInviteActions = false,
    this.inviteActionBusy = false,
    this.onAcceptInvite,
    this.onDeclineInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardUiTheme.pageBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: DashboardUiTheme.pageBackground,
        foregroundColor: AppTheme.textPrimary,
        title: const SizedBox.shrink(),
        centerTitle: false,
        actions: [
          if (canEdit || canDelete)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (v) {
                if (v == 'edit') {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          EventEditScreen(eventId: event.id, event: event),
                    ),
                  );
                } else if (v == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                if (canEdit)
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (canDelete)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFFDC2626)),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showPendingInviteActions &&
              onAcceptInvite != null &&
              onDeclineInvite != null)
            EventDetailInviteBar(
              event: event,
              busy: inviteActionBusy,
              onAccept: onAcceptInvite!,
              onDecline: onDeclineInvite!,
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth >= EventDetailLayout.wideBreakpoint;
                final pad = EdgeInsets.fromLTRB(
                  wide ? 28 : 16,
                  12,
                  wide ? 28 : 16,
                  28,
                );

                final link = event.meetingLink?.trim() ?? '';
                final hero = EventDetailHero(
                  event: event,
                  onJoinEvent: link.isEmpty
                      ? null
                      : () async {
                          final normalized = _normalizeWebUrl(link);
                          final uri = Uri.tryParse(normalized);
                          if (uri == null) return;
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        },
                );

                final leftCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EventDetailScheduleCard(event: event),
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: DashboardUiTheme.border.withValues(alpha: 0.55),
                    ),
                    const SizedBox(height: 16),
                    EventDetailLocationCard(event: event),
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: DashboardUiTheme.border.withValues(alpha: 0.55),
                    ),
                    const SizedBox(height: 16),
                    EventDetailParticipantsCard(
                      participants: event.participants,
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: DashboardUiTheme.border.withValues(alpha: 0.55),
                    ),
                    const SizedBox(height: 16),
                    EventDetailDescriptionCard(event: event),
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: DashboardUiTheme.border.withValues(alpha: 0.55),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Created by ${event.createdBy.username} • ${DateFormat('MMM d, yyyy').format(event.createdAt.toLocal())}',
                      style: EventManagementFonts.jakarta(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                );

                return SingleChildScrollView(
                  padding: pad,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: EventDetailLayout.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          hero,
                          const SizedBox(height: 8),
                          leftCol,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeWebUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;
    final lower = v.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return v;
    return 'https://$v';
  }
}
