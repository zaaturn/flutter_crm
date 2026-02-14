import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my_app/event_management/core/constants/app_colors.dart';
import 'package:my_app/event_management/features/domain/entities/event_entity.dart';

// ✅ import real user model
import '../../../calendar/data/datasources/event_remote_datasource_impl.dart';

class EventDetailsModalDesktop extends StatelessWidget {
  final EventEntity event;
  final Map<int, UserLite> usersById;

  final void Function(EventEntity) onEdit;
  final void Function(int) onDelete;

  const EventDetailsModalDesktop({
    super.key,
    required this.event,
    required this.usersById,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tc = EventTypeColor.of(event.eventType);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: tc.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(EVENT_TYPE_ICONS[event.eventType] ?? '',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text(
                        EVENT_TYPE_LABELS[event.eventType] ?? event.eventType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tc.text,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(event.title, style: theme.textTheme.displayMedium),
            const SizedBox(height: 20),

            _detailRow(
              '🕐',
              'Date & Time',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatFullDate(event.start),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(
                    '${_fmtTime(event.start)} – ${_fmtTime(event.end)}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

            if (event.description.isNotEmpty)
              _detailRow('📝', 'Description',
                  Text(event.description, style: const TextStyle(fontSize: 13))),

            if (event.meetingLink.isNotEmpty)
              _detailRow(
                '🔗',
                'Meeting Link',
                GestureDetector(
                  onTap: () => _launch(event.meetingLink),
                  child: Text(
                    event.meetingLink,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

            // ✅ REAL PARTICIPANTS (no mock)
            if (event.participants.isNotEmpty)
              _detailRow(
                '👥',
                'Participants',
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: event.participants.map((uid) {
                    final u = usersById[uid];
                    final initials = u != null && u.name.isNotEmpty
                        ? u.name[0].toUpperCase()
                        : '?';

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          u?.name ?? 'User $uid',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

            _detailRow(
              '🔔',
              'Reminder',
              Text(
                REMINDER_LABELS[event.reminderBefore] ??
                    '${event.reminderBefore} min',
                style: const TextStyle(fontSize: 13),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.dangerBorder, width: 1.5),
                    foregroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _confirmDelete(context, event, onDelete),

                  child: const Text('Delete',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit(event);
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// helpers unchanged ...
}
// ─────────────────────────────────────────────
// LOCAL HELPERS & CONSTANTS (replacing mock_data.dart)
// ─────────────────────────────────────────────

const Map<String, String> EVENT_TYPE_ICONS = {
  'meeting': '📅',
  'call': '📞',
  'task': '✅',
  'reminder': '⏰',
};

const Map<String, String> EVENT_TYPE_LABELS = {
  'meeting': 'Meeting',
  'call': 'Call',
  'task': 'Task',
  'reminder': 'Reminder',
};

const Map<int, String> REMINDER_LABELS = {
  5: '5 minutes before',
  10: '10 minutes before',
  15: '15 minutes before',
  30: '30 minutes before',
  60: '1 hour before',
};

Widget _detailRow(String icon, String label, Widget content) => Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 16)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            content,
          ],
        ),
      ),
    ],
  ),
);

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> _confirmDelete(
    BuildContext context,
    EventEntity event,
    void Function(int) onDelete,
    ) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Event'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true && event.id != null) {
    onDelete(event.id!);
    if (context.mounted) Navigator.pop(context);
  }
}

String _fmtTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m ${dt.hour >= 12 ? "PM" : "AM"}';
}

String _formatFullDate(DateTime dt) {
  final days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${days[dt.weekday % 7]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}
