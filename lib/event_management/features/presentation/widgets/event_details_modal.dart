import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my_app/event_management/core/constants/app_colors.dart';
import '../../domain/entities/event_entity.dart';


class EventDetailsModal extends StatelessWidget {
  final EventEntity event;


  final Map<int, dynamic> usersById;

  final void Function(EventEntity) onEdit;
  final void Function(int) onDelete;

  const EventDetailsModal({
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
      expand: false,
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
            // ── Handle ──
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

            // ── Header row: badge + close ──
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
                      Text(_getTypeIcon(event.eventType), style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text(event.eventType.toUpperCase(), style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: tc.text,
                      )),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(event.title, style: theme.textTheme.displayMedium),
            const SizedBox(height: 20),

            _detailRow('🕐', 'Date & Time', Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatFullDate(event.start), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${_fmtTime(event.start)} – ${_fmtTime(event.end)}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              ],
            )),

            if (event.description.isNotEmpty)
              _detailRow('📝', 'Description', Text(event.description, style: const TextStyle(fontSize: 13))),

            if (event.meetingLink.isNotEmpty)
              _detailRow('🔗', 'Meeting Link', GestureDetector(
                onTap: () => _launch(event.meetingLink),
                child: Text(event.meetingLink, style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary,
                  decoration: TextDecoration.underline,
                )),
              )),

            // ── Participants ──
            if (event.participants.isNotEmpty)
              _detailRow('👥', 'Participants', Wrap(
                spacing: 8,
                runSpacing: 6,
                children: event.participants.map((uid) {

                  final userData = usersById[uid];


                  final String name = userData?.name ?? 'Unknown';
                  final initials = _getInitials(name);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary,
                        child: Text(initials, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Text(name, style: const TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              )),

            _detailRow('🔔', 'Reminder', Text(
              '${event.reminderBefore} minutes before',
              style: const TextStyle(fontSize: 13),
            )),

            const SizedBox(height: 24),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.dangerBorder, width: 1.5),
                    foregroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _confirmDelete(context),
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Row(children: [
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
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  String _getInitials(String name) {
    if (name.isEmpty || name == 'Unknown') return "?";
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'meeting': return '🤝';
      case 'call': return '📞';
      case 'task': return '✅';
      case 'followup': return '🔁';
      default: return '📅';
    }
  }

  static Widget _detailRow(String icon, String label, Widget content) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6)),
            const SizedBox(height: 2),
            content,
          ],
        )),
      ],
    ),
  );

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
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

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour >= 12 ? "PM" : "AM"}';
  }

  static String _formatFullDate(DateTime dt) {
    final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class EventTypeColor {
  final Color text;
  final Color bg;
  final Color border;

  const EventTypeColor({required this.text, required this.bg, required this.border});

  static EventTypeColor of(String type) {
    const map = {
      'meeting': EventTypeColor(text: AppColors.meetingText, bg: AppColors.meetingBg, border: AppColors.meetingBorder),
      'call':    EventTypeColor(text: AppColors.callText,    bg: AppColors.callBg,    border: AppColors.callBorder),
      'followup':EventTypeColor(text: AppColors.followUpText,bg: AppColors.followUpBg,border: AppColors.followUpBorder),
      'task':    EventTypeColor(text: AppColors.taskText,    bg: AppColors.taskBg,    border: AppColors.taskBorder),
    };
    return map[type.toLowerCase()] ?? map['meeting']!;
  }
}