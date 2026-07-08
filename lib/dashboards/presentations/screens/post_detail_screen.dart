import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';
import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/widgets/app_color.dart';
import 'package:my_app/dashboards/widgets/post_view_count_chip.dart';
import 'package:my_app/dashboards/widgets/post_attachments_preview.dart';

/// Opens from notifications via `post_id`.
class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostBloc>().add(FetchPostById(widget.postId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'Post',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading || state is PostInitial) {
            return const Center(
              child: CircularProgressIndicator(),
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
          if (state is PostDetailLoaded) {
            return _Body(post: state.post);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final PostModel post;
  const _Body({required this.post});

  @override
  Widget build(BuildContext context) {
    final created = DateFormat('MMM d, yyyy • h:mm a').format(post.createdAt);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderChip(category: post.category),
          const SizedBox(height: 12),
          Text(
            post.title?.trim().isNotEmpty == true ? post.title!.trim() : 'Post',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(created, style: const TextStyle(color: AppColors.textMuted)),
              if (post.canSeeViewers || post.isRead) ...[
                const SizedBox(width: 12),
                PostFeedStatusRow(post: post),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (post.attachments.isNotEmpty) ...[
            PostAttachmentsGallery(
              attachments: post.attachments,
              height: 280,
            ),
            const SizedBox(height: 16),
            const Text(
              'Attachments',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...post.attachments.map((a) {
              final name = (a.file.split('/').isNotEmpty)
                  ? a.file.split('/').last
                  : a.file;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String category;
  const _HeaderChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final c = category.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cyanLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        c,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.cyan,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

