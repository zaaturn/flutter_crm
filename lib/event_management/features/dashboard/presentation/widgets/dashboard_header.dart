import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_create_screen.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/notification_screen.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import '../bloc/dashboard_bloc.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
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
                  const Icon(Icons.notifications_none_rounded, size: 24),
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
            icon: const Icon(Icons.help_outline_rounded, size: 24),
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const EventCreateScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Event'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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

