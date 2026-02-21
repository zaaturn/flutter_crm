import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

class DesktopEmployeeSection extends StatefulWidget {
  final List<Employee> employees;
  final Function(Employee)? onEmployeeTap;

  const DesktopEmployeeSection({
    super.key,
    required this.employees,
    this.onEmployeeTap,
  });

  @override
  State<DesktopEmployeeSection> createState() =>
      _DesktopEmployeeSectionState();
}

class _DesktopEmployeeSectionState
    extends State<DesktopEmployeeSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workingCount = widget.employees
        .where((e) => e.liveStatus == LiveStatus.working)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(workingCount),
          if (widget.employees.isEmpty)
            _buildEmptyState()
          else
            _buildList(),
        ],
      ),
    );
  }

  Widget _buildHeader(int workingCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Color(0xFF0D3199),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Live Attendance",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "$workingCount working • ${widget.employees.length} total",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 500),
      child: ListView.separated(
        controller: _scrollController,
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: widget.employees.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final employee = widget.employees[index];
          return _EmployeeTile(
            employee: employee,
            onTap: () =>
                widget.onEmployeeTap?.call(employee),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          "No active employees found",
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;

  const _EmployeeTile({
    required this.employee,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employee.statusColor;
    final statusText = employee.statusText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: const Color(0xFFF8FAFC),
        splashColor:
        const Color(0xFF0D3199).withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:
            Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              _buildAvatar(statusColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          employee.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        _buildStatusChip(
                            statusText, statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${employee.designation ?? ''} • ${employee.department ?? ''}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CompactTimeRow(employee: employee),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Color statusColor) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor:
          const Color(0xFF0D3199).withOpacity(0.1),
          child: Text(
            employee.initials,
            style: const TextStyle(
              color: Color(0xFF0D3199),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
      String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CompactTimeRow extends StatelessWidget {
  final Employee employee;

  const _CompactTimeRow({
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _timeLabel(
          Icons.login,
          employee.checkIn,
          const Color(0xFF10B981),
        ),
        const SizedBox(width: 16),
        _timeLabel(
          Icons.logout,
          employee.checkOut == '-'
              ? "Active"
              : employee.checkOut,
          const Color(0xFF64748B),
        ),
        if (employee.liveStatus ==
            LiveStatus.breakTime)
          Padding(
            padding:
            const EdgeInsets.only(left: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B)
                    .withOpacity(0.1),
                borderRadius:
                BorderRadius.circular(4),
              ),
              child: const Text(
                "BREAK",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _timeLabel(
      IconData icon, String time, Color color) {
    return Row(
      children: [
        Icon(icon,
            size: 12,
            color: color.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}