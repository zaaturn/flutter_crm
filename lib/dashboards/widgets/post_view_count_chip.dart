import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/models/post_seen_by_viewer.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/widgets/app_color.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';

/// Eye + view count and Seen badge on one row.
class PostFeedStatusRow extends StatelessWidget {
  const PostFeedStatusRow({
    super.key,
    required this.post,
    this.compact = false,
  });

  final PostModel post;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final showEye = post.canSeeViewers;
    final showSeen = post.isRead;

    if (!showEye && !showSeen) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showEye) PostViewCountChip(post: post, compact: compact),
        if (showEye && showSeen) SizedBox(width: compact ? 10 : 12),
        if (showSeen) PostSeenBadge(compact: compact),
      ],
    );
  }
}

/// Read/seen indicator — visible to employees and admins.
class PostSeenBadge extends StatelessWidget {
  const PostSeenBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.done_all_rounded,
          size: compact ? 14 : 16,
          color: EmployeeDashboardV2Theme.greenMid,
        ),
        const SizedBox(width: 4),
        Text(
          'Seen',
          style: GoogleFonts.plusJakartaSans(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: EmployeeDashboardV2Theme.greenMid,
          ),
        ),
      ],
    );
  }
}

/// View count chip with eye icon. Tap opens seen-by bottom sheet.
class PostViewCountChip extends StatelessWidget {
  const PostViewCountChip({
    super.key,
    required this.post,
    this.compact = false,
    this.lightOnDark = false,
  });

  final PostModel post;
  final bool compact;
  final bool lightOnDark;

  @override
  Widget build(BuildContext context) {
    if (!post.canSeeViewers) return const SizedBox.shrink();
    final count = post.viewCount ?? 0;
    final label = compact
        ? '$count view${count == 1 ? '' : 's'}'
        : '$count view${count == 1 ? '' : 's'}';
    final fg = lightOnDark
        ? Colors.white.withValues(alpha: 0.9)
        : EmployeeDashboardV2Theme.textMuted;
    final accent = lightOnDark ? Colors.white : AppColors.cyan;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => PostViewersSheet.show(context, postId: post.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility_outlined, size: compact ? 16 : 18, color: accent),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostViewersSheet {
  PostViewersSheet._();

  static Future<void> show(BuildContext context, {required int postId}) {
    final repo = context.read<PostRepository>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RepositoryProvider<PostRepository>.value(
        value: repo,
        child: _PostViewersSheetBody(postId: postId),
      ),
    );
  }
}

class _PostViewersSheetBody extends StatefulWidget {
  const _PostViewersSheetBody({required this.postId});

  final int postId;

  @override
  State<_PostViewersSheetBody> createState() => _PostViewersSheetBodyState();
}

class _PostViewersSheetBodyState extends State<_PostViewersSheetBody> {
  late Future<List<PostSeenByViewer>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<PostSeenByViewer>> _load() {
    return context.read<PostRepository>().fetchSeenBy(widget.postId);
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.visibility_outlined, color: AppColors.cyan),
                const SizedBox(width: 10),
                Text(
                  'Viewed by',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: FutureBuilder<List<PostSeenByViewer>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Could not load viewers',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _retry,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final viewers = snap.data ?? [];
                  if (viewers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No views yet.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: viewers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final v = viewers[i];
                      final ago = formatPostViewTimeAgo(v.readAt);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.cyanLight,
                          child: Text(
                            v.fullName.isNotEmpty
                                ? v.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
                        title: Text(
                          v.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          [
                            if (v.phone != null && v.phone!.isNotEmpty) v.phone!,
                            if (ago.isNotEmpty) ago,
                          ].join(' · '),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
