import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/survey_models.dart';
import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';

class SurveyUserResponsesTab extends StatelessWidget {
  const SurveyUserResponsesTab({
    super.key,
    required this.responses,
    this.loading = false,
    this.mobile = false,
    this.onRefresh,
  });

  final List<SurveyIndividualResponse> responses;
  final bool loading;
  final bool mobile;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (loading && responses.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: mobile ? SurveyMobileTheme.primary : SurveyTheme.purple,
        ),
      );
    }

    if (responses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: mobile ? 48 : 80),
          Center(
            child: Text(
              'No individual responses yet.',
              style: GoogleFonts.plusJakartaSans(
                color: mobile ? SurveyMobileTheme.textMuted : SurveyTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(mobile ? 16 : 32),
      itemCount: responses.length,
      separatorBuilder: (_, __) => SizedBox(height: mobile ? 10 : 12),
      itemBuilder: (context, index) => _EmployeeResponseTile(
        response: responses[index],
        mobile: mobile,
      ),
    );
  }
}

class _EmployeeResponseTile extends StatefulWidget {
  const _EmployeeResponseTile({
    required this.response,
    required this.mobile,
  });

  final SurveyIndividualResponse response;
  final bool mobile;

  @override
  State<_EmployeeResponseTile> createState() => _EmployeeResponseTileState();
}

class _EmployeeResponseTileState extends State<_EmployeeResponseTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.mobile ? SurveyMobileTheme.primary : SurveyTheme.purple;
    final textMain = widget.mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain;
    final textMuted = widget.mobile ? SurveyMobileTheme.textMuted : SurveyTheme.textMuted;
    final surface = widget.mobile ? SurveyMobileTheme.card : SurveyTheme.surface;
    final df = DateFormat('dd MMM yyyy · h:mm a');
    final submitted = widget.response.submittedAt != null
        ? df.format(widget.response.submittedAt!.toLocal())
        : null;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: accent.withValues(alpha: 0.12),
                    child: Text(
                      widget.response.employeeName.isNotEmpty
                          ? widget.response.employeeName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.response.employeeName,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: textMain,
                          ),
                        ),
                        if (widget.response.subtitle.isNotEmpty)
                          Text(
                            widget.response.subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: textMuted,
                            ),
                          ),
                        if (submitted != null)
                          Text(
                            submitted,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: textMuted,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                ...widget.response.answers.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.questionText.isNotEmpty
                              ? a.questionText
                              : 'Question ${a.questionId}',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.displayValue.isNotEmpty ? a.displayValue : '—',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            height: 1.45,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
