import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/core/ui/adaptive_layout.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';

import '../../bloc/survey_employee_bloc.dart';
import '../../bloc/survey_employee_event.dart';
import '../../bloc/survey_employee_state.dart';
import '../../models/survey_models.dart';
import '../../navigation/survey_flow_controller.dart';
import 'survey_submission.dart';

/// Scrolling billboard under the greeting when surveys are assigned.
class SurveyAssignmentBillboard extends StatefulWidget {
  const SurveyAssignmentBillboard({super.key, this.autoLoad = true});

  final bool autoLoad;

  @override
  State<SurveyAssignmentBillboard> createState() =>
      _SurveyAssignmentBillboardState();
}

class _SurveyAssignmentBillboardState extends State<SurveyAssignmentBillboard> {
  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          context
              .read<SurveyEmployeeBloc>()
              .add(const SurveyEmployeeLoadActive());
        } catch (_) {}
      });
    }
  }

  Future<void> _open(BuildContext context, SurveySummary survey) async {
    final done = await SurveyFlowController.openTakeSurvey(context, survey.id);
    if (!context.mounted) return;
    if (done == true) {
      context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
      showSurveySuccessSnack(title: survey.title);
      return;
    }
    context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
  }

  @override
  Widget build(BuildContext context) {
    final mobile = AdaptiveLayout.useMobileUi(context);
    // Same catchy yellow as the workspace switch button.
    const bg = EmployeeDashboardV2Theme.navYellow;
    const chipBg = Color(0xFFE0A820);
    const fg = Color(0xFF1A1208);

    return BlocBuilder<SurveyEmployeeBloc, SurveyEmployeeState>(
      builder: (context, state) {
        final pending = state.activeSurveys
            .where((s) => !s.alreadySubmitted)
            .toList();
        if (pending.isEmpty) return const SizedBox.shrink();

        final message = pending.length == 1
            ? 'Survey assigned · ${pending.first.title} · Tap to take'
            : 'Surveys assigned · ${pending.map((s) => s.title).join('  ·  ')} · Tap to take';

        return Padding(
          padding: EdgeInsets.only(bottom: mobile ? 12 : 0, top: mobile ? 0 : 14),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(mobile ? 14 : 16),
            child: InkWell(
              onTap: () => _open(context, pending.first),
              borderRadius: BorderRadius.circular(mobile ? 14 : 16),
              child: SizedBox(
                height: mobile ? 52 : 56,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.assignment_outlined,
                            size: 15,
                            color: fg,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pending.length == 1 ? 'SURVEY' : '${pending.length} SURVEYS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: fg,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MarqueeText(
                        text: message,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: fg,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: fg,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Continuous horizontal ticker (single pass — no duplicate copy).
class _MarqueeText extends StatefulWidget {
  const _MarqueeText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _textWidth = 0;
  double _viewportWidth = 0;
  bool _measureQueued = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _queueMeasure();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _queueMeasure() {
    if (_measureQueued) return;
    _measureQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureQueued = false;
      if (!mounted) return;
      final painter = TextPainter(
        text: TextSpan(text: widget.text, style: widget.style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final tw = painter.width;
      if ((tw - _textWidth).abs() < 0.5 && _controller.isAnimating) return;
      setState(() => _textWidth = tw);
      _restart();
    });
  }

  void _restart() {
    _controller.stop();
    if (_textWidth <= 0 || _viewportWidth <= 0) return;
    final travel = _textWidth + _viewportWidth + 48;
    final seconds = (travel / 55).clamp(10.0, 30.0);
    _controller
      ..duration = Duration(milliseconds: (seconds * 1000).round())
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vw = constraints.maxWidth;
        if ((vw - _viewportWidth).abs() > 0.5) {
          _viewportWidth = vw;
          _queueMeasure();
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // One line only: enter from right, exit left, then restart.
            final start = _viewportWidth;
            final end = -_textWidth;
            final dx = start + (end - start) * _controller.value;

            return ClipRect(
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: Text(
                  widget.text,
                  maxLines: 1,
                  softWrap: false,
                  style: widget.style,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

