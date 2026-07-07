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
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/employee_dashboard/widget/employee_avatar.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/survey/bloc/survey_employee_bloc.dart';
import 'package:my_app/survey/bloc/survey_employee_event.dart';
import 'package:my_app/survey/presentation/widgets/survey_feed_section.dart';
import 'package:my_app/utils/download_and_open.dart';

class EmployeeFeedScreenDesktop extends StatefulWidget {
  const EmployeeFeedScreenDesktop({super.key});

  @override
  State<EmployeeFeedScreenDesktop> createState() =>
      _EmployeeFeedScreenDesktopState();
}

class _EmployeeFeedScreenDesktopState extends State<EmployeeFeedScreenDesktop> {
  static const _textMain = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF475569);
  static const _green = EmployeeDashboardV2Theme.greenMid;

  String? _category;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostBloc>().add(FetchPosts(category: _category));
      context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
    });
  }

  void _toggleProfilePanel() {}

  void _goBack() {
    EmployeeDashboardNavigator.dashboard(context);
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
      backgroundColor: EmployeeDashboardV2Theme.shell,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: EmployeeDashboardV2Theme.shell,
                border: Border(bottom: BorderSide(color: EmployeeDashboardV2Theme.cardBorder)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back_rounded, color: _textMain),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Activity Feed',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: EmployeeDashboardV2Theme.textDark,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _logout,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _green,
                onRefresh: () async {
                  context.read<PostBloc>().add(FetchPosts(category: _category));
                  context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      // Social-feed style: keep a narrow centered column on desktop.
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Curated updates from across the organization.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: EmployeeDashboardV2Theme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SimpleTabs(
                            selected: _category,
                            onSelected: (c) {
                              setState(() => _category = c);
                              context.read<PostBloc>().add(FetchPosts(category: c));
                            },
                          ),
                          const SizedBox(height: 22),
                          const SurveyFeedSection(),
                          const SizedBox(height: 16),
                          BlocBuilder<PostBloc, PostState>(
                            builder: (context, state) {
                              if (state is PostLoading || state is PostInitial) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 80),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: _green,
                                    ),
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
                                      .map(
                                        (p) => _SocialFeedCard(
                                          post: p,
                                          onOpen: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => PostDetailScreen(postId: p.id),
                                              ),
                                            );
                                          },
                                        ),
                                      )
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
    );
  }
}

class _SimpleTabs extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _SimpleTabs({required this.selected, required this.onSelected});

  static const _accent = EmployeeDashboardV2Theme.greenMid;

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
              color: isSel ? _accent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? _accent : EmployeeDashboardV2Theme.cardBorder,
                width: 2,
              ),
              boxShadow: isSel
                  ? [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
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

  static const _accent = EmployeeDashboardV2Theme.greenMid;
  static const _textMain = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF334155);
  static const _border = EmployeeDashboardV2Theme.cardBorder;

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
    final accent = isPdf ? const Color(0xFFEF4444) : _accent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: InkWell(
        onTap: () => _handleMediaTap(context, url, type),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: EmployeeDashboardV2Theme.greenDark.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                EmployeeAvatar(
                  photoUrl: photo,
                  initials: _initials(),
                  size: 36,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _authorName(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _accent,
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
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (heroUrl.isNotEmpty) const SizedBox(height: 10),
                if (_hasLink) ...[
                  InkWell(
                    onTap: () => _openLink(context),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: _accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (post.link ?? '').trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _accent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (post.title?.isNotEmpty ?? false) ...[
                  Text(
                    post.title!.trim(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textMain,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  post.content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _textMuted,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!post.isRead) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => context.read<PostBloc>().add(MarkPostAsRead(post.id)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      ),
                      child: const Text(
                        'MARK AS SEEN',
                        style: TextStyle(
                          fontSize: 10,
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