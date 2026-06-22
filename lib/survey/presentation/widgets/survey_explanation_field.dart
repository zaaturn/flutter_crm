import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';
import '../../utils/survey_word_count.dart';

/// Follow-up explanation after a choice question (no visible word counter).
class SurveyExplanationField extends StatefulWidget {
  const SurveyExplanationField({
    super.key,
    required this.label,
    required this.maxWords,
    required this.value,
    required this.onChanged,
    this.mobile = false,
    this.required = false,
  });

  final String label;
  final int maxWords;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool mobile;
  final bool required;

  @override
  State<SurveyExplanationField> createState() => _SurveyExplanationFieldState();
}

class _SurveyExplanationFieldState extends State<SurveyExplanationField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant SurveyExplanationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.value ?? '';
    if (next != _controller.text) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String raw) {
    final limited = truncateToWordLimit(raw, widget.maxWords);
    if (limited != raw) {
      _controller.value = TextEditingValue(
        text: limited,
        selection: TextSelection.collapsed(offset: limited.length),
      );
    }
    widget.onChanged(limited);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.mobile ? SurveyMobileTheme.primaryDark : SurveyTheme.purple;
    final textMuted = widget.mobile ? SurveyMobileTheme.textMuted : SurveyTheme.textMuted;
    final textMain = widget.mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label + (widget.required ? ' *' : ''),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: textMain,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: _handleChanged,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Share more details…',
            filled: true,
            fillColor: widget.mobile ? SurveyMobileTheme.fieldFill : SurveyTheme.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textMuted.withValues(alpha: 0.25)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textMuted.withValues(alpha: 0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 1.5),
            ),
          ),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.45,
            color: textMain,
          ),
        ),
      ],
    );
  }
}
