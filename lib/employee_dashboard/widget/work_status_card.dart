import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/design_tokens.dart';

// Ensure these paths match your project structure
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/model/attendance_model.dart';

class SessionOverviewSection extends StatefulWidget {
  const SessionOverviewSection({super.key});

  @override
  State<SessionOverviewSection> createState() => _SessionOverviewSectionState();
}

class _SessionOverviewSectionState extends State<SessionOverviewSection> {
  Timer? _ticker;
  Duration _liveNetWork = Duration.zero;
  Duration _liveBreak = Duration.zero;
  DateTime? _lastCheckInTime;
  bool _lastIsCheckedIn = false;

  Duration _maxDur(Duration a, Duration b) => a >= b ? a : b;

  @override
  void initState() {
    super.initState();
    final a = context.read<EmployeeBloc>().state.attendance;
    if (a != null && a.isCheckedIn) {
      _liveNetWork = a.netWork;
      _liveBreak = a.totalBreak;
      _lastIsCheckedIn = true;
      _lastCheckInTime = a.checkInTime;
    }
    _startTicker();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = context.read<EmployeeBloc>().state;
      final attendance = state.attendance;
      if (attendance == null || !attendance.isCheckedIn) return;

      if (attendance.onBreak) {
        setState(() => _liveBreak += const Duration(seconds: 1));
      } else {
        setState(() => _liveNetWork += const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmtTimer(Duration d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.inHours)}:${p(d.inMinutes.remainder(60))}:${p(d.inSeconds.remainder(60))}';
  }

  String _fmtTime(DateTime? dt) => dt == null
      ? '--:--'
      : '${(dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';

  String _fmtDur(Duration d) {
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmployeeBloc, EmployeeState>(
      listener: (context, state) {
        final a = state.attendance;
        if (a != null && a.isCheckedIn) {
          setState(() {
            final isNewSession =
                !_lastIsCheckedIn || _lastCheckInTime != a.checkInTime;

            _liveNetWork =
                isNewSession ? a.netWork : _maxDur(_liveNetWork, a.netWork);
            _liveBreak =
                isNewSession ? a.totalBreak : _maxDur(_liveBreak, a.totalBreak);

            _lastIsCheckedIn = true;
            _lastCheckInTime = a.checkInTime;
          });
        } else {
          setState(() {
            _liveNetWork = Duration.zero;
            _liveBreak = Duration.zero;
            _lastIsCheckedIn = false;
            _lastCheckInTime = null;
          });
        }
      },
      builder: (context, state) {
        final a = state.attendance;
        final isCheckedIn = a?.isCheckedIn ?? false;
        final isOnBreak = a?.onBreak ?? false;
        final isLoading = state.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSessionCard(context, a, isCheckedIn, isOnBreak, isLoading),
            const SizedBox(height: 32),
            _buildTodaysLog(a),
          ],
        );
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, AttendanceModel? a, bool isCheckedIn, bool isOnBreak, bool loading) {
    // Vibrant SaaS Status Colors
    final statusLabel = isOnBreak ? 'ON BREAK' : isCheckedIn ? 'WORKING' : 'OFF DUTY';
    final statusColor = isOnBreak ? const Color(0xFFF59E0B) : isCheckedIn ? const Color(0xFF10B981) : const Color(0xFF94A3B8);
    final statusBg = isOnBreak ? const Color(0xFFFEF3C7) : isCheckedIn ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Session', style: AppTextStyles.label(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    isCheckedIn ? _fmtTimer(_liveNetWork) : '00:00:00',
                    style: AppTextStyles.headline(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ).copyWith(letterSpacing: -1.0), // Corrected using copyWith
                  ),
                ],
              ),
              // --- VIBRANT STATUS BOARD ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStat("Working (Net) Today", _fmtDur(a?.netWork ?? Duration.zero)),
          const SizedBox(height: 12),
          _buildStat("Break Today", _fmtDur(a?.totalBreak ?? Duration.zero)),
          const SizedBox(height: 8),
          Text(
            'Breaks taken: ${a?.breakCount ?? 0}',
            style: AppTextStyles.label(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (isCheckedIn) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(isOnBreak ? Icons.play_arrow_rounded : Icons.coffee_rounded, size: 20),
                    label: Text(isOnBreak ? "Resume" : "Break"),
                    onPressed: loading ? null : () => context.read<EmployeeBloc>().add(ToggleBreakEvent()),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(isCheckedIn ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 22),
                  label: Text(isCheckedIn ? "Punch Out" : "Punch In"),
                  onPressed: loading ? null : () => _handlePunchInOut(context, isCheckedIn),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: isCheckedIn ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePunchInOut(BuildContext context, bool isCheckedIn) async {
    if (isCheckedIn) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Punch Out"),
          content: const Text("Confirm session end for today?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
                child: const Text("Punch Out")
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    if (mounted) context.read<EmployeeBloc>().add(ToggleCheckInEvent());
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label.toUpperCase(),
            style: AppTextStyles.label(fontSize: 10, fontWeight: FontWeight.w700).copyWith(letterSpacing: 1.1)
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.body(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      ],
    );
  }

  Widget _buildTodaysLog(AttendanceModel? a) {
    final isWorking = a?.isCheckedIn ?? false;
    final onBreak = a?.onBreak ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Log", style: AppTextStyles.headline(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {},
              child: Text("History", style: AppTextStyles.label(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.surfaceContainerHigh),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogDetail("In", _fmtTime(a?.checkInTime)),
              _vDivider(),
              _buildLogDetail("Out", _fmtTime(a?.checkOutTime)),
              _vDivider(),
              _buildLogDetail("Worked", _fmtDur(a?.netWork ?? Duration.zero)),
              _vDivider(),
              Column(
                children: [
                  Text("STATUS", style: AppTextStyles.label(fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: onBreak ? const Color(0xFFF59E0B) : isWorking ? const Color(0xFF10B981) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(width: 1, height: 30, color: AppColors.surfaceContainerHigh);

  Widget _buildLogDetail(String label, String value) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.label(fontSize: 9, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.body(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}