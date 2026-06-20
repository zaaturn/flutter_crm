import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';



import '../../bloc/analytics_bloc.dart';

import '../../bloc/analytics_event.dart';

import '../../bloc/analytics_state.dart';

import '../../theme/analytics_theme.dart';



class AnalyticsTabBar extends StatelessWidget {

  const AnalyticsTabBar({super.key});



  @override

  Widget build(BuildContext context) {

    return BlocBuilder<AnalyticsBloc, AnalyticsState>(

      buildWhen: (p, c) => p.tab != c.tab,

      builder: (context, state) {

        return Container(

          color: AnalyticsDesktopTheme.surface,

          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          child: SingleChildScrollView(

            scrollDirection: Axis.horizontal,

            child: Row(

              children: [

                _chip(context, state, AnalyticsTab.overview, 'Overview'),

                _chip(context, state, AnalyticsTab.weeklyAttendance, 'Attendance'),

                _chip(context, state, AnalyticsTab.weeklyBusiness, 'Business'),

                _chip(context, state, AnalyticsTab.leaves, 'Leaves'),

                _chip(context, state, AnalyticsTab.monthlyBilling, 'Billing'),

              ],

            ),

          ),

        );

      },

    );

  }



  Widget _chip(

    BuildContext context,

    AnalyticsState state,

    AnalyticsTab tab,

    String label,

  ) {

    final selected = state.tab == tab;

    return Padding(

      padding: const EdgeInsets.only(right: 8),

      child: FilterChip(

        label: Text(label),

        selected: selected,

        showCheckmark: false,

        selectedColor: AnalyticsDesktopTheme.purpleLight,

        backgroundColor: AnalyticsDesktopTheme.surface,

        labelStyle: GoogleFonts.manrope(

          fontWeight: FontWeight.w800,

          color: selected

              ? AnalyticsDesktopTheme.purple

              : AnalyticsDesktopTheme.textMuted,

        ),

        side: BorderSide(

          color: selected

              ? AnalyticsDesktopTheme.purple.withValues(alpha: 0.35)

              : AnalyticsDesktopTheme.border,

        ),

        onSelected: (selected) {

          if (!selected) return;

          context.read<AnalyticsBloc>().add(AnalyticsTabChanged(tab));

        },

      ),

    );

  }

}


