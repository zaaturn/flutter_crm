import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaveManagerSummarySection extends StatelessWidget {
  const LeaveManagerSummarySection({
    super.key,
    required this.activeRequests,
    required this.approvedCount,
    required this.onLeaveCount,
  });

  final int activeRequests;
  final int approvedCount;
  final int onLeaveCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'ACTIVE',
              value: activeRequests,
              color: const Color(0xFFF3924C),
              icon: Icons.assignment_late_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'APPROVED',
              value: approvedCount,
              color: const Color(0xFFC05E41),
              icon: Icons.check_circle_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'ON LEAVE',
              value: onLeaveCount,
              color: const Color(0xFF52A5CE), // light blue
              icon: Icons.timer_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Colors.white.withOpacity(0.9)),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}