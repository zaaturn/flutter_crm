import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/event.dart';
import '../../bloc/event_bloc.dart';

/// Simple dialogs used from [EventCreateScreen].
abstract final class EventCreateDialogs {
  static void _safePop<T>(BuildContext ctx, [T? result]) {
    // Avoid popping while keyboard/focus is mid-update. Microtask is enough and
    // avoids an extra frame where dialog is still "alive" (can trigger dependents assertion).
    FocusManager.instance.primaryFocus?.unfocus();
    Future<void>.microtask(() {
      if (!ctx.mounted) return;
      final nav = Navigator.of(ctx, rootNavigator: true);
      if (nav.canPop()) nav.pop<T>(result);
    });
  }

  static Future<RecurrenceRule?> pickRecurrence(BuildContext context) {
    return showDialog<RecurrenceRule>(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        title: const Text('Repeat'),
        children: RecurrenceRule.values.map((r) {
          final label = r == RecurrenceRule.none
              ? 'Never'
              : '${r.name[0].toUpperCase()}${r.name.substring(1)}';
          return SimpleDialogOption(
            onPressed: () => _safePop(dialogCtx, r),
            child: Text(label),
          );
        }).toList(),
      ),
    );
  }

  static Future<void> editConferenceLink(
    BuildContext context, {
    required TextEditingController meetingLinkCtrl,
    required VoidCallback onSaved,
  }) async {
    final ctrl = TextEditingController(text: meetingLinkCtrl.text);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conference link'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://…',
            border: OutlineInputBorder(),
          ),
          autofocus: false,
        ),
        actions: [
          TextButton(
            onPressed: () => _safePop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _safePop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      meetingLinkCtrl.text = ctrl.text.trim();
      onSaved();
    }
    ctrl.dispose();
  }

  static Future<void> editLocation(
    BuildContext context, {
    required TextEditingController locationCtrl,
    required VoidCallback onSaved,
  }) async {
    final ctrl = TextEditingController(text: locationCtrl.text);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Add address or place',
            border: OutlineInputBorder(),
          ),
          autofocus: false,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => _safePop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _safePop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final next = ctrl.text.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        locationCtrl.text = next;
        onSaved();
      });
    }
    ctrl.dispose();
  }

  static void showConflict(
    BuildContext context,
    EventConflictDetected state,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Scheduling conflict'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This event overlaps with:'),
            const SizedBox(height: 8),
            ...state.conflicting.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                              '0xFF${e.displayColor.replaceAll('#', '')}')),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        e.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            const Text('Save anyway?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _safePop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _safePop(dialogCtx);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                context.read<EventBloc>().add(
                      ConflictConfirmed(event: state.pendingEvent),
                    );
              });
            },
            child: const Text('Save anyway'),
          ),
        ],
      ),
    );
  }
}
