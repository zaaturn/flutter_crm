import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

class DesktopEmployeeSection extends StatefulWidget {
  final List<Employee> employees;
  final int totalEmployeeCount;
  final Function(Employee)? onEmployeeTap;
  final bool flat;
  final bool compact;
  final double? maxListHeight;

  const DesktopEmployeeSection({
    super.key,
    required this.employees,
    this.totalEmployeeCount = 0,
    this.onEmployeeTap,
    this.flat = false,
    this.compact = false,
    this.maxListHeight,
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
    final breakCount = widget.employees
        .where((e) => e.liveStatus == LiveStatus.breakTime)
        .length;
    final loggedOutCount = widget.employees
        .where((e) => e.liveStatus == LiveStatus.loggedOut)
        .length;
    final totalStaff = widget.totalEmployeeCount > 0
        ? widget.totalEmployeeCount
        : widget.employees.length;

    final content = widget.flat
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                totalStaff: totalStaff,
                loggedInToday: widget.employees.length,
                workingCount: workingCount,
                breakCount: breakCount,
                loggedOutCount: loggedOutCount,
                isDark: isDark,
              ),
              Divider(
                height: 1,
                color: const Color(0xFFEDF2EF),
              ),
              Expanded(
                child: widget.employees.isEmpty
                    ? _buildEmptyState()
                    : _buildList(isDark),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                totalStaff: totalStaff,
                loggedInToday: widget.employees.length,
                workingCount: workingCount,
                breakCount: breakCount,
                loggedOutCount: loggedOutCount,
                isDark: isDark,
              ),
              Divider(
                height: 1,
                color: _borderPurple,
              ),
              if (widget.employees.isEmpty)
                _buildEmptyState()
              else
                _buildList(isDark),
            ],
          );

    if (widget.flat) return content;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
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
      child: content,
    );
  }

  Widget _buildHeader({
    required int totalStaff,
    required int loggedInToday,
    required int workingCount,
    required int breakCount,
    required int loggedOutCount,
    required bool isDark,
  }) {
    final stats = _buildStatBoxes(
      totalStaff: totalStaff,
      loggedInToday: loggedInToday,
      workingCount: workingCount,
      breakCount: breakCount,
      loggedOutCount: loggedOutCount,
    );

    final icon = Container(
      padding: EdgeInsets.all(widget.compact ? 8 : 10),
      decoration: BoxDecoration(
        color: _brandPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.sensors_rounded,
        color: _brandPurple,
        size: widget.compact ? 18 : 22,
      ),
    );

    final title = Text(
      'Live Attendance',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.plusJakartaSans(
        fontSize: widget.compact ? 15 : 18,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : _textPrimary,
        letterSpacing: -0.5,
      ),
    );

    if (widget.compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 10),
                Expanded(child: title),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: stats,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 16),
          title,
          const Spacer(),
          Flexible(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: stats,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatBoxes({
    required int totalStaff,
    required int loggedInToday,
    required int workingCount,
    required int breakCount,
    required int loggedOutCount,
  }) {
    return [
      _StatBox(
        label: 'Total',
        count: totalStaff,
        bg: _purpleLight,
        border: _borderPurple,
        labelColor: _brandPurple,
        countColor: _textPrimary,
        compact: widget.compact,
      ),
      _StatBox(
        label: 'Logged In',
        count: loggedInToday,
        bg: const Color(0xFFEEF2FF),
        border: const Color(0xFFC7D2FE),
        labelColor: const Color(0xFF4338CA),
        countColor: _textPrimary,
        compact: widget.compact,
      ),
      _StatBox(
        label: 'Working',
        count: workingCount,
        bg: const Color(0xFFECFDF5),
        border: const Color(0xFFA7F3D0),
        labelColor: const Color(0xFF047857),
        countColor: const Color(0xFF065F46),
        compact: widget.compact,
      ),
      _StatBox(
        label: 'Break',
        count: breakCount,
        bg: const Color(0xFFFFFBEB),
        border: const Color(0xFFFDE68A),
        labelColor: const Color(0xFFB45309),
        countColor: const Color(0xFF92400E),
        compact: widget.compact,
      ),
      _StatBox(
        label: 'Out',
        count: loggedOutCount,
        bg: const Color(0xFFFEF2F2),
        border: const Color(0xFFFECACA),
        labelColor: const Color(0xFFB91C1C),
        countColor: const Color(0xFF991B1B),
        compact: widget.compact,
      ),
    ];
  }

  Widget _buildList(bool isDark) {
    final listView = ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        widget.compact ? 16 : 20,
        widget.compact ? 10 : 16,
        widget.compact ? 16 : 20,
        widget.compact ? 14 : 24,
      ),
      itemCount: widget.employees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final employee = widget.employees[index];
        return _EmployeeTile(
          employee: employee,
          onTap: () => widget.onEmployeeTap?.call(employee),
          isDark: isDark,
          flat: widget.flat,
        );
      },
    );

    if (widget.flat) return listView;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxListHeight ?? 500,
      ),
      child: listView,
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.compact ? 28 : 60),
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
  final bool flat;

  const _EmployeeTile({
    required this.employee,
    this.onTap,
    required this.isDark,
    this.flat = false,
  });

  static const _brandPurple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final statusColor = employee.statusColor;
    final statusText = employee.statusText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(flat ? 0 : 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: flat
              ? Colors.transparent
              : (isDark
                  ? const Color(0xFF334155).withOpacity(0.3)
                  : Colors.white),
          borderRadius: flat ? null : BorderRadius.circular(16),
          border: flat
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFEDF2EF)),
                )
              : Border.all(
                  color: isDark
                      ? _brandPurple.withOpacity(0.1)
                      : const Color(0xFFF1F5F9),
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
                        employee.displayName,
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

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.count,
    required this.bg,
    required this.border,
    required this.labelColor,
    required this.countColor,
    this.compact = false,
  });

  final String label;
  final int count;
  final Color bg;
  final Color border;
  final Color labelColor;
  final Color countColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: labelColor,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(width: compact ? 5 : 8),
          Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: compact ? 13 : 16,
              fontWeight: FontWeight.w800,
              color: countColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}