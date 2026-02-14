import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee_dashboard_bloc.dart';
import '../bloc/employee_dashboard_event.dart';
import '../model/attendance_model.dart';

class WorkStatusCard extends StatelessWidget {
  final AttendanceModel? att;
  const WorkStatusCard({super.key, this.att});

  // --- SAAS COLOR PALETTE (Matched to Drawer/Sidebar) ---
  final Color bgLight = const Color(0xFFF1F5F9); // Slate 100
  final Color textSecondary = const Color(0xFF64748B); // Slate 500
  final Color primaryIndigo = const Color(0xFF4F46E5); // Indigo 600
  final Color accentViolet = const Color(0xFF7C3AED); // Violet 600
  final Color textDark = const Color(0xFF1E293B); // Slate 800
  final Color successGreen = const Color(0xFF10B981); // Emerald 500
  final Color warningAmber = const Color(0xFFF59E0B); // Amber 500

  String _formatTime(DateTime? t) {
    if (t == null) return "—";
    final dt = t.toLocal();
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? "PM" : "AM";
    return "$h:$m $suffix";
  }

  String _formatDuration(Duration? d) {
    if (d == null) return "—";
    return "${d.inHours}h ${d.inMinutes % 60}m";
  }

  @override
  Widget build(BuildContext context) {
    if (att == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final isCheckedIn = att!.isCheckedIn;
    final onBreak = att!.onBreak;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER WITH STATUS BADGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "WORK STATUS",
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCheckedIn ? successGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: isCheckedIn ? successGreen : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCheckedIn ? "Checked In" : "Checked Out",
                      style: TextStyle(
                        color: isCheckedIn ? successGreen : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // PRIMARY ACTIONS (GRADIENT BUTTONS)
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  onPressed: () => context.read<EmployeeBloc>().add(ToggleCheckInEvent()),
                  icon: isCheckedIn ? Icons.logout_rounded : Icons.login_rounded,
                  label: isCheckedIn ? "Check-Out" : "Check-In",
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  onPressed: () => context.read<EmployeeBloc>().add(ToggleBreakEvent()),
                  icon: onBreak ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  label: onBreak ? "End Break" : "Break",
                  isPrimary: false,
                  accentColor: onBreak ? warningAmber : textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ATTENDANCE DATA GRID
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _attendanceItem(
                    icon: Icons.login_rounded,
                    title: "In",
                    value: _formatTime(att!.checkInTime),
                    color: primaryIndigo,
                  ),
                  _vDivider(),
                  _attendanceItem(
                    icon: Icons.logout_rounded,
                    title: "Out",
                    value: _formatTime(att!.checkOutTime),
                    color: accentViolet,
                  ),
                  _vDivider(),
                  _attendanceItem(
                    icon: Icons.schedule_rounded,
                    title: "Total",
                    value: _formatDuration(att!.totalHours),
                    color: textDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CUSTOM ACTION BUTTONS ---
  Widget _actionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
    Color? accentColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isPrimary
              ? LinearGradient(colors: [primaryIndigo, accentViolet])
              : null,
          color: isPrimary ? null : Colors.white,
          border: isPrimary ? null : Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: primaryIndigo.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : (accentColor ?? textDark), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : (accentColor ?? textDark),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ATTENDANCE ITEM (MATCHED TO SIDEBAR ICON STYLE) ---
  Widget _attendanceItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: textDark,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => VerticalDivider(
    color: textSecondary.withOpacity(0.1),
    thickness: 1,
    width: 1,
    indent: 10,
    endIndent: 10,
  );
}