import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen.dart';
import 'package:my_app/dashboards/widgets/employee_social_feed_card.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/survey/bloc/survey_employee_bloc.dart';
import 'package:my_app/survey/bloc/survey_employee_event.dart';
import 'package:my_app/survey/presentation/widgets/survey_feed_section.dart';

class EmployeeFeedScreenDesktop extends StatefulWidget {
  const EmployeeFeedScreenDesktop({super.key});

  @override
  State<EmployeeFeedScreenDesktop> createState() =>
      _EmployeeFeedScreenDesktopState();
}

class _EmployeeFeedScreenDesktopState extends State<EmployeeFeedScreenDesktop> {
  static const _textMain = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF475569);
  static const _green = EmployeeDashboardV2Theme.greenMid;

  String? _category = 'shared';
  static const _feedPageSize = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<PostBloc>().add(
              FetchPosts(category: _category, pageSize: _feedPageSize),
            );
        context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
      } catch (e) {
        debugPrint('Activity Feed init failed: $e');
      }
    });
  }

  void _goBack() {
    EmployeeDashboardNavigator.dashboard(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDashboardV2Theme.shell,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: EmployeeDashboardV2Theme.shell,
                border: Border(bottom: BorderSide(color: EmployeeDashboardV2Theme.cardBorder)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back_rounded, color: _textMain),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Activity Feed',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: EmployeeDashboardV2Theme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _green,
                onRefresh: () async {
                  context.read<PostBloc>().add(
            FetchPosts(category: _category, pageSize: _feedPageSize),
          );
                  context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      // Social-feed style: keep a narrow centered column on desktop.
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Curated updates from across the organization.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: EmployeeDashboardV2Theme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SimpleTabs(
                            selected: _category,
                            onSelected: (c) {
                              setState(() => _category = c);
                              context.read<PostBloc>().add(FetchPosts(category: c, pageSize: _feedPageSize));
                            },
                          ),
                          const SizedBox(height: 22),
                          const SurveyFeedSection(autoLoad: false),
                          const SizedBox(height: 16),
                          BlocBuilder<PostBloc, PostState>(
                            builder: (context, state) {
                              final bloc = context.read<PostBloc>();
                              if ((state is PostLoading || state is PostInitial) &&
                                  bloc.posts.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 80),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: _green,
                                    ),
                                  ),
                                );
                              }
                              if (state is PostError && bloc.posts.isEmpty) {
                                return _ErrorWidget(message: state.message);
                              }
                              final posts = state is PostLoaded
                                  ? state.posts
                                  : bloc.posts;
                              if (posts.isEmpty) return const _Empty();
                              return Column(
                                children: posts
                                    .map(
                                      (p) => EmployeeSocialFeedCard(
                                        post: p,
                                        onOpen: () async {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PostDetailScreen(postId: p.id),
                                            ),
                                          );
                                          if (!context.mounted) return;
                                          context.read<PostBloc>().add(
                                                FetchPosts(
                                                  category: _category,
                                                  pageSize: _feedPageSize,
                                                ),
                                              );
                                        },
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleTabs extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _SimpleTabs({required this.selected, required this.onSelected});

  static const _accent = EmployeeDashboardV2Theme.greenMid;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String?)>[
      ('Shared', 'shared'),
      ('Announcements', 'announcement'),
      ('Culture', 'quote'),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((it) {
        final isSel = selected == it.$2;
        return InkWell(
          onTap: () => onSelected(it.$2),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? _accent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? _accent : EmployeeDashboardV2Theme.cardBorder,
                width: 2,
              ),
              boxShadow: isSel
                  ? [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Text(
              it.$1,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSel ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_rounded, color: Color(0xFFEDE9FE), size: 48),
          SizedBox(height: 16),
          Text('No feeds in this category yet.',
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}