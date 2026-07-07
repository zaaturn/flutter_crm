import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';

import 'employee_dashboard_v2_theme.dart';

/// Punch in/out card — Daxarrow Dashboard v2 time tracker.
class EmployeeDashboardV2TimeTracker extends StatelessWidget {
  const EmployeeDashboardV2TimeTracker({super.key});

  String _fmtTimer(Duration d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.inHours)}:${p(d.inMinutes.remainder(60))}:${p(d.inSeconds.remainder(60))}';
  }

  String _fmtBreak(Duration d) => '${d.inHours}h ${d.inMinutes.remainder(60)}m';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        final a = state.attendance;
        final isCheckedIn = a?.isCheckedIn ?? false;
        final isOnBreak = a?.onBreak ?? false;
        final loading = state.loading;
        final display =
            isCheckedIn ? _fmtTimer(a?.netWork ?? Duration.zero) : '00:00:00';
        final parts = display.split(':');
        final statusLabel =
            isOnBreak ? 'ON BREAK' : isCheckedIn ? 'WORKING' : 'OFF DUTY';
        final statusColor = isOnBreak
            ? const Color(0xFFD97706)
            : isCheckedIn
                ? EmployeeDashboardV2Theme.green
                : const Color(0xFF94A3B8);
        final progress = isCheckedIn
            ? ((a?.netWork.inMinutes ?? 0) / (8 * 60)).clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'WORKING TIME (NET)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: EmployeeDashboardV2Theme.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: EmployeeDashboardV2Theme.cardMuted,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          statusLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: EmployeeDashboardV2Theme.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  _timePart(parts[0]),
                  _colon(),
                  _timePart(parts[1]),
                  _colon(),
                  _timePart(parts[2]),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: EmployeeDashboardV2Theme.rowBorder,
                  valueColor: const AlwaysStoppedAnimation(
                    EmployeeDashboardV2Theme.green,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 20,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _punchButton(context, isCheckedIn, loading),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _miniStat('Break', _fmtBreak(a?.totalBreak ?? Duration.zero)),
                      const SizedBox(width: 26),
                      _miniStat('Breaks', '${a?.breakCount ?? 0}'),
                    ],
                  ),
                  if (isCheckedIn)
                    OutlinedButton.icon(
                      onPressed: loading
                          ? null
                          : () => context.read<EmployeeBloc>().add(ToggleBreakEvent()),
                      icon: Icon(
                        isOnBreak ? Icons.coffee_outlined : Icons.free_breakfast_outlined,
                        size: 16,
                      ),
                      label: Text(isOnBreak ? 'End Break' : 'Start Break'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: EmployeeDashboardV2Theme.greenDark,
                        side: const BorderSide(color: Color(0xFFCCEADB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                ],
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _timePart(String value) => Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 52,
          fontWeight: FontWeight.w800,
          color: EmployeeDashboardV2Theme.textDark,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );

  Widget _colon() => Text(
        ':',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 52,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFC3DDCE),
        ),
      );

  Widget _miniStat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFA7BFB2),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: EmployeeDashboardV2Theme.textDark,
            ),
          ),
        ],
      );

  Widget _punchButton(BuildContext context, bool isCheckedIn, bool loading) {
    return ElevatedButton.icon(
      onPressed: loading ? null : () => _onPunch(context, isCheckedIn),
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(
              isCheckedIn ? Icons.stop_circle_outlined : Icons.play_circle_outline,
              size: 18,
            ),
      label: Text(isCheckedIn ? 'Punch Out' : 'Punch In'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCheckedIn
            ? const Color(0xFFDC2626)
            : EmployeeDashboardV2Theme.greenMid,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }

  Future<void> _onPunch(BuildContext context, bool isCheckedIn) async {
    if (isCheckedIn) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Punch Out'),
          content: const Text('Are you sure you want to logout for today?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
          ],
        ),
      );
      if (confirm != true) return;
      if (!context.mounted) return;
      context.read<EmployeeBloc>().add(ToggleCheckInEvent());
      return;
    }

    final a = context.read<EmployeeBloc>().state.attendance;
    if (a != null && a.checkOutTime != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance is already complete for today.')),
      );
      return;
    }
    context.read<EmployeeBloc>().add(ToggleCheckInEvent());
  }
}
