import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen.dart';

class SharedPostsSection extends StatefulWidget {
  const SharedPostsSection({super.key});

  @override
  State<SharedPostsSection> createState() => _SharedPostsSectionState();
}

class _SharedPostsSectionState extends State<SharedPostsSection> {
  // --- DAXARROW Purple Palette ---
  static const _purple = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _textMain = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _borderPurple = Color(0xFFEDE9FE);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Shared Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _textMain,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/feed'),
              child: const Text(
                'View all',
                style: TextStyle(color: _purple, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderPurple, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _purple.withOpacity(0.04),
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
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _purple)),
                  );
                }

                final posts = snap.data ?? [];

                if (posts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'No fresh items shared in the last 24h',
                        style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    color: _borderPurple.withOpacity(0.5),
                  ),
                  itemBuilder: (context, i) => _Row(post: posts[i]),
                );
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
  const _Row({required this.post});

  @override
  Widget build(BuildContext context) {
    final title = post.title?.trim().isNotEmpty == true ? post.title!.trim() : 'Untitled Post';


    final localTime = post.createdAt.toLocal();
    final formattedTime = DateFormat('hh:mm a').format(localTime);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.rss_feed_rounded, color: Color(0xFF7C3AED), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formattedTime,
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFEDE9FE), size: 14),
          ],
        ),
      ),
    );
  }
}