import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/event_management/core/utils/indian_time.dart';
import 'package:my_app/event_management/features/notification/domain/entity/notification_entity.dart';
import 'package:my_app/services/notification_payload_router.dart';

import '../../bloc/notification_bloc.dart';

class _DesktopNotifUI {
  static const Color bg = Color(0xFFF8F9FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFF5F3FF);
  static const Color purpleBorder = Color(0xFFEDE9FE);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color labelMuted = Color(0xFF94A3B8);
  static const Color danger = Color(0xFFEF4444);
}

/// Desktop / web notifications — white surface + purple accent, IST timestamps.
class NotificationScreenDesktop extends StatefulWidget {
  const NotificationScreenDesktop({super.key});

  @override
  State<NotificationScreenDesktop> createState() =>
      _NotificationScreenDesktopState();
}

class _NotificationScreenDesktopState extends State<NotificationScreenDesktop> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationBloc>().add(NotificationLoadRequested());
    });
  }

  Map<String, List<AppNotification>> _groupNotifications(
    List<AppNotification> list,
  ) {
    final groups = <String, List<AppNotification>>{};
    for (final n in list) {
      final label = IndianTime.groupLabel(n.createdAt);
      groups.putIfAbsent(label, () => []).add(n);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DesktopNotifUI.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                  child: Text(
                    'Times shown in Indian Standard Time (IST)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _DesktopNotifUI.labelMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (ctx, state) {
                      if (state.error != null && state.notifications.isEmpty) {
                        return _buildErrorState(ctx, state.error!);
                      }
                      if (state.isLoading && state.notifications.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: _DesktopNotifUI.purple,
                            strokeWidth: 2.4,
                          ),
                        );
                      }
                      if (state.notifications.isEmpty) {
                        return _buildEmptyState();
                      }

                      final grouped = _groupNotifications(state.notifications);

                      return RefreshIndicator(
                        color: _DesktopNotifUI.purple,
                        backgroundColor: _DesktopNotifUI.surface,
                        onRefresh: () async {
                          ctx
                              .read<NotificationBloc>()
                              .add(NotificationLoadRequested());
                          await Future<void>.delayed(
                            const Duration(milliseconds: 500),
                          );
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(28, 4, 28, 32),
                          itemCount: grouped.keys.length,
                          itemBuilder: (context, index) {
                            final dateLabel = grouped.keys.elementAt(index);
                            final items = grouped[dateLabel]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    top: 20,
                                    bottom: 12,
                                  ),
                                  child: Text(
                                    dateLabel.toUpperCase(),
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: _DesktopNotifUI.labelMuted,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                ...items.map(
                                  (notif) => _NotifCardDesktop(
                                    notification: notif,
                                    onTap: () => _handleNotifTap(ctx, notif),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _DesktopNotifUI.surface,
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: _DesktopNotifUI.textDark,
            ),
            tooltip: 'Back',
          ),
          Text(
            'Notifications',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _DesktopNotifUI.textDark,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (ctx, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => ctx
                    .read<NotificationBloc>()
                    .add(NotificationMarkAllRead()),
                style: TextButton.styleFrom(
                  foregroundColor: _DesktopNotifUI.purple,
                  backgroundColor: _DesktopNotifUI.purpleLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: _DesktopNotifUI.purpleBorder),
                  ),
                ),
                child: Text(
                  'Mark all read',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleNotifTap(BuildContext ctx, AppNotification notif) {
    ctx.read<NotificationBloc>().add(NotificationMarkRead(notif.id));

    if (notif.isClickable) {
      NotificationPayloadRouter.handleWithContext(ctx, {
        'notif_type': notif.type,
        if (notif.eventId?.isNotEmpty ?? false) 'event_id': notif.eventId,
        if (notif.taskId?.isNotEmpty ?? false) 'task_id': notif.taskId,
        if (notif.leaveId?.isNotEmpty ?? false) 'leave_id': notif.leaveId,
        if (notif.postId?.isNotEmpty ?? false) 'post_id': notif.postId,
        if (notif.surveyId?.isNotEmpty ?? false) 'survey_id': notif.surveyId,
      });
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _DesktopNotifUI.purpleLight,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _DesktopNotifUI.purpleBorder),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 44,
              color: _DesktopNotifUI.purple,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _DesktopNotifUI.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No new notifications right now.',
            style: GoogleFonts.inter(
              color: _DesktopNotifUI.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext ctx, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: _DesktopNotifUI.danger,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _DesktopNotifUI.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _DesktopNotifUI.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ctx
                .read<NotificationBloc>()
                .add(NotificationLoadRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _NotifCardDesktop extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotifCardDesktop({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    final canClick = notification.isClickable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _DesktopNotifUI.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? const Color(0xFFF1F5F9)
              : _DesktopNotifUI.purple.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: canClick ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeIcon(),
              const SizedBox(width: 14),
              Expanded(
                child: Opacity(
                  opacity: isRead ? 0.78 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!isRead)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                color: _DesktopNotifUI.purple,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight:
                                    isRead ? FontWeight.w700 : FontWeight.w900,
                                color: _DesktopNotifUI.textDark,
                              ),
                            ),
                          ),
                          Text(
                            IndianTime.formatRelative(notification.createdAt),
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _DesktopNotifUI.labelMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          height: 1.35,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: _DesktopNotifUI.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        IndianTime.formatTime(notification.createdAt),
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _DesktopNotifUI.labelMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'task_assigned':
      case 'task_completed':
        icon = Icons.assignment_rounded;
        color = const Color(0xFF3B82F6);
        break;
      case 'event_created':
        icon = Icons.calendar_today_rounded;
        color = const Color(0xFF10B981);
        break;
      case 'reminder':
        icon = Icons.alarm_rounded;
        color = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = _DesktopNotifUI.purple;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
