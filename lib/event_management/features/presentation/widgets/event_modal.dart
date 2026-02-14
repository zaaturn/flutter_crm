import 'package:flutter/material.dart';
import 'package:my_app/event_management/core/constants/app_colors.dart';

import '../../domain/entities/event_entity.dart';
import 'mock_data.dart';
import 'type_selector.dart';

/// Full Create / Edit form shown as a bottom-sheet modal.
/// Pass [initialEvent] to pre-fill (edit mode); leave null for create mode.
class EventModal extends StatefulWidget {
  final EventEntity? initialEvent;
  final DateTime? selectedDateTime; // from slot tap – pre-fills start
  final void Function(EventEntity) onSave;

  const EventModal({
    super.key,
    this.initialEvent,
    this.selectedDateTime,
    required this.onSave,
  });

  @override
  State<EventModal> createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  // ── Form state ──
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _linkCtrl;
  late DateTime _start;
  late DateTime _end;
  late String _eventType;
  late List<int> _participants;
  late int _reminderBefore;

  @override
  void initState() {
    super.initState();
    final ev = widget.initialEvent;
    final slot = widget.selectedDateTime;

    _titleCtrl = TextEditingController(text: ev?.title ?? '');
    _descCtrl = TextEditingController(text: ev?.description ?? '');
    _linkCtrl = TextEditingController(text: ev?.meetingLink ?? '');

    _start = ev?.start ?? slot ?? DateTime.now();
    _end = ev?.end ?? (_start.add(const Duration(hours: 1)));
    _eventType = ev?.eventType ?? 'meeting';
    _participants = List<int>.from(ev?.participants ?? []);
    _reminderBefore = ev?.reminderBefore ?? 30;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.initialEvent?.id != null;

  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
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
              child: Container(width: 36, height: 4, decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(2),
              )),
            ),
            const SizedBox(height: 14),

            // ── Header ──
            _modalHeader(theme),
            const SizedBox(height: 20),

            // ── Title ──
            _labelText('Title'),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Event title…'),
            ),
            const SizedBox(height: 16),

            // ── Type Selector ──
            _labelText('Event Type'),
            TypeSelector(
              selected: _eventType,
              onChanged: (v) => setState(() => _eventType = v),
            ),
            const SizedBox(height: 16),

            // ── Start / End ──
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _labelText('Start'),
                _dateTimePicker(_start, (v) => setState(() => _start = v)),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _labelText('End'),
                _dateTimePicker(_end, (v) => setState(() => _end = v)),
              ])),
            ]),
            const SizedBox(height: 16),

            // ── Description ──
            _labelText('Description'),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add details…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // ── Meeting Link ──
            _labelText('Meeting Link'),
            TextField(
              controller: _linkCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(hintText: 'https://meet.google.com/…'),
            ),
            const SizedBox(height: 16),

            // ── Participants ──
            _labelText('Participants'),
            _participantDropdown(),
            if (_participants.isNotEmpty) ...[
              const SizedBox(height: 8),
              _participantChips(),
            ],
            const SizedBox(height: 16),

            // ── Reminder ──
            _labelText('Reminder'),
            _reminderDropdown(),
            const SizedBox(height: 28),

            // ── Actions ──
            _actionButtons(theme),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Sub-builders
  // ─────────────────────────────────────────────

  Widget _modalHeader(ThemeData theme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        _isEditing ? 'Edit Event' : 'New Event',
        style: theme.textTheme.displaySmall,
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
  );

  Widget _labelText(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(label.toUpperCase(), style: const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6,
    )),
  );

  Widget _dateTimePicker(DateTime current, ValueChanged<DateTime> onPick) {
    return GestureDetector(
      onTap: () async {
        // ── Date first ──
        final date = await showDatePicker(
          context: context,
          initialDate: current,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date == null || !mounted) return;

        // ── Time second ──
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(current),
        );
        if (time == null || !mounted) return;

        onPick(DateTime(date.year, date.month, date.day, time.hour, time.minute));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Text(
          _fmtDateTime(current),
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _participantDropdown() {
    final available = MOCK_USERS.where((u) => !_participants.contains(u.id)).toList();
    return DropdownButtonFormField<int>(
      value: null,
      hint: const Text('Add participant…'),
      decoration: const InputDecoration(isDense: true),
      items: available.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
      onChanged: (id) {
        if (id != null) setState(() => _participants.add(id));
      },
    );
  }

  Widget _participantChips() => Wrap(
    spacing: 6,
    children: _participants.map((uid) {
      final u = MOCK_USERS.firstWhere((x) => x.id == uid, orElse: () => const MockUser(id: -1, name: '?', initials: '?'));
      return Chip(
        avatar: CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.primary,
          child: Text(u.initials, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        label: Text(u.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
        backgroundColor: AppColors.primaryExtraLight,
        deleteIconColor: AppColors.primary.withOpacity(0.6),
        onDeleted: () => setState(() => _participants.remove(uid)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      );
    }).toList(),
  );

  Widget _reminderDropdown() => DropdownButtonFormField<int>(
    value: _reminderBefore,
    decoration: const InputDecoration(isDense: true),
    items: REMINDER_LABELS.entries
        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
        .toList(),
    onChanged: (v) {
      if (v != null) setState(() => _reminderBefore = v);
    },
  );

  Widget _actionButtons(ThemeData theme) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: _titleCtrl.text.trim().isEmpty ? null : _handleSave,
        child: Text(_isEditing ? 'Save Changes' : 'Create Event'),
      ),
    ],
  );

  void _handleSave() {
    final entity = EventEntity(
      id: widget.initialEvent?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      start: _start,
      end: _end,
      meetingLink: _linkCtrl.text.trim(),
      eventType: _eventType,
      participants: _participants,
      reminderBefore: _reminderBefore,
    );
    widget.onSave(entity);
    Navigator.pop(context);
  }

  // ─── Formatting helpers ───
  static String _fmtDateTime(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$m $ampm';
  }
}