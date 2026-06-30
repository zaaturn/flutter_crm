import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/datasources/calendar_remote_datasource.dart';
import '../../domain/entities/calendar_grid_event.dart';

Future<void> showCalendarEventPopover(
  BuildContext context, {
  required CalendarGridEvent event,
  required CalendarRemoteDataSource dataSource,
  required VoidCallback onChanged,
  required VoidCallback onEdit,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              event.title,
              style: TextStyle(
                decoration:
                    event.isCancelled ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (event.isCancelled)
            const Chip(
              label: Text('CANCELLED'),
              backgroundColor: Color(0xFFFEE2E2),
            ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _badge(event.eventType),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('EEE, MMM d · h:mm a').format(event.startTime.toLocal())} – ${DateFormat('h:mm a').format(event.endTime.toLocal())}',
            ),
            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('📍 ${event.location}'),
            ],
            if (event.taskStatus != null) ...[
              const SizedBox(height: 6),
              Text('Status: ${event.taskStatus}'),
            ],
            if (event.priority != null) ...[
              const SizedBox(height: 4),
              Text('Priority: ${event.priority}'),
            ],
          ],
        ),
      ),
      actions: [
        if (!event.isTaskApiId) ...[
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              onEdit();
            },
            child: const Text('Edit'),
          ),
          if (event.eventType == 'task' && !event.isCancelled)
            TextButton(
              onPressed: () async {
                await dataSource.completeEvent(event.id);
                if (ctx.mounted) Navigator.pop(ctx);
                onChanged();
              },
              child: const Text('Mark complete'),
            ),
          if (!event.isCancelled)
            TextButton(
              onPressed: () async {
                await dataSource.cancelEvent(event.id);
                if (ctx.mounted) Navigator.pop(ctx);
                onChanged();
              },
              child: const Text('Cancel'),
            ),
          if (event.isCancelled)
            TextButton(
              onPressed: () async {
                await dataSource.restoreEvent(event.id);
                if (ctx.mounted) Navigator.pop(ctx);
                onChanged();
              },
              child: const Text('Restore'),
            ),
          TextButton(
            onPressed: () async {
              await dataSource.duplicateEvent(event.id);
              if (ctx.mounted) Navigator.pop(ctx);
              onChanged();
            },
            child: const Text('Duplicate'),
          ),
        ],
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
      ],
    ),
  );
}

Widget _badge(String type) {
  return Chip(
    label: Text(type[0].toUpperCase() + type.substring(1)),
    visualDensity: VisualDensity.compact,
  );
}
