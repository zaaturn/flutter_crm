import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen_mobile.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/employee_dashboard/widget/employee_feed_chrome.dart';

class SharedPostsSection extends StatefulWidget {
  final bool hideHeader;
  final bool scrollable;
  final bool v2Flat;

  const SharedPostsSection({
    super.key,
    this.hideHeader = false,
    this.scrollable = false,
    this.v2Flat = false,
  });

  @override
  State<SharedPostsSection> createState() => _SharedPostsSectionState();
}

class _SharedPostsSectionState extends State<SharedPostsSection> {
  static const _textMain = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _creamBg = Color(0xFFFAF3E0);
  static const _beigeCard = Color(0xFFEADBC8);
  static const _terracotta = Color(0xFFC05E41);
  static const _coffee = Color(0xFF3E2723);
  static const _coffeeMuted = Color(0xFF8D6E63);

  Future<List<PostModel>> _load(PostRepository repo) async {
    final allPosts = await repo.fetchPosts(category: 'shared', pageSize: 10);
    final now = DateTime.now();

    // FILTER: Using .toLocal() ensures the comparison happens in the user's timezone
    final freshPosts = allPosts.where((post) {
      final localCreatedAt = post.createdAt.toLocal();
      final difference = now.difference(localCreatedAt).inHours;
      return difference < 24;
    }).toList();

    // SORT: Latest ones first
    freshPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return freshPosts;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PostRepository>();
    final chrome = EmployeeFeedChrome.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.hideHeader) ...[
          Row(
            children: [
              Text(
                'Shared Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: narrow ? _coffee : _textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => EmployeeDashboardNavigator.feed(context),
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: narrow ? _terracotta : chrome.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (widget.v2Flat) ...[
          FutureBuilder<List<PostModel>>(
            future: _load(repo),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final posts = snap.data ?? [];
              if (posts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  child: Center(
                    child: Text(
                      'No items shared',
                      style: TextStyle(
                        color: narrow ? _coffeeMuted : _textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }

              final list = ListView.separated(
                primary: false,
                shrinkWrap: !widget.scrollable,
                physics: widget.scrollable
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: chrome.borderAccent.withValues(alpha: 0.65),
                ),
                itemBuilder: (context, i) => _Row(post: posts[i], chrome: chrome),
              );

              if (!widget.scrollable) return list;
              return SizedBox(height: 260, child: list);
            },
          ),
        ] else
        Container(
          decoration: BoxDecoration(
            color: narrow ? _beigeCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: narrow
                  ? _terracotta.withValues(alpha: 0.14)
                  : chrome.borderAccent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (narrow ? _terracotta : chrome.accent)
                    .withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FutureBuilder<List<PostModel>>(
              future: _load(repo),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: chrome.accent,
                      ),
                    ),
                  );
                }

                final posts = snap.data ?? [];

                if (posts.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'No fresh items shared in the last 24h',
                        style: TextStyle(
                          color: narrow ? _coffeeMuted : _textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                final list = ListView.separated(
                  primary: false,
                  shrinkWrap: !widget.scrollable,
                  physics: widget.scrollable
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    color: chrome.borderAccent.withValues(alpha: 0.65),
                  ),
                  itemBuilder: (context, i) => _Row(post: posts[i], chrome: chrome),
                );

                if (!widget.scrollable) return list;

                // When used inside fixed-height cards (v2 bento grid), keep
                // card heights aligned by scrolling the list instead.
                return SizedBox(height: 260, child: list);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final PostModel post;
  final EmployeeFeedChrome chrome;
  const _Row({required this.post, required this.chrome});

  @override
  Widget build(BuildContext context) {
    final title = post.title?.trim().isNotEmpty == true ? post.title!.trim() : 'Untitled Post';
    final narrow = MediaQuery.sizeOf(context).width < 900;


    final localTime = post.createdAt.toLocal();
    final formattedTime = DateFormat('hh:mm a').format(localTime);

    return InkWell(
      onTap: () {
        final narrow = MediaQuery.sizeOf(context).width < 900;
        if (narrow) {
          Navigator.of(context)
              .push<void>(
            PageRouteBuilder<void>(
              opaque: true,
              fullscreenDialog: true,
              pageBuilder: (_, __, ___) => PostDetailScreenMobile(
                postId: post.id,
              ),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: child,
                );
              },
            ),
          )
              .then((_) {
            if (context.mounted) {
              context.read<PostBloc>().add(
                    FetchPosts(category: 'shared'),
                  );
            }
          });
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(postId: post.id),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: narrow
                    ? const Color(0xFFFFFFFF).withValues(alpha: 0.6)
                    : chrome.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.rss_feed_rounded,
                color: narrow ? const Color(0xFFC05E41) : chrome.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: narrow ? const Color(0xFF3E2723) : const Color(0xFF0F172A),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formattedTime,
              style: TextStyle(
                color: narrow ? const Color(0xFFC05E41) : chrome.accent,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: narrow
                  ? const Color(0xFF8D6E63).withValues(alpha: 0.75)
                  : chrome.borderAccent,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}