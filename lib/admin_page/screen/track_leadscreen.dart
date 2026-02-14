import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lead_bloc.dart';
import '../bloc/lead_state.dart';
import '../widget/lead_card.dart';

class TrackLeadScreen extends StatelessWidget {
  const TrackLeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Leads"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoaded) {
            return ListView.builder(
              itemCount: state.leads.length,
              itemBuilder: (context, i) => LeadCard(lead: state.leads[i]),
            );
          }
          return const Center(child: Text("No leads yet"));
        },
      ),
    );
  }
}

