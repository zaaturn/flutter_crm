import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/leave_request.dart';
import 'leave_manager_colors.dart';
import 'leave_manager_request_card.dart';

class LeaveManagerRequestsSection extends StatelessWidget {
  const LeaveManagerRequestsSection({
    super.key,
    required this.title,
    required this.leaves,
    required this.onViewAll,
    required this.showViewAll,
    required this.onOpenDetail,
    required this.onOpenReview,
    this.emptyMessage = 'No requests in this view.',
  });

  final String title;
  final List<LeaveRequest> leaves;
  final VoidCallback onViewAll;
  final bool showViewAll;
  final void Function(LeaveRequest leave) onOpenDetail;
  final void Function(LeaveRequest leave) onOpenReview;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: LeaveManagerColors.onBackground,
                  ),
                ),
              ),
              if (showViewAll)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'VIEW ALL',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: LeaveManagerColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (leaves.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: LeaveManagerColors.outline,
                ),
              ),
            )
          else
            ...leaves.map(
              (leave) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LeaveManagerRequestCard(
                  leave: leave,
                  onDetails: () => onOpenDetail(leave),
                  onReview: () => onOpenReview(leave),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
