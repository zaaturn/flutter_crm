import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my_app/dashboards/domain/models/post_attachment.dart';
import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';
import 'package:my_app/leave_management/screens/mobile_screen/widget/leave_manager_colors.dart';

/// Full-screen post reader (feed-style: edge-to-edge media, overlay close).
class PostDetailScreenMobile extends StatefulWidget {
  const PostDetailScreenMobile({super.key, required this.postId});

  final int postId;

  @override
  State<PostDetailScreenMobile> createState() => _PostDetailScreenMobileState();
}

class _PostDetailScreenMobileState extends State<PostDetailScreenMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostBloc>().add(FetchPostById(widget.postId));
      context.read<PostBloc>().add(MarkPostAsRead(widget.postId));
    });
  }

  static bool _isImage(String fileType, String url) {
    final ft = fileType.toLowerCase();
    if (ft.contains('image')) return true;
    final u = url.toLowerCase();
    return u.endsWith('.png') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.webp') ||
        u.endsWith('.gif');
  }

  static bool _isVideo(String fileType, String url) {
    final ft = fileType.toLowerCase();
    if (ft.contains('video')) return true;
    final u = url.toLowerCase();
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.webm');
  }

  Future<void> _openLink(String raw) async {
    final s = raw.trim();
    if (s.isEmpty) return;
    final uri = Uri.tryParse(
      s.toLowerCase().startsWith('http')
          ? s
          : (s.contains('.') ? 'https://$s' : s),
    );
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading || state is PostInitial) {
            return Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Colors.black),
                const Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                ),
                _CloseButton(topInset: topInset),
              ],
            );
          }
          if (state is PostError) {
            return Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Colors.black),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                _CloseButton(topInset: topInset),
              ],
            );
          }
          if (state is PostDetailLoaded) {
            return _ImmersivePostBody(
              post: state.post,
              topInset: topInset,
              onClose: () => Navigator.of(context).pop(),
              onOpenLink: _openLink,
              isImage: _isImage,
              isVideo: _isVideo,
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              _CloseButton(topInset: topInset),
            ],
          );
        },
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topInset + 8,
      left: 12,
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}

class _ImmersivePostBody extends StatelessWidget {
  const _ImmersivePostBody({
    required this.post,
    required this.topInset,
    required this.onClose,
    required this.onOpenLink,
    required this.isImage,
    required this.isVideo,
  });

  final PostModel post;
  final double topInset;
  final VoidCallback onClose;
  final Future<void> Function(String) onOpenLink;
  final bool Function(String fileType, String url) isImage;
  final bool Function(String fileType, String url) isVideo;

  String _authorName() {
    final n = (post.createdByFullName ?? '').trim();
    if (n.isNotEmpty) return n;
    final u = (post.createdByUsername ?? '').trim();
    if (u.isNotEmpty) return u;
    return 'Member';
  }

  String _timeAgo() {
    final d = DateTime.now().difference(post.createdAt);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return DateFormat('MMM d').format(post.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final title = post.title?.trim().isNotEmpty == true
        ? post.title!.trim()
        : post.category.replaceAll('_', ' ');
    final link = (post.link ?? '').trim();

    PostAttachment? hero;
    if (post.attachments.isNotEmpty) {
      final a = post.attachments.first;
      if (isImage(a.fileType, a.file) || isVideo(a.fileType, a.file)) {
        hero = a;
      }
    }

    final List<PostAttachment> extras;
    if (post.attachments.isEmpty) {
      extras = [];
    } else if (hero != null) {
      extras = post.attachments.length > 1
          ? post.attachments.sublist(1)
          : <PostAttachment>[];
    } else {
      extras = post.attachments;
    }

    if (hero != null && isImage(hero.fileType, hero.file)) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Image.network(
                hero.file,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white38),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFF121212),
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white38,
                      size: 56,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _CloseButton(topInset: topInset),
        ],
      );
    }

    if (hero != null && isVideo(hero.fileType, hero.file)) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: const ColoredBox(color: Colors.black),
            ),
          ),
          Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              size: MediaQuery.sizeOf(context).shortestSide * 0.22,
              color: Colors.white54,
            ),
          ),
          _CloseButton(topInset: topInset),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: LeaveManagerColors.background,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, topInset + 56, 20, 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LeaveManagerColors.primary,
                        LeaveManagerColors.primaryDark,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      _Avatar(url: (post.createdByProfilePhoto ?? '').trim()),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _authorName(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _timeAgo(),
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    32 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          post.category.replaceAll('_', ' ').toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
                            color: LeaveManagerColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: -0.4,
                          color: LeaveManagerColors.onBackground,
                        ),
                      ),
                      if (post.content.trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          post.content.trim(),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 1.45,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (link.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => onOpenLink(link),
                            icon: Icon(
                              Icons.link_rounded,
                              color: LeaveManagerColors.primary,
                            ),
                            label: Text(
                              link,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: LeaveManagerColors.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              side: BorderSide(
                                color: LeaveManagerColors.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (extras.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Attachments',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: LeaveManagerColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...extras.map((a) {
                          final name = a.file.split('/').isNotEmpty
                              ? a.file.split('/').last
                              : a.file;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: LeaveManagerColors.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_file_rounded,
                                  color: LeaveManagerColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _CloseButton(topInset: topInset),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white24,
        backgroundImage: NetworkImage(url),
      );
    }
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.white.withValues(alpha: 0.25),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
    );
  }
}
