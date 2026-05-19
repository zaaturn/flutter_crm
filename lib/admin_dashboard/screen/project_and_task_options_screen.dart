import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/assign_task_screen_mobile.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/track_task_screen_mobile.dart';

class ProjectAndTaskOptionsScreen extends StatelessWidget {
  const ProjectAndTaskOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFAF9F6);
    const Color darkSlate = Color(0xFF0F172A);


    const Color cardYellow = Color(0xFFEFD353);
    const Color cardDustyBlue = Color(0xFF80A4AA);


    const Color trackerIconBg = Color(0xFFE94E63);
    const Color assignIconBg = Color(0xFFF86320);

    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: lightCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: darkSlate),
        title: Text(
          "Projects & Tasks",
          style: GoogleFonts.manrope(
            color: darkSlate,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _OptionCard(
            title: "Task Tracker",
            subtitle: "Monitor team productivity",
            icon: Icons.assignment_turned_in_rounded,
            cardColor: cardYellow,      // Outer Box Yellow
            iconCircleColor: trackerIconBg, // Inner Circle Indigo
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskTrackerScreenMobile()),
              );
            },
          ),
          const SizedBox(height: 16),
          _OptionCard(
            title: "Assign Task",
            subtitle: "Delegate new work",
            icon: Icons.add_task_rounded,
            cardColor: cardDustyBlue,    // Outer Box Dusty Blue
            iconCircleColor: assignIconBg, // Inner Circle Amber
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
  final Color cardColor;
  final Color iconCircleColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cardColor,
    required this.iconCircleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkSlate = Color(0xFF0F172A);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkSlate, width: 1.75),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20.0),
            child: Row(
              children: [
                // Circular Filled Icon Background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconCircleColor, // 👈 Circle filled with Indigo/Amber
                    shape: BoxShape.circle,
                    border: Border.all(color: darkSlate, width: 1.5), // Optional: border for the circle
                  ),
                  child: Icon(icon, size: 24, color: Colors.white), // White icon for contrast
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: darkSlate,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle.toUpperCase(),
                        style: GoogleFonts.manrope(
                          color: darkSlate.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: darkSlate,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}