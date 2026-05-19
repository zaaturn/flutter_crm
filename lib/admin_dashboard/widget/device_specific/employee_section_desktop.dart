import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _DesktopEmployeeSectionState extends State<DesktopEmployeeSection> {
  final ScrollController _scrollController = ScrollController();

  // --- Daxarrow Theme Constants ---
  static const _brandPurple = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _borderPurple = Color(0xFFDDD6FE);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workingCount = widget.employees
        .where((e) => e.liveStatus == LiveStatus.working)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        // --- ADDED THEME BORDER ---
        border: Border.all(
          color: isDark ? _brandPurple.withOpacity(0.3) : _borderPurple,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _brandPurple.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(workingCount, isDark),
          const Divider(height: 1, color: _borderPurple),
          if (widget.employees.isEmpty)
            _buildEmptyState()
          else
            _buildList(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(int workingCount, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _brandPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: _brandPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Live Attendance",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "$workingCount working • ${widget.employees.length} total staff",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 500),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: widget.employees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final employee = widget.employees[index];
          return _EmployeeTile(
            employee: employee,
            onTap: () => widget.onEmployeeTap?.call(employee),
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          "No active employees found",
          style: GoogleFonts.plusJakartaSans(
            color: _textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;
  final bool isDark;

  const _EmployeeTile({
    required this.employee,
    this.onTap,
    required this.isDark,
  });

  static const _brandPurple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final statusColor = employee.statusColor;
    final statusText = employee.statusText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155).withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? _brandPurple.withOpacity(0.1) : const Color(0xFFF1F5F9),
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(statusColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        employee.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      _buildStatusChip(statusText, statusColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${employee.designation ?? 'Team Member'} • ${employee.department ?? 'General'}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
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
    );
  }

  Widget _buildAvatar(Color statusColor) {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _brandPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              employee.initials,
              style: GoogleFonts.plusJakartaSans(
                color: _brandPurple,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CompactTimeRow extends StatelessWidget {
  final Employee employee;
  const _CompactTimeRow({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _timeLabel(
          Icons.login_rounded,
          employee.checkIn,
          const Color(0xFF10B981),
        ),
        const SizedBox(width: 16),
        _timeLabel(
          Icons.logout_rounded,
          employee.checkOut == '-' ? "STILL ACTIVE" : employee.checkOut,
          const Color(0xFF64748B),
        ),
        if (employee.liveStatus == LiveStatus.breakTime)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "BREAK",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _timeLabel(IconData icon, String time, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          time,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}