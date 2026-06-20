import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/notification/domain/entity/notification_entity.dart';
import 'package:my_app/services/notification_payload_router.dart';
import '../bloc/notification_bloc.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationBloc>().add(NotificationLoadRequested());
    });
  }

  Map<String, List<AppNotification>> _groupNotifications(List<AppNotification> list) {
    final groups = <String, List<AppNotification>>{};
    final now = DateTime.now();

    for (var n in list) {
      String label;
      final date = n.createdAt;

      if (date.year == now.year && date.month == now.month && date.day == now.day) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (ctx, state) {
              // Hide "Mark all read" if everything is already read
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: () => ctx.read<NotificationBloc>().add(NotificationMarkAllRead()),
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D3199)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (ctx, state) {
          if (state.error != null && state.notifications.isEmpty) {
            return _buildErrorState(ctx, state.error!);
          }

          if (state.isLoading && state.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D3199)),
            );
          }

          if (state.notifications.isEmpty) {
            return _buildEmptyState();
          }

          final grouped = _groupNotifications(state.notifications);

          return RefreshIndicator(
            color: const Color(0xFF0D3199),
            backgroundColor: Colors.white,
            onRefresh: () async {
              ctx.read<NotificationBloc>().add(NotificationLoadRequested());
              await Future<void>.delayed(const Duration(milliseconds: 600));
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final dateLabel = grouped.keys.elementAt(index);
                final items = grouped[dateLabel]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 24, bottom: 12),
                      child: Text(
                        dateLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...items.map((notif) => _NotificationCard(
                      notification: notif,
                      onTap: () => _handleNotifTap(ctx, notif),
                    )),
                  ],
                );
              },
            ),
          );
        },
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
    } else {

      debugPrint("Navigation restricted for this notification type.");
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: Colors.blueGrey[50]),
          const SizedBox(height: 16),
          const Text(
            'All caught up!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          const Text(
            'No new notifications right now.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
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
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
          const SizedBox(height: 12),
          Text(error, style: const TextStyle(color: Color(0xFF64748B))),
          TextButton(
            onPressed: () => ctx.read<NotificationBloc>().add(NotificationLoadRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification.isRead;
    final bool canClick = notification.isClickable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(

          color: isRead ? const Color(0xFFF1F5F9) : const Color(0xFF0D3199).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(

        onTap: canClick ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Opacity(

            opacity: canClick ? 1.0 : 0.7,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!isRead)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0D3199),
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.w700 : FontWeight.w900,
                                fontSize: 14,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(notification.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
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
        color = const Color(0xFF64748B);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, color: color, size: 18)),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('MMM d').format(dt);
  }
}