import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen_mobile.dart';
import 'package:my_app/dashboards/widgets/employee_social_feed_card.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/employee_dashboard/widget/bottom_nav.dart';
import 'package:my_app/survey/bloc/survey_employee_bloc.dart';
import 'package:my_app/survey/bloc/survey_employee_event.dart';
import 'package:my_app/survey/presentation/widgets/survey_feed_section.dart';

/// Mobile Activity Feed — same posts API, tabs, surveys, and card behavior as desktop.
class FeedScreenMobile extends StatefulWidget {
  const FeedScreenMobile({super.key});

  @override
  State<FeedScreenMobile> createState() => _FeedScreenMobileState();
}

class _FeedScreenMobileState extends State<FeedScreenMobile> {
  static const _terracotta = Color(0xFFC05C39);
  static const _cream = Color(0xFFFAF9F6);
  static const _border = Color(0xFFE8DFD4);
  static const _textMuted = Color(0xFF8A7A6E);

  String? _category = 'shared';
  static const _feedPageSize = 30;

  void _goBack() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      EmployeeDashboardNavigator.dashboard(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostBloc>().add(
            FetchPosts(category: _category, pageSize: _feedPageSize),
          );
      context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
    });
  }

  Future<void> _refresh() async {
    context.read<PostBloc>().add(
          FetchPosts(category: _category, pageSize: _feedPageSize),
        );
    context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _terracotta,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Activity Feed',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: RefreshIndicator(
        color: _terracotta,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              'Curated updates from across the organization.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _Tabs(
              selected: _category,
              accent: _terracotta,
              onSelected: (c) {
                setState(() => _category = c);
                context.read<PostBloc>().add(
                      FetchPosts(category: c, pageSize: _feedPageSize),
                    );
              },
            ),
            const SizedBox(height: 18),
            const SurveyFeedSection(autoLoad: false),
            const SizedBox(height: 12),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                final bloc = context.read<PostBloc>();
                if ((state is PostLoading || state is PostInitial) &&
                    bloc.posts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: CircularProgressIndicator(color: _terracotta),
                    ),
                  );
                }
                if (state is PostError && bloc.posts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.plusJakartaSans(
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }
                final posts = state is PostLoaded ? state.posts : bloc.posts;
                if (posts.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_rounded, color: _border, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'No feeds in this category yet.',
                          style: GoogleFonts.plusJakartaSans(
                            color: _textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: posts
                      .map(
                        (p) => EmployeeSocialFeedCard(
                          post: p,
                          accent: _terracotta,
                          border: _border,
                          shadowColor: _terracotta,
                          onOpen: () async {
                            await Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    PostDetailScreenMobile(postId: p.id),
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
    );
  }
}

class _Tabs extends StatelessWidget {
  final String? selected;
  final Color accent;
  final ValueChanged<String?> onSelected;
  const _Tabs({
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(String, String?)>[
      ('Shared', 'shared'),
      ('Announcements', 'announcement'),
      ('Culture', 'quote'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((it) {
          final isSel = selected == it.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => onSelected(it.$2),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: isSel ? accent : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? accent : const Color(0xFFE8DFD4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  it.$1,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSel ? Colors.white : const Color(0xFF5A4A3E),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
