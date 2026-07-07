import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/tasks/task_status_utils.dart';

import 'employee_dashboard_v2_theme.dart';

class EmployeeDashboardV2KpiStrip extends StatelessWidget {
  const EmployeeDashboardV2KpiStrip({super.key});

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
        final statusLabel =
            isOnBreak ? 'On break' : isCheckedIn ? 'Working' : 'Off Duty';

        final done = state.tasks
            .where((t) => normalizeTaskStatusForApi(t.status) == 'COMPLETED')
            .length;
        final total = state.tasks.length;

        final kpis = [
          _KpiData(
            value: isCheckedIn ? _fmtTimer(a?.netWork ?? Duration.zero) : '00:00:00',
            label: 'Working time',
            tag: 'Net',
            chipBg: EmployeeDashboardV2Theme.greenLight,
            chipFg: EmployeeDashboardV2Theme.greenMid,
            icon: Icons.schedule_rounded,
          ),
          _KpiData(
            value: _fmtBreak(a?.totalBreak ?? Duration.zero),
            label: 'On break',
            tag: 'Today',
            chipBg: EmployeeDashboardV2Theme.amberBg,
            chipFg: const Color(0xFFD97706),
            icon: Icons.free_breakfast_outlined,
          ),
          _KpiData(
            value: statusLabel,
            label: 'Current status',
            tag: 'Now',
            chipBg: EmployeeDashboardV2Theme.slateBg,
            chipFg: EmployeeDashboardV2Theme.textBody,
            icon: Icons.sensors_rounded,
          ),
          _KpiData(
            value: '$done / $total',
            label: 'Tasks done',
            tag: 'Active',
            chipBg: const Color(0xFFE0F2F2),
            chipFg: const Color(0xFF0D9488),
            icon: Icons.check_circle_outline_rounded,
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 900 ? 4 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: cols == 4 ? 1.55 : 1.35,
              ),
              itemCount: kpis.length,
              itemBuilder: (_, i) => _KpiCard(data: kpis[i]),
            );
          },
        );
      },
    );
  }
}

class _KpiData {
  final String value;
  final String label;
  final String tag;
  final Color chipBg;
  final Color chipFg;
  final IconData icon;

  const _KpiData({
    required this.value,
    required this.label,
    required this.tag,
    required this.chipBg,
    required this.chipFg,
    required this.icon,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: EmployeeDashboardV2Theme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.chipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.chipFg, size: 20),
              ),
              Text(
                data.tag,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: EmployeeDashboardV2Theme.kpiValue(),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
