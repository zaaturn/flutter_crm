import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen_mobile.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/employee_dashboard/widget/bottom_nav.dart';
import 'package:my_app/survey/bloc/survey_employee_bloc.dart';
import 'package:my_app/survey/bloc/survey_employee_event.dart';
import 'package:my_app/survey/presentation/widgets/survey_feed_section.dart';
import 'package:my_app/leave_management/screens/mobile_screen/widget/leave_manager_colors.dart';

class FeedScreenMobile extends StatefulWidget {
  const FeedScreenMobile({super.key});

  @override
  State<FeedScreenMobile> createState() => _FeedScreenMobileState();
}

class _FeedScreenMobileState extends State<FeedScreenMobile> {
  static const _textMuted = Color(0xFF64748B);

  String? _category;

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
      context.read<PostBloc>().add(FetchPosts(category: _category));
      context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LeaveManagerColors.background,
      appBar: AppBar(
        backgroundColor: LeaveManagerColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: LeaveManagerColors.primary,
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(
          'Feeds',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: LeaveManagerColors.onBackground,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: LeaveManagerColors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PostBloc>().add(FetchPosts(category: _category));
          context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const SizedBox(height: 4),
            _Tabs(
              selected: _category,
              onSelected: (c) {
                setState(() => _category = c);
                context.read<PostBloc>().add(FetchPosts(category: c));
              },
            ),
            const SizedBox(height: 16),
            const SurveyFeedSection(),
            const SizedBox(height: 8),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoading || state is PostInitial) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: LeaveManagerColors.primary,
                      ),
                    ),
                  );
                }
                if (state is PostError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(state.message, style: const TextStyle(color: _textMuted)),
                    ),
                  );
                }
                if (state is PostLoaded) {
                  if (state.posts.isEmpty) return const _Empty();
                  return Column(
                    children: state.posts
                        .map((p) => _Row(
                              post: p,
                              onOpen: () {
                                Navigator.of(context)
                                    .push<void>(
                                  PageRouteBuilder<void>(
                                    opaque: true,
                                    fullscreenDialog: true,
                                    pageBuilder: (_, __, ___) =>
                                        PostDetailScreenMobile(
                                      postId: p.id,
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
                                  if (!context.mounted) return;
                                  context.read<PostBloc>().add(
                                        FetchPosts(category: _category),
                                      );
                                });
                              },
                            ))
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

class _Tabs extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _Tabs({required this.selected, required this.onSelected});

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
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isSel
                      ? LeaveManagerColors.primary
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSel
                        ? LeaveManagerColors.primary
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  it.$1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                    color: isSel ? Colors.white : const Color(0xFF475569),
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

class _Row extends StatelessWidget {
  final PostModel post;
  final VoidCallback onOpen;
  const _Row({required this.post, required this.onOpen});

  bool get _hasLink => (post.link ?? '').trim().isNotEmpty;

  String _authorName() {
    final n = (post.createdByFullName ?? '').trim();
    if (n.isNotEmpty) return n;
    final u = (post.createdByUsername ?? '').trim();
    if (u.isNotEmpty) return u;
    return 'User';
  }

  String _designation() => (post.createdByDesignation ?? '').trim();

  String _initials() {
    final parts = _authorName()
        .split(RegExp(r'\s+'))
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    final first = parts.first.trim();
    final last = parts.length > 1 ? parts.last.trim() : '';
    final a = first.isNotEmpty ? first[0] : 'U';
    final b = last.isNotEmpty ? last[0] : '';
    return (a + b).toUpperCase();
  }

  String _timeAgo() {
    final d = DateTime.now().difference(post.createdAt);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return DateFormat('MMM d').format(post.createdAt);
  }

  bool _isImage(String fileType, String url) {
    final ft = fileType.toLowerCase();
    if (ft.contains('image')) return true;
    final u = url.toLowerCase();
    return u.endsWith('.png') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.webp') ||
        u.endsWith('.gif');
  }

  Future<void> _openLink(BuildContext context) async {
    final raw = (post.link ?? '').trim();
    if (raw.isEmpty) return;
    final uri = Uri.tryParse(_normalizeUrl(raw));
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  String _normalizeUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;
    final u = s.toLowerCase();
    if (u.startsWith('http://') || u.startsWith('https://')) return s;
    if (u.startsWith('www.')) return 'https://$s';
    if (s.contains('.') && !s.contains(' ')) return 'https://$s';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final title = post.title?.trim().isNotEmpty == true
        ? post.title!.trim()
        : post.category.replaceAll('_', ' ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LeaveManagerColors.primary.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(
                    photoUrl: (post.createdByProfilePhoto ?? '').trim(),
                    initials: _initials(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _authorName(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _designation().isEmpty
                              ? _timeAgo().toUpperCase()
                              : '${_designation().toUpperCase()} • ${_timeAgo().toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (post.attachments.isNotEmpty) ...[
                _HeroMedia(
                  attachments: post.attachments,
                  isImage: _isImage,
                ),
                const SizedBox(height: 12),
              ],
              if (_hasLink) ...[
                InkWell(
                  onTap: () => _openLink(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LeaveManagerColors.primary),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 16,
                          color: LeaveManagerColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            post.link!.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: LeaveManagerColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              if (post.content.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  post.content.trim(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A6062),
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (!post.isRead)
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => context
                        .read<PostBloc>()
                        .add(MarkPostAsRead(post.id)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: LeaveManagerColors.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'MARK AS SEEN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: LeaveManagerColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String photoUrl;
  final String initials;
  const _Avatar({required this.photoUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Image.network(
          photoUrl,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _Initials(initials: initials),
        ),
      );
    }
    return _Initials(initials: initials);
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  const _Initials({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: LeaveManagerColors.primary,
        ),
      ),
    );
  }
}

class _HeroMedia extends StatelessWidget {
  final List<dynamic> attachments;
  final bool Function(String fileType, String url) isImage;
  const _HeroMedia({required this.attachments, required this.isImage});

  bool _isVideo(String fileType, String url) {
    final ft = fileType.toLowerCase();
    if (ft.contains('video')) return true;
    final u = url.toLowerCase();
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.webm');
  }

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    final a = attachments.first;
    final file = (a.file as String);
    final type = (a.fileType as String?) ?? '';
    final isImg = isImage(type, file);
    final isVid = _isVideo(type, file);
    if (isImg) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFF1F5F9),
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
      );
    }
    if (isVid) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.play_circle_fill_rounded,
            size: 56, color: Colors.white),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.inbox_outlined, color: Color(0xFF94A3B8)),
          SizedBox(width: 10),
          Expanded(
            child: Text('No posts found.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

