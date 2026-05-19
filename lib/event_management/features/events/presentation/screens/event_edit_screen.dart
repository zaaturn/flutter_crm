import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/scaffold_messenger_scope.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import '../../domain/entities/event.dart';
import '../bloc/event_bloc.dart';
import '../widgets/event_create/event_alert_me_card.dart';
import '../widgets/event_create/event_color_override_card.dart';
import '../widgets/event_create/event_create_app_bar.dart';
import '../widgets/event_create/event_create_constants.dart';
import '../widgets/event_create/event_create_date_picker.dart';
import '../widgets/event_create/event_create_dialogs.dart';
import '../widgets/event_create/event_details_card.dart';
import '../widgets/event_create/event_inspiration_card.dart';
import '../widgets/event_create/event_schedule_card.dart';
import '../widgets/event_create/event_settings_card.dart';
import '../utils/event_snackbar.dart';
import '../widgets/event_create/event_type_of_entry_section.dart';
import '../widgets/participant_picker.dart';

/// Edit event: same layout and theme as [EventCreateScreen].
class EventEditScreen extends StatefulWidget {
  final String eventId;
  final Event? event;

  const EventEditScreen({
    required this.eventId,
    this.event,
    super.key,
  });

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
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
  late String _colorOverride;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _meetingLinkCtrl = TextEditingController(text: e?.meetingLink ?? '');
    _startTime =
        e?.startTime ?? DateTime.now().add(const Duration(hours: 1));
    _endTime = e?.endTime ?? _startTime.add(const Duration(hours: 1));
    _isAllDay = e?.isAllDay ?? false;
    _eventType = e?.type ?? EventType.meeting;
    _recurrence = e?.recurrence ?? RecurrenceRule.none;
    _participants = List<Participant>.from(e?.participants ?? []);
    _reminderMinutes =
        e?.reminders.map((r) => r.minutesBefore).toList() ?? [];
    _colorOverride = e?.colorOverride ?? '';
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
            SnackBar(
              content: Text('Event "${state.event.title}" updated'),
            ),
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
        backgroundColor: EventCreateLayout.surfaceColor,
        appBar: EventCreateAppBar(
          isSaving: _isSaving,
          onSave: _submit,
          saveButtonLabel: 'Update',
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= EventCreateLayout.wideBreakpoint;
            return Form(
              key: _formKey,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: EventCreateLayout.maxContentWidth,
                  ),
                  child: wide
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 13,
                                child: _buildLeftColumn(context),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 11,
                                child: _buildRightColumn(context),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLeftColumn(context),
                              const SizedBox(height: 20),
                              _buildRightColumn(context),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EventTypeOfEntrySection(
          selected: _eventType,
          onChanged: (t) => setState(() {
            _eventType = t;
            _colorOverride = '';
          }),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _titleCtrl,
          autofocus: widget.event == null,
          textCapitalization: TextCapitalization.sentences,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
          decoration: const InputDecoration(
            hintText: 'Untitled Event',
            hintStyle: TextStyle(
              color: AppTheme.textHint,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title is required' : null,
        ),
        const SizedBox(height: 20),
        EventScheduleCard(
          isAllDay: _isAllDay,
          onAllDayChanged: _onAllDayChanged,
          start: _startTime,
          end: _endTime,
          onPickStartDate: () => _pickDate(isStart: true),
          onPickStartTime: () => _pickDate(isStart: true, timeOnly: true),
          onPickEndDate: () => _pickDate(isStart: false),
          onPickEndTime: () => _pickDate(isStart: false, timeOnly: true),
        ),
        const SizedBox(height: 20),
        EventDetailsCard(controller: _descCtrl),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EventSettingsCard(
          recurrenceLabel: _recurrence == RecurrenceRule.none
              ? 'Never'
              : _recurrence.name[0].toUpperCase() +
                  _recurrence.name.substring(1),
          onRepeatTap: _pickRecurrence,
          participants: _participants,
          onGuestsTap: _pickParticipants,
          meetingLink: _meetingLinkCtrl.text,
          onConferenceTap: _editConferenceLink,
          location: _locationCtrl.text,
          onLocationTap: _editLocation,
        ),
        const SizedBox(height: 16),
        EventColorOverrideCard(
          colorOverrideHex: _colorOverride,
          onSelected: (hex) => setState(() => _colorOverride = hex),
          onReset: () => setState(() => _colorOverride = ''),
        ),
        const SizedBox(height: 16),
        EventAlertMeCard(
          selected: _reminderMinutes,
          onChanged: (r) => setState(() => _reminderMinutes = r),
        ),
        const SizedBox(height: 16),
        const EventInspirationCard(),
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

  Future<void> _pickDate({required bool isStart, bool timeOnly = false}) {
    return EventCreateDateTimePicker.pick(
      context: context,
      isAllDay: _isAllDay,
      isStart: isStart,
      timeOnly: timeOnly,
      startTime: _startTime,
      endTime: _endTime,
      onApply: (s, e) => setState(() {
        _startTime = s;
        _endTime = e;
      }),
    );
  }

  Future<void> _pickRecurrence() async {
    final result = await EventCreateDialogs.pickRecurrence(context);
    if (result != null) setState(() => _recurrence = result);
  }

  Future<void> _pickParticipants() async {
    final result = await showModalBottomSheet<List<Participant>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ParticipantPicker(selected: _participants),
    );
    if (result != null) setState(() => _participants = result);
  }

  Future<void> _editConferenceLink() {
    return EventCreateDialogs.editConferenceLink(
      context,
      meetingLinkCtrl: _meetingLinkCtrl,
      onSaved: () => setState(() {}),
    );
  }

  Future<void> _editLocation() {
    return EventCreateDialogs.editLocation(
      context,
      locationCtrl: _locationCtrl,
      onSaved: () => setState(() {}),
    );
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
      colorOverride: _colorOverride,
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
