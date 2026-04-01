import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_ended_section.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stat_cards.dart';
import '../widgets/dashboard_today_grid.dart';
import '../widgets/dashboard_tomorrow_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Use a small delay or ensure the Bloc is provided high enough in the tree
    context.read<DashboardBloc>().add(DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Set base background to pure white
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0D3199),
          backgroundColor: Colors.white,
          onRefresh: () async {
            context.read<DashboardBloc>().add(DashboardRefreshRequested());
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (ctx, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0D3199),
                  ),
                );
              }

              return Container(
                color: Colors.white, // Extra safety for overscroll areas
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header Area
                    const SliverToBoxAdapter(child: DashboardHeader()),

                    // Statistics Cards (Ensure these use subtle shadows now)
                    SliverToBoxAdapter(child: DashboardStatCards(state: state)),

                    // Sections with optimized vertical spacing
                    SliverToBoxAdapter(
                      child: DashboardEndedSection(endedEvents: state.missedEvents),
                    ),

                    // Today Grid
                    SliverToBoxAdapter(
                      child: DashboardTodayGrid(events: state.todayEvents),
                    ),

                    // Tomorrow / Upcoming Section
                    SliverToBoxAdapter(
                      child: DashboardTomorrowSection(upcoming: state.upcomingEvents),
                    ),

                    // Bottom padding for clear scrolling
                    const SliverToBoxAdapter(child: SizedBox(height: 60)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}