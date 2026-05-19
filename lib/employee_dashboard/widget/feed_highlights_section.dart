import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen.dart';

/// Small dashboard section: Quote of the day + Birthday + New hire.
class FeedHighlightsSection extends StatefulWidget {
  const FeedHighlightsSection({super.key});

  @override
  State<FeedHighlightsSection> createState() => _FeedHighlightsSectionState();
}

class _FeedHighlightsSectionState extends State<FeedHighlightsSection> {
  static const _textMain = Color(0xFF1E293B);
  static const _textMuted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);

  Future<({PostModel? quote, List<PostModel> birthday, List<PostModel> newHire})>
      _load(PostRepository repo) async {
    final results = await Future.wait<List<PostModel>>([
      repo.fetchPosts(category: 'quote', pageSize: 1),
      repo.fetchPosts(category: 'birthday', pageSize: 3),
      repo.fetchPosts(category: 'new_hire', pageSize: 3),
    ]);
    return (
      quote: results[0].isEmpty ? null : results[0].first,
      birthday: results[1],
      newHire: results[2],
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PostRepository>();

    return FutureBuilder(
      future: _load(repo),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 6, bottom: 6),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }
        final data = snap.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Highlights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 860 ? 3 : (c.maxWidth >= 560 ? 2 : 1);
                final items = <Widget>[
                  _QuoteCard(post: data.quote),
                  _MiniListCard(
                    title: 'Birthday Wishes',
                    icon: Icons.cake_rounded,
                    tint: const Color(0xFFFFF7ED),
                    accent: const Color(0xFFF97316),
                    posts: data.birthday,
                  ),
                  _MiniListCard(
                    title: 'New Hire Welcome',
                    icon: Icons.person_add_alt_1_rounded,
                    tint: const Color(0xFFECFDF5),
                    accent: const Color(0xFF10B981),
                    posts: data.newHire,
                  ),
                ];

                if (cols == 1) {
                  return Column(
                    children: [
                      for (final w in items) ...[
                        w,
                        const SizedBox(height: 12),
                      ]
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: items[0]),
                    const SizedBox(width: 12),
                    Expanded(child: items[1]),
                    if (cols == 3) ...[
                      const SizedBox(width: 12),
                      Expanded(child: items[2]),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none_rounded,
                      color: _textMuted, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'These cards update when admin publishes shared posts.',
                      style: TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/feed'),
                    child: const Text('Open Feed'),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final PostModel? post;
  const _QuoteCard({required this.post});

  static const _border = Color(0xFFE2E8F0);
  static const _textMain = Color(0xFF1E293B);
  static const _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.format_quote_rounded, color: Color(0xFF7C3AED)),
              SizedBox(width: 8),
              Text(
                'Quote',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: _textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post?.content.trim().isNotEmpty == true
                ? post!.content.trim()
                : 'No quote published yet.',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.25,
              color: _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: post == null
                  ? null
                  : () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => PostDetailScreen(postId: post!.id),
                        ),
                      );
                    },
              child: const Text('View'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color tint;
  final Color accent;
  final List<PostModel> posts;

  const _MiniListCard({
    required this.title,
    required this.icon,
    required this.tint,
    required this.accent,
    required this.posts,
  });

  static const _border = Color(0xFFE2E8F0);
  static const _textMain = Color(0xFF1E293B);
  static const _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (posts.isEmpty)
            const Text(
              'Nothing to show yet.',
              style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600),
            )
          else
            Column(
              children: posts
                  .take(3)
                  .map(
                    (p) => InkWell(
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => PostDetailScreen(postId: p.id),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                (p.title?.trim().isNotEmpty == true
                                        ? p.title!.trim()
                                        : p.content.trim())
                                    .trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _textMain,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                size: 18, color: _textMuted),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

