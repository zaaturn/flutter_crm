import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/notification_screen.dart';
import 'package:my_app/event_management/shared/themes/event_adaptive_theme.dart';

import '../bloc/dashboard_bloc.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dashboard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: EventAdaptiveTheme.text(context),
                        letterSpacing: -0.2,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => _openNotifications(context),
                icon: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (_, state) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 24,
                        color: EventAdaptiveTheme.text(context),
                      ),
                      if (state.missedEvents.isNotEmpty)
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Help',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Today is ${DateFormat('EEEE, MMMM d').format(DateTime.now())}.',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.help_outline_rounded,
                  size: 24,
                  color: EventAdaptiveTheme.text(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    try {
      final bloc = context.read<NotificationBloc>();
      bloc.add(NotificationLoadRequested());
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const NotificationScreen(),
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications unavailable')),
      );
    }
  }
}

