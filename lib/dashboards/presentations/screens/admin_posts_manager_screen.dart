import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen.dart';
import 'package:my_app/dashboards/widgets/app_color.dart';

import 'admin_seen_by_screen.dart';

class AdminPostsManagerScreen extends StatefulWidget {
  final String? initialCategory; // null = all

  const AdminPostsManagerScreen({super.key, this.initialCategory});

  @override
  State<AdminPostsManagerScreen> createState() => _AdminPostsManagerScreenState();
}

class _AdminPostsManagerScreenState extends State<AdminPostsManagerScreen> {
  String? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostBloc>().add(FetchPosts(category: _category));
    });
  }

  void _refresh() {
    context.read<PostBloc>().add(FetchPosts(category: _category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Feed Manager',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            _CategoryRow(
              selected: _category,
              onSelected: (c) {
                setState(() => _category = c);
                _refresh();
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoading || state is PostInitial) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is PostError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                if (state is PostLoaded) {
                  if (state.posts.isEmpty) {
                    return const _Empty();
                  }
                  return Column(
                    children: state.posts
                        .map((p) => _PostAdminCard(post: p))
                        .toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _CategoryRow({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String?)>[
      ('All', null),
      ('Shared', 'shared'),
      ('Announcements', 'announcement'),
      ('Quotes', 'quote'),
      ('Birthday', 'birthday'),
      ('New hire', 'new_hire'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((it) {
          final sel = selected == it.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              selected: sel,
              label: Text(it.$1),
              onSelected: (_) => onSelected(it.$2),
              selectedColor: AppColors.cyan,
              labelStyle: TextStyle(
                color: sel ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.border),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PostAdminCard extends StatelessWidget {
  final PostModel post;
  const _PostAdminCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final title = post.title?.trim().isNotEmpty == true
        ? post.title!.trim()
        : post.category.replaceAll('_', ' ');
    final date = DateFormat('MMM d, yyyy').format(post.createdAt);
    final isPublished = post.isPublished;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _StatusPill(published: isPublished),
              ],
            ),
            const SizedBox(height: 6),
            Text(date, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 10),
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.25,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Chip(text: post.category.toUpperCase()),
                if (post.attachments.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _Chip(text: '${post.attachments.length} FILES'),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => PostDetailScreen(postId: post.id),
                      ),
                    );
                  },
                  child: const Text('Preview'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => AdminSeenByScreen(postId: post.id),
                      ),
                    );
                  },
                  child: const Text('Seen-by'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isPublished
                      ? null
                      : () {
                          context
                              .read<PostBloc>()
                              .add(PublishPostRequested(post.id));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.cyan.withValues(alpha: 0.4),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Publish',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool published;
  const _StatusPill({required this.published});

  @override
  Widget build(BuildContext context) {
    final bg = published ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED);
    final fg = published ? const Color(0xFF10B981) : const Color(0xFFF97316);
    final label = published ? 'PUBLISHED' : 'DRAFT';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF334155),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.textMuted),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No posts found.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

