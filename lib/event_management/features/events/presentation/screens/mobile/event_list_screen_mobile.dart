import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/mobile/mobile_event_theme.dart';
import 'package:my_app/event_management/features/events/presentation/utils/event_snackbar.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/event_card_mobile.dart';

class EventsListScreenMobile extends StatefulWidget {
  const EventsListScreenMobile({super.key});

  @override
  State<EventsListScreenMobile> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreenMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    if (!mounted) return;
    final now = DateTime.now();
    context.read<EventBloc>().add(FetchEventsRequested(
      startDate: DateTime(now.year, now.month - 1, 1),
      endDate: DateTime(now.year + 1, now.month, now.day),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listenWhen: (_, s) => s is EventError,
      listener: (_, state) {
        if (state is EventError) EventSnackBars.show(state.message);
      },
      child: Container(
      color: MobileEventTheme.background,
      child: RefreshIndicator(
        color: MobileEventTheme.terracotta,
        backgroundColor: Colors.white,
        onRefresh: () async {
          _load();
          await Future<void>.delayed(const Duration(milliseconds: 350));
        },
        child: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventInitial || state is EventLoading) {
              return const Center(
                child: CircularProgressIndicator(color: MobileEventTheme.terracotta),
              );
            }

            if (state is EventError) {
              return _buildStateOverlay(
                icon: Icons.error_outline_rounded,
                message: 'Unable to load events. Pull to retry.',
                action: FilledButton(
                  onPressed: _load,
                  style: FilledButton.styleFrom(backgroundColor: MobileEventTheme.terracotta),
                  child: const Text('Retry'),
                ),
              );
            }

            final events = state is EventsLoaded
                ? (List<Event>.from(state.events)
                  ..sort(
                    // Newest first (Apr 23 before Apr 22)
                    (a, b) => b.startTime.toLocal().compareTo(a.startTime.toLocal()),
                  ))
                : const <Event>[];

            if (events.isEmpty) {
              return _buildStateOverlay(
                icon: Icons.event_busy_rounded,
                message: "No events found. Time to plan something new!",
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => EventCardMobile(event: events[i]),
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _buildStateOverlay({
    required IconData icon,
    required String message,
    Widget? action,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: MobileEventTheme.field.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: MobileEventTheme.textMuted.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: MobileEventTheme.textMuted.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MobileEventTheme.textDark,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 20),
                  action,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}