import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/notification/domain/entity/notification_entity.dart';
import 'package:my_app/services/notification_payload_router.dart';

import '../../bloc/notification_bloc.dart';

class _ZaaturnNotifUI {
  static const Color bg = Color(0xFFFAF3E0);
  static const Color terracotta = Color(0xFFC05E41);
  static const Color card = Color(0xFFEADBC8);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textMuted = Color(0xFF8D6E63);
  static const Color danger = Color(0xFFEF4444);
}

class NotificationScreenMobile extends StatefulWidget {
  const NotificationScreenMobile({super.key});

  @override
  State<NotificationScreenMobile> createState() =>
      _NotificationScreenMobileState();
}

class _NotificationScreenMobileState extends State<NotificationScreenMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationBloc>().add(NotificationLoadRequested());
    });
  }

  Map<String, List<AppNotification>> _groupNotifications(
      List<AppNotification> list) {
    final groups = <String, List<AppNotification>>{};
    final now = DateTime.now().toLocal();

    for (final n in list) {
      String label;
      // `createdAt` should already be local, but keep this defensive.
      final date = n.createdAt.toLocal();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        label = "Today";
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.subtract(const Duration(days: 1)).day) {
        label = "Yesterday";
      } else {
        label = DateFormat('MMMM dd').format(date);
      }
      groups.putIfAbsent(label, () => []).add(n);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ZaaturnNotifUI.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (ctx, state) {
                  if (state.error != null && state.notifications.isEmpty) {
                    return _buildErrorState(ctx, state.error!);
                  }
                  if (state.isLoading && state.notifications.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _ZaaturnNotifUI.terracotta,
                        strokeWidth: 2.4,
                      ),
                    );
                  }
                  if (state.notifications.isEmpty) return _buildEmptyState();

                  final grouped = _groupNotifications(state.notifications);

                  return RefreshIndicator(
                    color: _ZaaturnNotifUI.terracotta,
                    backgroundColor: _ZaaturnNotifUI.bg,
                    onRefresh: () async {
                      ctx
                          .read<NotificationBloc>()
                          .add(NotificationLoadRequested());
                      await Future<void>.delayed(
                          const Duration(milliseconds: 450));
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: grouped.keys.length,
                      itemBuilder: (context, index) {
                        final dateLabel = grouped.keys.elementAt(index);
                        final items = grouped[dateLabel]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, top: 18, bottom: 10),
                              child: Text(
                                dateLabel.toUpperCase(),
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: _ZaaturnNotifUI.textMuted
                                      .withValues(alpha: 0.85),
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            ...items.map(
                              (notif) => _NotifCard(
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
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: _ZaaturnNotifUI.bg,
      padding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _ZaaturnNotifUI.textDark,
              size: 20,
            ),
          ),
          Text(
            'Notifications',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _ZaaturnNotifUI.textDark,
            ),
          ),
          const Spacer(),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (ctx, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () =>
                    ctx.read<NotificationBloc>().add(NotificationMarkAllRead()),
                style: TextButton.styleFrom(
                  foregroundColor: _ZaaturnNotifUI.terracotta,
                  textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w900),
                ),
                child: const Text('Mark all read'),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: _ZaaturnNotifUI.card,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  size: 40, color: _ZaaturnNotifUI.terracotta),
            ),
            const SizedBox(height: 14),
            Text(
              'All caught up!',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _ZaaturnNotifUI.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No new notifications right now.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: _ZaaturnNotifUI.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext ctx, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: _ZaaturnNotifUI.danger, size: 36),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: _ZaaturnNotifUI.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _ZaaturnNotifUI.terracotta,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  ctx.read<NotificationBloc>().add(NotificationLoadRequested()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotifCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification.isRead;
    final bool canClick = notification.isClickable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _ZaaturnNotifUI.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRead
              ? _ZaaturnNotifUI.terracotta.withValues(alpha: 0.08)
              : _ZaaturnNotifUI.terracotta.withValues(alpha: 0.22),
        ),
      ),
      child: InkWell(
        onTap: canClick ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                  color: _ZaaturnNotifUI.terracotta,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Opacity(
                  opacity: isRead ? 0.72 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: GoogleFonts.manrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: _ZaaturnNotifUI.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          height: 1.35,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _ZaaturnNotifUI.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('hh:mm a')
                            .format(notification.createdAt.toLocal()),
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _ZaaturnNotifUI.textMuted.withValues(alpha: 0.9),
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
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: _ZaaturnNotifUI.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: _ZaaturnNotifUI.bg, width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

