import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/employee_dashboard_bloc.dart';
import '../../bloc/employee_dashboard_event.dart';
import '../../model/attendance_model.dart';

class DashboardWorkStatusCard extends StatelessWidget {
  final AttendanceModel? attendance;

  const DashboardWorkStatusCard({
    super.key,
    required this.attendance,
  });

  static const Color _primaryBlue = Color(0xFF137FEC);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = attendance?.isCheckedIn ?? false;

    final duration = (isCheckedIn && attendance?.checkInTime != null)
        ? DateTime.now().difference(attendance!.checkInTime!)
        : Duration.zero;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isNarrow
              ? _buildVerticalLayout(context, duration, isCheckedIn)
              : _buildHorizontalLayout(context, duration, isCheckedIn),
        );
      },
    );
  }

  // ================= HORIZONTAL (DESKTOP) =================
  Widget _buildHorizontalLayout(
      BuildContext context, Duration duration, bool isCheckedIn) {
    return Row(
      children: [
        _buildSessionTimer(duration),
        const SizedBox(width: 40),
        _divider(),
        const SizedBox(width: 40),
        _buildDailyGoal(attendance?.totalHours),
        const Spacer(),
        _buildTeamGroup(),
        const SizedBox(width: 24),
        _buildActionButton(context, isCheckedIn),
      ],
    );
  }

  // ================= VERTICAL (NARROW) =================
  Widget _buildVerticalLayout(
      BuildContext context, Duration duration, bool isCheckedIn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSessionTimer(duration),
            const SizedBox(width: 40),
            _divider(),
            const SizedBox(width: 40),
            _buildDailyGoal(attendance?.totalHours),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTeamGroup(),
            _buildActionButton(context, isCheckedIn),
          ],
        ),
      ],
    );
  }

  // ================= TIMER =================
  Widget _buildSessionTimer(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CURRENT SESSION",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: _textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(hours, style: _timerStyle()),
            const Text(" : ", style: TextStyle(fontSize: 18, color: _textMuted, fontWeight: FontWeight.bold)),
            Text(minutes, style: _timerStyle()),
            const Text(" : ", style: TextStyle(fontSize: 18, color: _textMuted, fontWeight: FontWeight.bold)),
            Text(seconds, style: _timerStyle(color: _primaryBlue)),
          ],
        ),
      ],
    );
  }

  // ================= TOTAL HOURS =================
  Widget _buildDailyGoal(Duration? totalHours) {
    final displayHours = totalHours?.inHours ?? 0;
    final displayMins = (totalHours?.inMinutes ?? 0) % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TOTAL WORKED",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: _textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${displayHours}h ${displayMins}m / 8h",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _textMain,
          ),
        ),
      ],
    );
  }

  // ================= ACTION BUTTON =================
  Widget _buildActionButton(BuildContext context, bool isCheckedIn) {
    return ElevatedButton.icon(
      onPressed: () =>
          context.read<EmployeeBloc>().add(ToggleCheckInEvent()),
      icon: Icon(
        isCheckedIn
            ? Icons.stop_circle_rounded
            : Icons.play_circle_filled_rounded,
        size: 20,
      ),
      label: Text(isCheckedIn ? "Punch Out" : "Punch In"),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCheckedIn ? Colors.red : _primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        textStyle:
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================
  TextStyle _timerStyle({Color color = _textMain}) {
    return TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.5,
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: const Color(0xFFE2E8F0));

  Widget _buildTeamGroup() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 16, color: _textMuted),
        ),
        const SizedBox(width: 6),
        const CircleAvatar(
          radius: 14,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 16, color: _primaryBlue),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "+4",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _textMain,
            ),
          ),
        ),
      ],
    );
  }
}
