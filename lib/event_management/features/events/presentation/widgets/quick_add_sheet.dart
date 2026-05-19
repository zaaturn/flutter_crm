import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_create_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import '../bloc/event_bloc.dart';
import '../utils/event_snackbar.dart';
import 'event_create/event_create_dialogs.dart';

class QuickAddSheet extends StatefulWidget {
  final DateTime selectedDate;

  const QuickAddSheet({required this.selectedDate, super.key});

  static Future<void> show(BuildContext context, DateTime date) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 768;

    if (isDesktop) {
      return showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.35),
        builder: (dialogCtx) => _inheritBlocs(
          context,
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 440,
              child: QuickAddSheet(selectedDate: date),
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (sheetCtx) => _inheritBlocs(
        context,
        QuickAddSheet(selectedDate: date),
      ),
    );
  }

  static Widget _inheritBlocs(BuildContext parent, Widget child) {
    final providers = <BlocProvider<dynamic>>[
      BlocProvider.value(value: parent.read<EventBloc>()),
    ];
    try {
      providers.add(BlocProvider.value(value: parent.read<CalendarBloc>()));
    } catch (_) {}
    try {
      providers.add(BlocProvider.value(value: parent.read<DashboardBloc>()));
    } catch (_) {}
    return MultiBlocProvider(providers: providers, child: child);
  }

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _titleController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return BlocListener<EventBloc, EventState>(
      listenWhen: (_, s) =>
          s is EventCreated ||
          s is EventError ||
          s is EventConflictDetected,
      listener: (ctx, state) {
        if (!ctx.mounted) return;
        if (state is EventCreated) {
          setState(() => _isSaving = false);
          final createdId = state.event.id;
          final createdTitle = state.event.title;
          final nav = Navigator.of(ctx);
          try {
            ctx.read<CalendarBloc>().add(CalendarRefreshRequested());
          } catch (_) {}
          try {
            ctx.read<DashboardBloc>().add(DashboardRefreshRequested());
          } catch (_) {}
          try {
            ctx.read<CalendarBloc>().add(
                  HighlightDateRequested(widget.selectedDate),
                );
          } catch (_) {}

          popRouteThenShowSnackBar(
            ctx,
            SnackBar(
              content: Text('Event "$createdTitle" created'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  if (!nav.mounted) return;
                  nav.push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => EventDetailScreen(eventId: createdId),
                    ),
                  );
                },
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is EventConflictDetected) {
          setState(() => _isSaving = false);
          EventCreateDialogs.showConflict(ctx, state);
        } else if (state is EventError) {
          setState(() {
            _isSaving = false;
            _error = state.message;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: isDesktop
              ? BorderRadius.circular(16)
              : const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          isDesktop ? 20 : 12,
          20,
          isDesktop ? 20 : (MediaQuery.of(context).viewInsets.bottom + 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isDesktop)
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppTheme.primaryBlue),
                const SizedBox(width: 6),
                Text(
                  DateFormat('EEEE, MMMM d').format(widget.selectedDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Event title',
                hintStyle: const TextStyle(
                  fontSize: 22,
                  color: AppTheme.textHint,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
                fillColor: Colors.transparent,
                filled: false,
                errorText: _error,
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              onSubmitted: (_) => _quickSave(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _quickSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final nav = Navigator.of(context, rootNavigator: true);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) return;
                        if (nav.canPop()) nav.pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted) return;
                          Navigator.of(context, rootNavigator: true).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => EventCreateScreen(
                                prefillDate: widget.selectedDate,
                                prefillTitle: _titleController.text.trim(),
                              ),
                            ),
                          );
                        });
                      });
                    },
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('More options'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _quickSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Please enter a title');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    context.read<EventBloc>().add(QuickCreateEvent(
          title: title,
          selectedDate: widget.selectedDate,
          creatorId: 'local',
        ));
  }
}
