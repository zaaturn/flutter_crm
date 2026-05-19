import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/event_management/core/utils/indian_time.dart';
import 'package:my_app/event_management/features/notification/domain/entity/notification_entity.dart';
import 'package:my_app/services/notification_payload_router.dart';

import '../../bloc/notification_bloc.dart';

class _ZaaturnNotifDesktopUI {
  static const Color bg = Color(0xFFFAF3E0);
  static const Color terracotta = Color(0xFFC05E41);
  static const Color card = Color(0xFFEADBC8);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textMuted = Color(0xFF8D6E63);
  static const Color danger = Color(0xFFEF4444);
}

/// Desktop notifications — warm Zaaturn theme, timestamps in IST.
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
      backgroundColor: _ZaaturnNotifDesktopUI.bg,
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
                      color: _ZaaturnNotifDesktopUI.textMuted
                          .withValues(alpha: 0.9),
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
                            color: _ZaaturnNotifDesktopUI.terracotta,
                            strokeWidth: 2.4,
                          ),
                        );
                      }
                      if (state.notifications.isEmpty) {
                        return _buildEmptyState();
                      }

                      final grouped = _groupNotifications(state.notifications);

                      return RefreshIndicator(
                        color: _ZaaturnNotifDesktopUI.terracotta,
                        backgroundColor: _ZaaturnNotifDesktopUI.bg,
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
                                      color: _ZaaturnNotifDesktopUI.textMuted
                                          .withValues(alpha: 0.85),
                                      letterSpacing: 1.1,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: _ZaaturnNotifDesktopUI.textDark,
            ),
            tooltip: 'Back',
          ),
          Text(
            'Notifications',
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _ZaaturnNotifDesktopUI.textDark,
            ),
          ),
          const Spacer(),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (ctx, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _ZaaturnNotifDesktopUI.terracotta.withValues(alpha: 0.12),
                  foregroundColor: _ZaaturnNotifDesktopUI.terracotta,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onPressed: () => ctx
                    .read<NotificationBloc>()
                    .add(NotificationMarkAllRead()),
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
              color: _ZaaturnNotifDesktopUI.card,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 44,
              color: _ZaaturnNotifDesktopUI.terracotta,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _ZaaturnNotifDesktopUI.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No new notifications right now.',
            style: GoogleFonts.inter(
              color: _ZaaturnNotifDesktopUI.textMuted,
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
            color: _ZaaturnNotifDesktopUI.danger,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _ZaaturnNotifDesktopUI.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _ZaaturnNotifDesktopUI.terracotta,
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
        color: _ZaaturnNotifDesktopUI.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRead
              ? _ZaaturnNotifDesktopUI.terracotta.withValues(alpha: 0.08)
              : _ZaaturnNotifDesktopUI.terracotta.withValues(alpha: 0.22),
        ),
      ),
      child: InkWell(
        onTap: canClick ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeIcon(),
              const SizedBox(width: 14),
              Expanded(
                child: Opacity(
                  opacity: isRead ? 0.75 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: _ZaaturnNotifDesktopUI.textDark,
                              ),
                            ),
                          ),
                          Text(
                            IndianTime.formatRelative(notification.createdAt),
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _ZaaturnNotifDesktopUI.textMuted,
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
                          fontWeight: FontWeight.w600,
                          color: _ZaaturnNotifDesktopUI.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        IndianTime.formatTime(notification.createdAt),
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _ZaaturnNotifDesktopUI.textMuted
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isRead)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  decoration: BoxDecoration(
                    color: _ZaaturnNotifDesktopUI.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _ZaaturnNotifDesktopUI.bg,
                      width: 2,
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
    switch (notification.type) {
      case 'task_assigned':
      case 'task_completed':
        icon = Icons.assignment_rounded;
        break;
      case 'event_created':
        icon = Icons.calendar_today_rounded;
        break;
      case 'reminder':
        icon = Icons.alarm_rounded;
        break;
      default:
        icon = Icons.notifications_active_rounded;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: _ZaaturnNotifDesktopUI.terracotta, size: 22),
    );
  }
}
