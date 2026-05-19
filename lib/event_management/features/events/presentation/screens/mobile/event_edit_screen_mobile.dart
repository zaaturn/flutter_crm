import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/core/scaffold_messenger_scope.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';

import '../../../domain/entities/event.dart';
import '../../bloc/event_bloc.dart';
import '../../utils/event_snackbar.dart';
import '../../widgets/participant_picker.dart';

class _ZaaturnEditUI {
  static const Color bg = Color(0xFFFAF3E0);
  static const Color terracotta = Color(0xFFC05E41);
  static const Color card = Color(0xFFEADBC8);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textMuted = Color(0xFF8D6E63);
}

class EventEditScreenMobile extends StatefulWidget {
  final String eventId;
  final Event? event;

  const EventEditScreenMobile({
    required this.eventId,
    this.event,
    super.key,
  });

  @override
  State<EventEditScreenMobile> createState() => _EventEditScreenMobileState();
}

class _EventEditScreenMobileState extends State<EventEditScreenMobile> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _meetingLinkCtrl;

  late DateTime _startTime;
  late DateTime _endTime;
  late bool _isAllDay;
  late EventType _eventType;
  late RecurrenceRule _recurrence;
  late List<Participant> _participants;
  late List<int> _reminderMinutes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _meetingLinkCtrl = TextEditingController(text: e?.meetingLink ?? '');
    _startTime = e?.startTime ?? DateTime.now().add(const Duration(hours: 1));
    _endTime = e?.endTime ?? _startTime.add(const Duration(hours: 1));
    _isAllDay = e?.isAllDay ?? false;
    _eventType = e?.type ?? EventType.meeting;
    _recurrence = e?.recurrence ?? RecurrenceRule.none;
    _participants = List<Participant>.from(e?.participants ?? []);
    _reminderMinutes = e?.reminders.map((r) => r.minutesBefore).toList() ?? [30];
    if (_reminderMinutes.isEmpty) _reminderMinutes = [30];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _meetingLinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listenWhen: (_, s) => s is EventUpdated || s is EventError,
      listener: (ctx, state) {
        if (!ctx.mounted) return;
        if (state is EventUpdated) {
          setState(() => _isSaving = false);
          try {
            ctx.read<CalendarBloc>().add(CalendarRefreshRequested());
          } catch (_) {}
          try {
            ctx.read<DashboardBloc>().add(DashboardRefreshRequested());
          } catch (_) {}
          popRouteThenShowSnackBar(
            ctx,
            SnackBar(content: Text('Event "${state.event.title}" updated')),
          );
        } else if (state is EventError) {
          setState(() => _isSaving = false);
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _ZaaturnEditUI.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(
                title: 'Edit Event',
                isSaving: _isSaving,
                onBack: () => Navigator.of(context).maybePop(),
                onSave: _submit,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CreamCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Event title',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _ZaaturnEditUI.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _titleCtrl,
                                textCapitalization: TextCapitalization.sentences,
                                style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: _ZaaturnEditUI.textDark,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Untitled Event',
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.55),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Title is required'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              _pillRow(
                                label: 'Type',
                                child: DropdownButtonFormField<EventType>(
                                  value: _eventType,
                                  dropdownColor: Colors.white,
                                  decoration: _pillDecoration(),
                                  items: EventType.values
                                      .map((t) => DropdownMenuItem(
                                            value: t,
                                            child: Text(t.label),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _eventType = v ?? EventType.meeting),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _pillRow(
                                label: 'All day',
                                child: Switch.adaptive(
                                  value: _isAllDay,
                                  activeColor: _ZaaturnEditUI.terracotta,
                                  onChanged: (v) => _onAllDayChanged(v),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CreamCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionTitle(icon: Icons.schedule_rounded, title: 'Schedule'),
                              const SizedBox(height: 12),
                              _DateTimeTile(
                                label: 'Starts',
                                dateTime: _startTime,
                                showTime: !_isAllDay,
                                onTap: () => _pickDateTime(isStart: true),
                              ),
                              const SizedBox(height: 10),
                              _DateTimeTile(
                                label: 'Ends',
                                dateTime: _endTime,
                                showTime: !_isAllDay,
                                onTap: () => _pickDateTime(isStart: false),
                              ),
                              const SizedBox(height: 10),
                              _pillRow(
                                label: 'Repeat',
                                child: DropdownButtonFormField<RecurrenceRule>(
                                  value: _recurrence,
                                  dropdownColor: Colors.white,
                                  decoration: _pillDecoration(),
                                  items: RecurrenceRule.values
                                      .map((r) => DropdownMenuItem(
                                            value: r,
                                            child: Text(_recurrenceLabel(r)),
                                          ))
                                      .toList(),
                                  onChanged: (v) => setState(
                                      () => _recurrence = v ?? RecurrenceRule.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CreamCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionTitle(icon: Icons.place_rounded, title: 'Location'),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _locationCtrl,
                                decoration: _pillDecoration().copyWith(
                                  hintText: 'Add location (optional)',
                                ),
                              ),
                              const SizedBox(height: 12),
                              _SectionTitle(icon: Icons.videocam_rounded, title: 'Meeting link'),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _meetingLinkCtrl,
                                keyboardType: TextInputType.url,
                                decoration: _pillDecoration().copyWith(
                                  hintText: 'Paste meeting link (optional)',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CreamCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionTitle(icon: Icons.group_rounded, title: 'Guests'),
                              const SizedBox(height: 10),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _ZaaturnEditUI.terracotta,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _pickParticipants,
                                child: Text(
                                  _participants.isEmpty
                                      ? 'Add guests'
                                      : 'Edit guests (${_participants.length})',
                                  style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                                ),
                              ),
                              if (_participants.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _participants
                                      .map(
                                        (p) => Chip(
                                          label: Text(p.username),
                                          backgroundColor: Colors.white.withValues(alpha: 0.65),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: _ZaaturnEditUI.terracotta.withValues(alpha: 0.25),
                                            ),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CreamCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionTitle(icon: Icons.notifications_rounded, title: 'Reminders'),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: const [10, 30, 60, 1440]
                                    .map((m) => _ReminderChip(minutes: m))
                                    .toList(growable: false),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CreamCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionTitle(icon: Icons.subject_rounded, title: 'Description'),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _descCtrl,
                                minLines: 4,
                                maxLines: 8,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  hintText: 'Add notes…',
                                  hintStyle: TextStyle(
                                    color: _ZaaturnEditUI.textMuted.withValues(alpha: 0.8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.55),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _recurrenceLabel(RecurrenceRule r) {
    switch (r) {
      case RecurrenceRule.none:
        return 'Never';
      case RecurrenceRule.daily:
        return 'Daily';
      case RecurrenceRule.weekly:
        return 'Weekly';
      case RecurrenceRule.monthly:
        return 'Monthly';
    }
  }

  InputDecoration _pillDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.55),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _pillRow({required String label, required Widget child}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              color: _ZaaturnEditUI.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 190, child: child),
      ],
    );
  }

  void _onAllDayChanged(bool v) {
    setState(() {
      _isAllDay = v;
      if (v) {
        final d = DateTime(_startTime.year, _startTime.month, _startTime.day);
        _startTime = d;
        var endDay = DateTime(_endTime.year, _endTime.month, _endTime.day);
        if (!endDay.isAfter(d) && !endDay.isAtSameMomentAs(d)) {
          endDay = d;
        }
        _endTime = DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59);
      }
    });
  }

  Future<void> _pickParticipants() async {
    final result = await showModalBottomSheet<List<Participant>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ParticipantPicker(selected: _participants),
    );
    if (result != null) setState(() => _participants = result);
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: _ZaaturnEditUI.terracotta,
                onPrimary: Colors.white,
                surface: _ZaaturnEditUI.bg,
                onSurface: _ZaaturnEditUI.textDark,
              ),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null) return;

    TimeOfDay? pickedTime;
    if (!_isAllDay) {
      pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _ZaaturnEditUI.terracotta,
                  onPrimary: Colors.white,
                  surface: _ZaaturnEditUI.bg,
                  onSurface: _ZaaturnEditUI.textDark,
                ),
          ),
          child: child!,
        ),
      );
      if (pickedTime == null) return;
    }

    setState(() {
      final dt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 0,
        pickedTime?.minute ?? 0,
      );
      if (isStart) {
        _startTime = dt;
        if (!_endTime.isAfter(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      } else {
        _endTime = dt;
        if (!_endTime.isAfter(_startTime)) {
          _startTime = _endTime.subtract(const Duration(hours: 1));
        }
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.event == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Original event data missing')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final originalReminders = widget.event!.reminders;
    final reminders = _reminderMinutes.map((m) {
      try {
        final existing =
            originalReminders.firstWhere((r) => r.minutesBefore == m);
        return EventReminder(id: existing.id, minutesBefore: m);
      } catch (_) {
        return EventReminder(id: 0, minutesBefore: m);
      }
    }).toList();

    final updated = widget.event!.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      isAllDay: _isAllDay,
      type: _eventType,
      meetingLink: _meetingLinkCtrl.text.trim().isNotEmpty
          ? _meetingLinkCtrl.text.trim()
          : null,
      location: _locationCtrl.text.trim().isNotEmpty
          ? _locationCtrl.text.trim()
          : null,
      recurrence: _recurrence,
      participants: _participants,
      reminders: reminders,
      updatedAt: DateTime.now(),
    );

    context.read<EventBloc>().add(UpdateEventRequested(event: updated));
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onSave;

  const _TopBar({
    required this.title,
    required this.isSaving,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _ZaaturnEditUI.bg,
      padding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _ZaaturnEditUI.textDark, size: 20),
          ),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _ZaaturnEditUI.textDark,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: _ZaaturnEditUI.terracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Update',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CreamCard extends StatelessWidget {
  final Widget child;
  const _CreamCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ZaaturnEditUI.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _ZaaturnEditUI.terracotta.withValues(alpha: 0.12),
        ),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _ZaaturnEditUI.terracotta, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: _ZaaturnEditUI.textDark,
          ),
        ),
      ],
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final DateTime dateTime;
  final bool showTime;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.label,
    required this.dateTime,
    required this.showTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = MaterialLocalizations.of(context).formatMediumDate(dateTime);
    final timeStr = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(dateTime),
      alwaysUse24HourFormat: false,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: _ZaaturnEditUI.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    showTime ? '$dateStr • $timeStr' : dateStr,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      color: _ZaaturnEditUI.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_calendar_rounded,
                color: _ZaaturnEditUI.terracotta.withValues(alpha: 0.9)),
          ],
        ),
      ),
    );
  }
}

class _ReminderChip extends StatefulWidget {
  final int minutes;
  const _ReminderChip({required this.minutes});

  @override
  State<_ReminderChip> createState() => _ReminderChipState();
}

class _ReminderChipState extends State<_ReminderChip> {
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_EventEditScreenMobileState>();
    final selected = state?._reminderMinutes.contains(widget.minutes) ?? false;
    final label = EventReminder(id: 0, minutesBefore: widget.minutes).label;

    return FilterChip(
      selected: selected,
      label: Text(label),
      labelStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        color: selected ? Colors.white : _ZaaturnEditUI.textDark,
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.55),
      selectedColor: _ZaaturnEditUI.terracotta,
      onSelected: (v) {
        if (state == null) return;
        state.setState(() {
          final list = List<int>.from(state._reminderMinutes);
          if (v) {
            if (!list.contains(widget.minutes)) list.add(widget.minutes);
          } else {
            list.remove(widget.minutes);
          }
          list.sort();
          state._reminderMinutes = list;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: _ZaaturnEditUI.terracotta.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

