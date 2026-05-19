import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/leave_management/models/leave_request.dart';

class LeaveManagerRequestCard extends StatelessWidget {
  const LeaveManagerRequestCard({
    super.key,
    required this.leave,
    required this.onDetails,
    required this.onReview,
  });

  final LeaveRequest leave;
  final VoidCallback onDetails;
  final VoidCallback onReview;

  static final _monthDay = DateFormat('MMM d');
  static const _templeOrange = Color(0xFFB14D1E);
  static const _cardBg = Color(0xFFE9D8C8);

  @override
  Widget build(BuildContext context) {
    final typeStyle = _typeChipStyle(leave.displayLeaveType);
    final pending = leave.isPending;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.employeeName?.trim() ?? 'Employee #${leave.employeeId}',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1C1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Applied ${_monthDay.format(leave.appliedAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1C1E).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _TypeChip(label: leave.displayLeaveType, style: typeStyle),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                _DataTile(
                  label: 'DURATION',
                  value: '${_monthDay.format(leave.startDate)} - ${_monthDay.format(leave.endDate)}',
                  baseColor: _templeOrange,
                ),
                const SizedBox(width: 24),
                _DataTile(
                  label: 'DAYS',
                  value: _daysLabel(leave.totalDays),
                  baseColor: _templeOrange,
                ),
                const Spacer(),
                _StatusPill(leave: leave),
              ],
            ),
          ),
          const SizedBox(height: 12),
          pending
              ? _PrimaryButton(label: 'Review', onPressed: onReview)
              : _OutlineButton(label: 'Details', onPressed: onDetails),
        ],
      ),
    );
  }

  String _daysLabel(double days) => days.round() <= 1 ? '1 Day' : '${days.round()} Days';

  _TypeChipColors _typeChipStyle(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('sick')) {
      return const _TypeChipColors(background: Color(0xFFE0E7FF), foreground: Color(0xFF4338CA));
    }
    return const _TypeChipColors(background: Color(0xFFF3E8FF), foreground: Color(0xFF7E22CE));
  }
}

class _DataTile extends StatelessWidget {
  const _DataTile({required this.label, required this.value, required this.baseColor});
  final String label;
  final String value;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: baseColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: baseColor,
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.style});
  final String label;
  final _TypeChipColors style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: style.foreground,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.leave});
  final LeaveRequest leave;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white.withOpacity(0.5);
    Color fg = const Color(0xFF475569);
    IconData? icon;

    if (leave.isPending) {
      bg = const Color(0xFFFFF7ED);
      fg = const Color(0xFFC2410C);
    } else if (leave.isApproved) {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF15803D);
      icon = Icons.check_circle_rounded;
    } else if (leave.isRejected) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFB91C1C);
      icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(
            leave.isPending ? 'Pending' : (leave.isApproved ? 'Approved' : 'Rejected'),
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF1A1C1E)),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF4338CA)], // indigo
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChipColors {
  const _TypeChipColors({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}