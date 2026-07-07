import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';

import 'employee_dashboard_v2_theme.dart';

const Duration _kQuoteFreshness = Duration(hours: 24);

String employeeV2TimeGreeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

String _quoteBody(PostModel post) {
  final title = (post.title ?? '').trim();
  if (title.isNotEmpty) return title;
  final content = post.content.trim();
  return content.isNotEmpty ? content : 'New update posted.';
}

class EmployeeDashboardV2Header extends StatefulWidget {
  const EmployeeDashboardV2Header({super.key});

  @override
  State<EmployeeDashboardV2Header> createState() =>
      _EmployeeDashboardV2HeaderState();
}

class _EmployeeDashboardV2HeaderState extends State<EmployeeDashboardV2Header> {
  PostModel? _quote;
  bool _quoteLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  static bool _isFresh(PostModel post) {
    return DateTime.now().difference(post.createdAt) <= _kQuoteFreshness;
  }

  Future<void> _loadQuote() async {
    try {
      final posts = await context
          .read<PostRepository>()
          .fetchPosts(category: 'quote', pageSize: 1);
      if (!mounted) return;
      final fresh =
          posts.isNotEmpty && _isFresh(posts.first) ? posts.first : null;
      setState(() {
        _quote = fresh;
        _quoteLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _quoteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLine = DateFormat('EEEE, MMMM d · yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: BlocBuilder<EmployeeBloc, EmployeeState>(
                builder: (context, state) {
                  final name = state.employee?.displayName ?? 'there';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLine,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: EmployeeDashboardV2Theme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${employeeV2TimeGreeting()}, $name 👋',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: EmployeeDashboardV2Theme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _quoteBanner(),
      ],
    );
  }

  Widget _quoteBanner() {
    if (_quoteLoading) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: EmployeeDashboardV2Theme.quoteGradient,
          borderRadius:
              BorderRadius.circular(EmployeeDashboardV2Theme.cardRadius),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: EmployeeDashboardV2Theme.quoteGradient,
        borderRadius: BorderRadius.circular(EmployeeDashboardV2Theme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: EmployeeDashboardV2Theme.greenDark.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 16),
            spreadRadius: -20,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 24,
            top: 8,
            child: Icon(
              Icons.format_quote_rounded,
              size: 96,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: _quote == null ? _emptyQuoteContent() : _quoteContent(_quote!),
          ),
        ],
      ),
    );
  }

  Widget _emptyQuoteContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAILY QUOTE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'No quote today',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Take a breath — small steps still move you forward.',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _quoteContent(PostModel quote) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAILY QUOTE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '"${_quoteBody(quote)}"',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        if ((quote.createdByFullName ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '— ${quote.createdByFullName}',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
