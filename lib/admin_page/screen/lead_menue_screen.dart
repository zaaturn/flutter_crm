import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lead_bloc.dart';
import 'create_lead_screen.dart';
import 'assign_lead_screen.dart';
import 'track_leadscreen.dart';

class LeadsMenuScreen extends StatelessWidget {
  LeadsMenuScreen({super.key}); // <-- no const (avoid old error)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Leads",
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _menuItem(
              context,
              title: "Create Lead",
              icon: Icons.add_business,
              color: Colors.blue,
              page: const CreateLeadScreen(),
            ),
            const SizedBox(height: 16),

            _menuItem(
              context,
              title: "Assign Lead",
              icon: Icons.assignment_ind,
              color: Colors.green,
              page: const AssignLeadScreen(),
            ),
            const SizedBox(height: 16),

            _menuItem(
              context,
              title: "Track Leads",
              icon: Icons.track_changes,
              color: Colors.orange,
              page: const TrackLeadScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required Widget page,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<LeadBloc>(),
              child: page,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }
}
