import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/scaffold_messenger_scope.dart';
import 'package:my_app/event_management/core/entities/user.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_composer_mobile_ui.dart';
import 'package:my_app/event_management/features/events/presentation/utils/event_snackbar.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/event_create/event_create_date_picker.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/event_create/event_create_dialogs.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/participant_picker.dart';
import 'package:uuid/uuid.dart';

class EventCreateScreenMobile extends StatefulWidget {
  final DateTime? prefillDate;
  final String? prefillTitle;

  const EventCreateScreenMobile({
    super.key,
    this.prefillDate,
    this.prefillTitle,
  });

  @override
  State<EventCreateScreenMobile> createState() => _EventCreateScreenMobileState();
}

class _EventCreateScreenMobileState extends State<EventCreateScreenMobile> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  late DateTime _startTime;
  late DateTime _endTime;
  bool _isAllDay = false;
  EventType _eventType = EventType.meeting;
  RecurrenceRule _recurrence = RecurrenceRule.none;
  List<Participant> _participants = [];
  List<int> _reminderMinutes = [30];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final base = widget.prefillDate ?? DateTime.now();
    final now = DateTime.now();
    _startTime = DateTime(base.year, base.month, base.day, now.hour + 1, 0);
    _endTime = _startTime.add(const Duration(hours: 1));
    if (widget.prefillTitle != null) {
      _titleCtrl.text = widget.prefillTitle!;
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
      listenWhen: (_, s) =>
          s is EventCreated || s is EventError || s is EventConflictDetected,
      listener: (ctx, state) {
        if (!ctx.mounted) return;
        if (state is EventCreated) {
          setState(() => _isSaving = false);
          try {
            ctx.read<CalendarBloc>().add(CalendarRefreshRequested());
          } catch (_) {}
          try {
            ctx.read<DashboardBloc>().add(DashboardRefreshRequested());
          } catch (_) {}
          popRouteThenShowSnackBar(
            ctx,
            SnackBar(content: Text('Event "${state.event.title}" created!')),
          );
        } else if (state is EventConflictDetected) {
          setState(() => _isSaving = false);
          EventCreateDialogs.showConflict(ctx, state);
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
                  title: 'Create Event',
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
    final result = await showModalBottomSheet<List<Participant>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ParticipantPicker(selected: _participants),
    );
    if (result != null) setState(() => _participants = result);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    const createdBy = User(id: 'local', username: 'You', email: '');
    final event = Event(
      id: const Uuid().v4(),
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
      reminders: _reminderMinutes
          .map((m) => EventReminder(id: 0, minutesBefore: m))
          .toList(),
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<EventBloc>().add(CreateEventRequested(event: event));
  }
}
