import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_sidebar.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_topbar.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/utils/download_and_open.dart';

class EmployeeFeedScreenDesktop extends StatefulWidget {
  const EmployeeFeedScreenDesktop({super.key});

  @override
  State<EmployeeFeedScreenDesktop> createState() =>
      _EmployeeFeedScreenDesktopState();
}

class _EmployeeFeedScreenDesktopState extends State<EmployeeFeedScreenDesktop> {
  static const _bg = Color(0xFFF8FAFC);
  static const _textMain = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF475569);
  static const _purple = Color(0xFF7C3AED);

  String? _category;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostBloc>().add(FetchPosts(category: _category));
    });
  }

  void _toggleProfilePanel() {}

  void _goBack() {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/employeeDashboard',
      (route) => false,
    );
  }

  Future<void> _logout() async {
    await ApiClient().logout();
    await SecureStorageService().clearAll();
    try {
      if (!mounted) return;
      context.read<EmployeeBloc>().add(StopTaskPolling());
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/employeeLogin',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          DashboardSidebar(onLogout: _logout),
          Expanded(
            child: Column(
              children: [
                DashboardTopBar(onProfileClick: _toggleProfilePanel),
                Expanded(
                  child: RefreshIndicator(
                    color: _purple,
                    onRefresh: () async {
                      context.read<PostBloc>().add(FetchPosts(category: _category));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _goBack,
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: _textMain,
                                        ),
                                        tooltip: 'Back',
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Feeds',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: _textMain,
                                          letterSpacing: -0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 48),
                                    child: Text(
                                      'Curated updates from across the organization.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _SimpleTabs(
                                selected: _category,
                                onSelected: (c) {
                                  setState(() => _category = c);
                                  context.read<PostBloc>().add(FetchPosts(category: c));
                                },
                              ),
                              const SizedBox(height: 24),
                              BlocBuilder<PostBloc, PostState>(
                                builder: (context, state) {
                                  if (state is PostLoading || state is PostInitial) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 80),
                                      child: Center(
                                        child: CircularProgressIndicator(strokeWidth: 3, color: _purple),
                                      ),
                                    );
                                  }
                                  if (state is PostError) {
                                    return _ErrorWidget(message: state.message);
                                  }
                                  if (state is PostLoaded) {
                                    final posts = state.posts;
                                    if (posts.isEmpty) return const _Empty();
                                    return Column(
                                      children: posts
                                          .map((p) => _SocialFeedCard(
                                        post: p,
                                        onOpen: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => PostDetailScreen(postId: p.id),
                                            ),
                                          );
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleTabs extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _SimpleTabs({required this.selected, required this.onSelected});

  static const _purple = Color(0xFF7C3AED);

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
              color: isSel ? _purple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? _purple : const Color(0xFFEDE9FE),
                width: 2,
              ),
              boxShadow: isSel
                  ? [BoxShadow(color: _purple.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
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

class _SocialFeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onOpen;
  const _SocialFeedCard({required this.post, required this.onOpen});

  static const _purple = Color(0xFF525FE1);
  static const _textMain = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF334155);
  static const _borderPurple = Color(0xFF525FE1);

  bool get _hasLink => (post.link ?? '').trim().isNotEmpty;

  String _normalizeUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;
    final u = s.toLowerCase();
    if (u.startsWith('http://') || u.startsWith('https://')) return s;
    if (u.startsWith('www.')) return 'https://$s';
    if (s.contains('.') && !s.contains(' ')) return 'https://$s';
    return s;
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

  String _authorName() => (post.createdByFullName ?? post.createdByUsername ?? 'User').trim();

  String _designation() => (post.createdByDesignation ?? '').trim();

  String _initials() {
    final name = _authorName();
    if (name.isEmpty) return 'U';
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _timeAgo() {
    final d = DateTime.now().difference(post.createdAt.toLocal());
    if (d.inMinutes < 1) return 'JUST NOW';
    if (d.inMinutes < 60) return '${d.inMinutes}M AGO';
    if (d.inHours < 24) return '${d.inHours}H AGO';
    return DateFormat('MMM d').format(post.createdAt.toLocal()).toUpperCase();
  }

  Future<void> _handleMediaTap(BuildContext context, String url, String type) async {
    final lowerUrl = url.toLowerCase();
    final baseUrl = lowerUrl.split('?').first;

    bool isOfficeDoc() {
      final t = type.toLowerCase();
      return t.contains('word') ||
          t.contains('excel') ||
          t.contains('powerpoint') ||
          baseUrl.endsWith('.doc') ||
          baseUrl.endsWith('.docx') ||
          baseUrl.endsWith('.xls') ||
          baseUrl.endsWith('.xlsx') ||
          baseUrl.endsWith('.ppt') ||
          baseUrl.endsWith('.pptx');
    }

    bool isDownloadableDoc() {
      if (lowerUrl.endsWith('.pdf')) return true;
      return isOfficeDoc();
    }
    Future<void> downloadAndOpen() async {
      try {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading...')),
        );
        await downloadAndOpenUrl(ApiClient().dio, url);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: $e')),
        );
      }
    }

    // PDF or Link handling
    if (lowerUrl.endsWith('.pdf') || lowerUrl.startsWith('http') && type == 'link') {
      // If it's a PDF attachment, download+open locally; if it's a link attachment, open browser.
      if (lowerUrl.endsWith('.pdf')) {
        await downloadAndOpen();
      } else {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
      return;
    }

    // Office documents: download then open locally (Word/Excel/PowerPoint apps)
    if (isDownloadableDoc()) {
      await downloadAndOpen();
      return;
    }

    // Image/Video Full Screen handling
    _showFullScreenMedia(context, url, type);
  }

  void _showFullScreenMedia(BuildContext context, String url, String type) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.95),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _fileNameFromUrl(String url) {
    final u = url.split('?').first;
    final parts = u.split('/');
    return parts.isEmpty ? 'file' : (parts.last.isEmpty ? 'file' : parts.last);
  }

  bool _isImageFile(String url, String type) {
    final t = type.toLowerCase();
    if (t.contains('image')) return true;
    final u = url.toLowerCase().split('?').first;
    return u.endsWith('.png') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.webp') ||
        u.endsWith('.gif');
  }

  bool _isVideoFile(String url, String type) {
    final t = type.toLowerCase();
    if (t.contains('video')) return true;
    final u = url.toLowerCase().split('?').first;
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.webm');
  }

  bool _isPdf(String url, String type) {
    final t = type.toLowerCase();
    if (t.contains('pdf')) return true;
    final u = url.toLowerCase().split('?').first;
    return u.endsWith('.pdf');
  }

  IconData _fileIcon(String url, String type) {
    final u = url.toLowerCase().split('?').first;
    final t = type.toLowerCase();
    if (_isPdf(url, type)) return Icons.picture_as_pdf_rounded;
    if (t.contains('word') || u.endsWith('.doc') || u.endsWith('.docx')) {
      return Icons.description_rounded;
    }
    if (t.contains('excel') || u.endsWith('.xls') || u.endsWith('.xlsx')) {
      return Icons.table_chart_rounded;
    }
    if (t.contains('powerpoint') || u.endsWith('.ppt') || u.endsWith('.pptx')) {
      return Icons.slideshow_rounded;
    }
    if (u.endsWith('.zip') || u.endsWith('.rar') || t.contains('zip')) {
      return Icons.folder_zip_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  Widget _attachmentPreview(BuildContext context, String url, String type) {
    // Image
    if (_isImageFile(url, type)) {
      return GestureDetector(
        onTap: () => _handleMediaTap(context, url, type),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            url,
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

    // Video (preview as play tile)
    if (_isVideoFile(url, type)) {
      return GestureDetector(
        onTap: () => _handleMediaTap(context, url, type),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: const Color(0xFF0F172A),
            alignment: Alignment.center,
            child: const Icon(Icons.play_circle_fill_rounded,
                size: 72, color: Colors.white),
          ),
        ),
      );
    }

    // Any other file (pdf/word/etc): show file tile, click to open/download
    final name = _fileNameFromUrl(url);
    final icon = _fileIcon(url, type);
    final isPdf = _isPdf(url, type);
    final accent = isPdf ? const Color(0xFFEF4444) : _purple;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: InkWell(
        onTap: () => _handleMediaTap(context, url, type),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderPurple, width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.open_in_new_rounded, size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = (post.createdByProfilePhoto ?? '').trim();
    final hero = post.attachments.isEmpty ? null : post.attachments.first;
    final heroUrl = hero?.file ?? '';
    final heroType = hero?.fileType ?? '';

    final subtitle = _designation().isEmpty ? _timeAgo() : '${_designation().toUpperCase()} • ${_timeAgo()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderPurple, width: 2),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _Avatar(photoUrl: photo, initials: _initials()),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _authorName(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: _textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _purple,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (heroUrl.isNotEmpty) _attachmentPreview(context, heroUrl, heroType),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasLink) ...[
                  InkWell(
                    onTap: () => _openLink(context),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: _purple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (post.link ?? '').trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _purple,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (post.title?.isNotEmpty ?? false) ...[
                  Text(
                    post.title!.trim(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _textMain,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  post.content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _textMuted,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!post.isRead) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => context.read<PostBloc>().add(MarkPostAsRead(post.id)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: const Text(
                        'MARK AS SEEN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
        image: photoUrl.isNotEmpty ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover) : null,
      ),
      child: photoUrl.isEmpty
          ? Center(
        child: Text(initials,
            style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w900, fontSize: 13)),
      )
          : null,
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