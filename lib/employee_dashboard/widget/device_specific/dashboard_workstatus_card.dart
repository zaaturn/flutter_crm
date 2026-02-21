import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/employee_dashboard_bloc.dart';
import '../../bloc/employee_dashboard_event.dart';
import '../../bloc/employee_dashboard_state.dart';
import '../../model/attendance_model.dart';

class DashboardWorkStatusCard extends StatefulWidget {
  const DashboardWorkStatusCard({super.key});

  @override
  State<DashboardWorkStatusCard> createState() =>
      _DashboardWorkStatusCardState();
}

class _DashboardWorkStatusCardState extends State<DashboardWorkStatusCard> {
  static const _blue = Color(0xFF137FEC);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _amber = Color(0xFFF59E0B);
  static const _textMain = Color(0xFF1E293B);
  static const _textMuted = Color(0xFF94A3B8);
  static const _surface = Color(0xFFF1F5F9);
  static const _border = Color(0xFFE2E8F0);

  Timer? _ticker;
  Duration _liveElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    final attendance = context.read<EmployeeBloc>().state.attendance;
    if (attendance != null && attendance.isCheckedIn) {
      _liveElapsed = _calcElapsed(attendance);
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final attendance = context.read<EmployeeBloc>().state.attendance;
      if (attendance != null &&
          attendance.isCheckedIn &&
          !attendance.onBreak) {
        setState(() => _liveElapsed = _calcElapsed(attendance));
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration _calcElapsed(AttendanceModel a) {
    if (a.checkInTime == null) return Duration.zero;
    return DateTime.now().difference(a.checkInTime!);
  }

  String _fmtTimer(Duration d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.inHours)}:${p(d.inMinutes.remainder(60))}:${p(d.inSeconds.remainder(60))}';
  }

  String _fmtTime(DateTime? dt) => dt == null
      ? '--:--'
      : '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _fmtDur(Duration? d) {
    if (d == null) return '0h 0m';
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmployeeBloc, EmployeeState>(
      listenWhen: (prev, curr) =>
      prev.attendance?.isCheckedIn != curr.attendance?.isCheckedIn ||
          prev.attendance?.onBreak != curr.attendance?.onBreak ||
          prev.attendance?.checkInTime != curr.attendance?.checkInTime,
      listener: (context, state) {
        if (state.attendance != null && state.attendance!.isCheckedIn) {
          setState(() => _liveElapsed = _calcElapsed(state.attendance!));
        } else {
          setState(() => _liveElapsed = Duration.zero);
        }
      },
      builder: (context, state) {
        final a = state.attendance;
        final isCheckedIn = a?.isCheckedIn ?? false;
        final isOnBreak = a?.onBreak ?? false;
        final isLoading = state.loading;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWide(context, a, isCheckedIn, isOnBreak, isLoading),
              if (a != null && a.checkInTime != null) ...[
                const SizedBox(height: 20),
                _hLine(),
                const SizedBox(height: 16),
                _buildTimeLog(a),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 12),
                _errorBanner(state.error!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildWide(BuildContext context, AttendanceModel? a,
      bool isCheckedIn, bool isOnBreak, bool loading) {
    return Row(
      children: [
        _timerBlock(isCheckedIn, isOnBreak),
        const SizedBox(width: 32),
        _vLine(),
        const SizedBox(width: 32),
        _totalWorked(a),
        const SizedBox(width: 32),
        _vLine(),
        const SizedBox(width: 32),
        _statusBadge(isCheckedIn, isOnBreak),
        const Spacer(),
        if (isCheckedIn) ...[
          _breakBtn(context, isOnBreak, loading),
          const SizedBox(width: 12),
        ],
        _checkInOutBtn(context, isCheckedIn, loading),
      ],
    );
  }

  Widget _timerBlock(bool isCheckedIn, bool isOnBreak) {
    final display = isCheckedIn ? _fmtTimer(_liveElapsed) : '00:00:00';
    final parts = display.split(':');
    final activeColor = isOnBreak ? _amber : _blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('CURRENT SESSION'),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _seg(parts[0]),
            _colon(),
            _seg(parts[1]),
            _colon(),
            _seg(parts[2], color: isCheckedIn ? activeColor : _textMuted),
          ],
        ),
      ],
    );
  }

  Widget _totalWorked(AttendanceModel? a) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('TOTAL WORKED'),
      const SizedBox(height: 4),
      Text(
        '${_fmtDur(a?.totalHours)} / 8h',
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _textMain),
      ),
    ],
  );

  Widget _statusBadge(bool isCheckedIn, bool isOnBreak) {
    final label =
    isOnBreak ? 'On Break' : isCheckedIn ? 'Working' : 'Off Duty';
    final color = isOnBreak ? _amber : isCheckedIn ? _green : _textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 7,
            height: 7,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color)),
      ]),
    );
  }

  Widget _breakBtn(BuildContext context, bool isOnBreak, bool loading) =>
      OutlinedButton.icon(
        onPressed: loading
            ? null
            : () => context.read<EmployeeBloc>().add(ToggleBreakEvent()),
        icon: Icon(
            isOnBreak
                ? Icons.coffee_outlined
                : Icons.free_breakfast_outlined,
            size: 16),
        label: Text(isOnBreak ? 'End Break' : 'Start Break'),
      );

  Widget _checkInOutBtn(
      BuildContext context, bool isCheckedIn, bool loading) =>
      ElevatedButton.icon(
        onPressed: loading
            ? null
            : () => context.read<EmployeeBloc>().add(ToggleCheckInEvent()),
        icon: loading
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : Icon(
          isCheckedIn
              ? Icons.stop_circle_rounded
              : Icons.play_circle_filled_rounded,
          size: 18,
        ),
        label: Text(isCheckedIn ? 'Punch Out' : 'Punch In'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCheckedIn ? _red : _green,
          foregroundColor: Colors.white,
        ),
      );

  Widget _buildTimeLog(AttendanceModel a) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label("TODAY'S LOG"),
      const SizedBox(height: 12),
      Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          _logCell('Check In', _fmtTime(a.checkInTime), _green),
          _logDivider(),
          _logCell('Check Out', _fmtTime(a.checkOutTime), _red),
          _logDivider(),
          _logCell('Total Worked', _fmtDur(a.totalHours), _blue),
          _logDivider(),
          _logCell(
            'Status',
            a.onBreak ? 'On Break' : a.isCheckedIn ? 'Active' : 'Done',
            a.onBreak ? _amber : a.isCheckedIn ? _green : _textMuted,
          ),
        ]),
      ),
    ],
  );

  Widget _errorBanner(String error) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _red.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _red.withOpacity(0.2)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline, size: 16, color: _red),
      const SizedBox(width: 8),
      Expanded(
        child: Text(error,
            style: const TextStyle(
                fontSize: 12,
                color: _red,
                fontWeight: FontWeight.w500)),
      ),
    ]),
  );

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _textMuted,
          letterSpacing: 1.2));

  Widget _seg(String v, {Color color = _textMain}) => Text(v,
      style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: -0.5));

  Widget _colon() => const Text(' : ',
      style: TextStyle(
          fontSize: 18,
          color: _textMuted,
          fontWeight: FontWeight.bold));

  Widget _vLine() =>
      Container(width: 1, height: 40, color: _border);

  Widget _hLine() =>
      Container(height: 1, color: _border);

  Widget _logDivider() => Container(
      width: 1,
      height: 36,
      color: _border,
      margin: const EdgeInsets.symmetric(horizontal: 12));

  Widget _logCell(String label, String value, Color accent) =>
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: accent)),
          ],
        ),
      );
}