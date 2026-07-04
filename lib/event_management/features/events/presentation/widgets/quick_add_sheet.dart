import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/mobile/mobile_event_theme.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_create_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_create_screen_mobile.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_detail_screen_mobile.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import '../bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/utils/event_snackbar.dart';
import 'event_create/event_create_dialogs.dart';

class QuickAddSheet extends StatefulWidget {
  final DateTime selectedDate;

  const QuickAddSheet({required this.selectedDate, super.key});

  static Future<void> show(BuildContext context, DateTime date) {
    final mobile = AdaptiveLayout.useMobileUi(context);

    if (!mobile) {
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
    final mobile = AdaptiveLayout.useMobileUi(context);

    final content = BlocListener<EventBloc, EventState>(
      listenWhen: (_, s) =>
          s is EventCreated ||
          s is EventError ||
          s is EventConflictDetected,
      listener: (ctx, state) {
        if (!ctx.mounted) return;
        if (state is EventCreated) {
          setState(() => _isSaving = false);
          final createdTitle = state.event.title;
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
            EventSnackBars.terracotta('Event "$createdTitle" created'),
          );
        } else if (state is EventConflictDetected) {
          setState(() => _isSaving = false);
          EventCreateDialogs.showConflict(ctx, state);
        } else if (state is EventError) {
          setState(() {
            _isSaving = false;
            _error = null;
          });
          EventSnackBars.show(state.message);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: mobile ? MobileEventTheme.background : Theme.of(context).cardColor,
          borderRadius: mobile
              ? const BorderRadius.vertical(top: Radius.circular(24))
              : BorderRadius.circular(16),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          mobile ? 12 : 20,
          20,
          mobile ? (MediaQuery.of(context).viewInsets.bottom + 24) : 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mobile)
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: MobileEventTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: mobile ? MobileEventTheme.terracotta : AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d').format(widget.selectedDate),
                  style: mobile
                      ? GoogleFonts.manrope(
                          fontSize: 13,
                          color: MobileEventTheme.terracotta,
                          fontWeight: FontWeight.w800,
                        )
                      : const TextStyle(
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
              style: mobile
                  ? GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: MobileEventTheme.textDark,
                    )
                  : const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
              decoration: InputDecoration(
                hintText: 'Event title',
                hintStyle: mobile
                    ? GoogleFonts.manrope(
                        fontSize: 22,
                        color: MobileEventTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      )
                    : const TextStyle(
                        fontSize: 22,
                        color: AppTheme.textHint,
                        fontWeight: FontWeight.w400,
                      ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: mobile
                        ? MobileEventTheme.terracotta
                        : AppTheme.primaryBlue,
                    width: 2,
                  ),
                ),
                fillColor: Colors.transparent,
                filled: false,
                errorText: _error,
              ),
              onSubmitted: (_) => _quickSave(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _quickSave,
                    style: mobile
                        ? MobileEventTheme.filledButton(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          )
                        : ElevatedButton.styleFrom(
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
                              builder: (_) => mobile
                                  ? EventCreateScreenMobile(
                                      prefillDate: widget.selectedDate,
                                      prefillTitle: _titleController.text.trim(),
                                    )
                                  : EventCreateScreen(
                                      prefillDate: widget.selectedDate,
                                      prefillTitle: _titleController.text.trim(),
                                    ),
                            ),
                          );
                        });
                      });
                    },
                    style: mobile
                        ? OutlinedButton.styleFrom(
                            foregroundColor: MobileEventTheme.terracotta,
                            side: const BorderSide(color: MobileEventTheme.terracotta),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          )
                        : null,
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

    if (mobile) {
      return MobileEventTheme.wrap(context, content);
    }
    return content;
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
