import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../block/leave_bloc.dart';
import '../block/leave_event.dart';
import '../models/leave_request.dart';

class AdminLeaveDetailScreen extends StatelessWidget {
  const AdminLeaveDetailScreen({
    super.key,
    required this.leave,
  });

  final LeaveRequest leave;

  // Elite SaaS Palette from your shared images
  static const Color _bgScreen = Color(0xFFFEF7F1);
  static const Color _textMain = Color(0xFF1A1C1E);
  static const Color _textMuted = Color(0xFF74777F);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(leave);
    final statusBg = statusColor.withOpacity(0.08);

    return Scaffold(
      backgroundColor: _bgScreen,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _textMain,
        title: Text(
          'Request Detail',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: statusColor.withOpacity(0.12), width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getStatusIcon(leave), color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    leave.statusLabel.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Applied on ${DateFormat('MMM d, yyyy').format(leave.appliedAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // EMPLOYEE INFO
            _DetailSection(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF4C4DBC).withOpacity(0.1),
                    child: Text(
                      leave.employeeName?[0].toUpperCase() ?? 'E',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4C4DBC),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.employeeName ?? 'Unknown',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textMain,
                        ),
                      ),
                      Text(
                        'Team Member',
                        style: GoogleFonts.inter(fontSize: 13, color: _textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LEAVE DATA SECTION
            _DetailSection(
              title: 'Leave Information',
              child: Column(
                children: [
                  _InfoRow(label: 'TYPE', value: leave.displayLeaveType, icon: Icons.category_rounded),
                  _InfoRow(
                    label: 'DURATION',
                    value: '${DateFormat('MMM d').format(leave.startDate)} - ${DateFormat('MMM d').format(leave.endDate)}',
                    icon: Icons.calendar_month_rounded,
                  ),
                  _InfoRow(label: 'TOTAL', value: '${leave.totalDays} Days', icon: Icons.timer_rounded, isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // REASON SECTION
            _DetailSection(
              title: 'Reason for Leave',
              child: Text(
                leave.reason.isNotEmpty ? leave.reason : 'No specific reason provided.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: _textMain.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: leave.isPending ? _buildActionButtons(context) : null,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionBtn(
              label: 'Reject',
              color: const Color(0xFFB91C1C),
              onPressed: () {
                context.read<LeaveBloc>().add(RejectLeaveEvent(leaveId: leave.id!));
                Navigator.pop(context);
              },
              isOutline: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionBtn(
              label: 'Approve',
              color: const Color(0xFF15803D),
              onPressed: () {
                context.read<LeaveBloc>().add(ApproveLeaveEvent(leaveId: leave.id!));
                Navigator.pop(context);
              },
              isOutline: false,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(LeaveRequest leave) {
    if (leave.isApproved) return const Color(0xFF15803D);
    if (leave.isRejected) return const Color(0xFFB91C1C);
    return const Color(0xFFF1833E);
  }

  IconData _getStatusIcon(LeaveRequest leave) {
    if (leave.isApproved) return Icons.check_rounded;
    if (leave.isRejected) return Icons.close_rounded;
    return Icons.hourglass_top_rounded;
  }
}

class _DetailSection extends StatelessWidget {
  final Widget child;
  final String? title;
  const _DetailSection({required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFE9D8C8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFB14D1E).withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB14D1E).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: const Color(0xFF1A1C1E),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}
class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool isLast;
  const _InfoRow({required this.label, required this.value, required this.icon, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB14D1E).withOpacity(0.7)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF74777F))),
          const Spacer(),
          Text(value, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1C1E))),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isOutline;
  const _ActionBtn({required this.label, required this.color, required this.onPressed, required this.isOutline});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isOutline ? Colors.transparent : color,
        foregroundColor: isOutline ? color : Colors.white,
        side: isOutline ? BorderSide(color: color, width: 1.5) : BorderSide.none,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16)),
    );
  }
}