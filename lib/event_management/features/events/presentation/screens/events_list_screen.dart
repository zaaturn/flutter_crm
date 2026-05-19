import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/event_management/shared/themes/event_management_fonts.dart';

import '../../domain/entities/event.dart';
import '../bloc/event_bloc.dart';
import '../widgets/event_card.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
          child: Text(
            'Events',
            style: EventManagementFonts.screenTitle(),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _load();
              await Future<void>.delayed(const Duration(milliseconds: 350));
            },
            child: BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                if (state is EventInitial || state is EventLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is EventError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: EventManagementFonts.cardMeta(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: FilledButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  );
                }
                final events =
                    state is EventsLoaded ? state.events : const <Event>[];
                if (events.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No events found.',
                          style: EventManagementFonts.cardMeta(),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => EventCard(event: events[i]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

