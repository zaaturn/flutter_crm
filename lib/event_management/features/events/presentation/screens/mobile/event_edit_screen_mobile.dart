import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/scaffold_messenger_scope.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_composer_mobile_ui.dart';
import 'package:my_app/event_management/features/events/presentation/utils/event_snackbar.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/event_create/event_create_date_picker.dart';
import 'package:my_app/services/secure_storage_service.dart';

import 'package:my_app/event_management/features/events/presentation/widgets/participant_picker.dart';

class EventEditScreenMobile extends StatefulWidget {
  final String eventId;
  final Event? event;

  const EventEditScreenMobile({
    super.key,
    required this.eventId,
    this.event,
  });

  @override
  State<EventEditScreenMobile> createState() => _EventEditScreenMobileState();
}

class _EventEditScreenMobileState extends State<EventEditScreenMobile> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;

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
    _startTime = e?.startTime ?? DateTime.now().add(const Duration(hours: 1));
    _endTime = e?.endTime ?? _startTime.add(const Duration(hours: 1));
    _isAllDay = e?.isAllDay ?? false;
    _eventType = e?.type ?? EventType.meeting;
    _recurrence = e?.recurrence ?? RecurrenceRule.none;
    _participants = List<Participant>.from(e?.participants ?? []);
    _reminderMinutes =
        e?.reminders.map((r) => r.minutesBefore).toList() ?? [30];
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureOwner());
  }

  Future<void> _ensureOwner() async {
    final e = widget.event;
    if (e == null || !mounted) return;
    final uid = await SecureStorageService().readUserId();
    if (!mounted) return;
    if (!e.isOwnedBy(uid)) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only the event host can edit this event'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
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
        backgroundColor: ZaaturnComposerUI.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                EventComposerMobileHeader(
                  title: 'Edit Event',
                  saveLabel: 'Save',
                  isSaving: _isSaving,
                  onSave: _submit,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      _buildDetailsCard(),
                      _buildScheduleCard(),
                      _buildLocationCard(),
                      _buildGuestsCard(),
                      _buildRemindersCard(),
                      _buildDescriptionCard(),
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

  Widget _buildDetailsCard() {
    return EventComposerSectionCard(
      icon: Icons.event_rounded,
      title: 'Event details',
      children: [
        const EventComposerFieldLabel('Event title'),
        EventComposerTextField(
          controller: _titleCtrl,
          hint: 'Untitled Event',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EventComposerFieldLabel('Type'),
                  DropdownButtonFormField<EventType>(
                    value: _eventType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ZaaturnComposerUI.field,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: EventType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _eventType = v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EventComposerFieldLabel('All day'),
                Switch.adaptive(
                  value: _isAllDay,
                  activeColor: ZaaturnComposerUI.terracotta,
                  onChanged: _onAllDayChanged,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleCard() {
    return EventComposerSectionCard(
      icon: Icons.schedule_rounded,
      title: 'Schedule',
      children: [
        EventComposerScheduleRow(
          label: 'Starts',
          value: _startTime,
          allDay: _isAllDay,
          onTap: () => _pickDate(isStart: true),
        ),
        EventComposerScheduleRow(
          label: 'Ends',
          value: _endTime,
          allDay: _isAllDay,
          onTap: () => _pickDate(isStart: false),
        ),
        const EventComposerFieldLabel('Repeat'),
        DropdownButtonFormField<RecurrenceRule>(
          value: _recurrence,
          decoration: InputDecoration(
            filled: true,
            fillColor: ZaaturnComposerUI.field,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          items: RecurrenceRule.values
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(recurrenceLabel(r)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _recurrence = v);
          },
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return EventComposerSectionCard(
      icon: Icons.location_on_rounded,
      title: 'Location',
      children: [
        EventComposerTextField(
          controller: _locationCtrl,
          hint: 'Add location (optional)',
        ),
      ],
    );
  }

  Widget _buildGuestsCard() {
    return EventComposerSectionCard(
      icon: Icons.people_rounded,
      title: 'Guests',
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _pickParticipants,
            style: FilledButton.styleFrom(
              backgroundColor: ZaaturnComposerUI.terracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _participants.isEmpty
                  ? 'Add guests'
                  : '${_participants.length} guest(s) added',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersCard() {
    return EventComposerSectionCard(
      icon: Icons.notifications_rounded,
      title: 'Reminders',
      children: [
        EventComposerReminderChips(
          selected: _reminderMinutes,
          onChanged: (r) => setState(() => _reminderMinutes = r),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return EventComposerSectionCard(
      icon: Icons.notes_rounded,
      title: 'Description',
      children: [
        EventComposerTextField(
          controller: _descCtrl,
          hint: 'Add notes...',
          maxLines: 4,
        ),
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

  Future<void> _pickDate({required bool isStart}) {
    return EventCreateDateTimePicker.pick(
      context: context,
      isAllDay: _isAllDay,
      isStart: isStart,
      timeOnly: false,
      startTime: _startTime,
      endTime: _endTime,
      onApply: (s, e) => setState(() {
        _startTime = s;
        _endTime = e;
      }),
    );
  }

  Future<void> _pickParticipants() async {
    final result = await showParticipantPicker(
      context,
      selected: _participants,
    );
    if (result != null) setState(() => _participants = result);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.event == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Original event data missing')),
      );
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
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
