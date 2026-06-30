import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/scaffold_messenger_scope.dart';
import 'package:my_app/event_management/core/entities/user.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/event.dart';
import '../bloc/event_bloc.dart';
import '../widgets/event_create/event_alert_me_card.dart';
import '../widgets/event_create/event_create_app_bar.dart';
import '../widgets/event_create/event_create_constants.dart';
import '../widgets/event_create/event_create_date_picker.dart';
import '../widgets/event_create/event_create_dialogs.dart';
import '../widgets/event_create/event_details_card.dart';
import '../widgets/event_create/event_schedule_card.dart';
import '../widgets/event_create/event_settings_card.dart';
import '../widgets/event_create/event_type_of_entry_section.dart';
import '../widgets/participant_picker.dart';
import '../utils/event_snackbar.dart';

class EventCreateScreen extends StatefulWidget {
  final DateTime? prefillDate;
  final String? prefillTitle;

  const EventCreateScreen({
    super.key,
    this.prefillDate,
    this.prefillTitle,
  });

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _meetingLinkCtrl = TextEditingController();

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
    _meetingLinkCtrl.dispose();
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
        backgroundColor: EventCreateLayout.surfaceColor,
        appBar: EventCreateAppBar(
          isSaving: _isSaving,
          onSave: _submit,
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
                                  flex: 13, child: _buildLeftColumn(context)),
                              const SizedBox(width: 28),
                              Expanded(
                                  flex: 11, child: _buildRightColumn(context)),
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
          onChanged: (t) => setState(() => _eventType = t),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _titleCtrl,
          autofocus: widget.prefillTitle == null,
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
        EventAlertMeCard(
          selected: _reminderMinutes,
          onChanged: (r) => setState(() => _reminderMinutes = r),
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
    final result = await showParticipantPicker(
      context,
      selected: _participants,
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
    setState(() => _isSaving = true);

    const createdBy = User(id: 'local', username: 'You', email: '');
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final link = _meetingLinkCtrl.text.trim();
    final loc = _locationCtrl.text.trim();

    final event = Event(
      id: const Uuid().v4(),
      title: title,
      description: desc,
      startTime: _startTime,
      endTime: _endTime,
      isAllDay: _isAllDay,
      type: _eventType,
      meetingLink: link.isNotEmpty ? link : null,
      location: loc.isNotEmpty ? loc : null,
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
