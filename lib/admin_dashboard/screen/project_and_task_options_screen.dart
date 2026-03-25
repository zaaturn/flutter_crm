import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/assign_task_screen_mobile.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/track_task_screen_mobile.dart';

const Color primaryIndigo = Color(0xFF6366F1);
const Color darkSlate = Color(0xFF0F172A);
const Color borderLight = Color(0xFFF1F5F9);

class ProjectAndTaskOptionsScreen extends StatelessWidget {
  const ProjectAndTaskOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // Keeps it white when scrolling
        leading: const BackButton(color: darkSlate),
        title: Text(
          "Projects & Tasks",
          style: GoogleFonts.plusJakartaSans(
            color: darkSlate,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          _OptionCard(
            title: "Task Tracker",
            subtitle: "Monitor team productivity",
            icon: Icons.track_changes_rounded,
            accentColor: primaryIndigo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskTrackerScreenMobile()),
              );
            },
          ),
          const SizedBox(height: 12),
          _OptionCard(
            title: "Assign Task",
            subtitle: "Delegate new work",
            icon: Icons.add_task_rounded,
            accentColor: const Color(0xFFF59E0B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssignTaskScreenMobile()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: accentColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: darkSlate,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}