import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/widgets/post_attachments_preview.dart';
import 'package:my_app/dashboards/widgets/post_media_utils.dart';
import 'package:my_app/dashboards/widgets/post_view_count_chip.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/employee_dashboard/widget/employee_avatar.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/utils/download_and_open.dart';

class EmployeeSocialFeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onOpen;
  final Color accent;
  final Color border;
  final Color? shadowColor;

  const EmployeeSocialFeedCard({
    super.key,
    required this.post,
    required this.onOpen,
    this.accent = EmployeeDashboardV2Theme.greenMid,
    this.border = EmployeeDashboardV2Theme.cardBorder,
    this.shadowColor,
  });

  static const _textMain = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF334155);

  Color get _accent => accent;
  Color get _border => border;

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
    final dt = post.createdAt.toLocal();
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
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

  @override
  Widget build(BuildContext context) {
    final photo = (post.createdByProfilePhoto ?? '').trim();

    final subtitle = _designation().isEmpty ? _timeAgo() : '${_designation().toUpperCase()} • ${_timeAgo()}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: (shadowColor ?? EmployeeDashboardV2Theme.greenDark)
                    .withValues(alpha: 0.06),
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
              if (post.attachments.isNotEmpty)
                PostAttachmentsPreview(
                  attachments: post.attachments,
                  onTap: (attachment) => _handleMediaTap(
                    context,
                    resolvePostAttachmentUrl(attachment.file),
                    attachment.fileType,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.attachments.isNotEmpty) const SizedBox(height: 10),
                    if (_hasLink) ...[
                      InkWell(
                        onTap: () => _openLink(context),
                        child: Row(
                          children: [
                            Icon(Icons.link, size: 16, color: _accent),
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!post.isRead) ...[
                          ElevatedButton(
                            onPressed: () => context
                                .read<PostBloc>()
                                .add(MarkPostAsRead(post.id)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
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
                          const SizedBox(width: 12),
                        ],
                        PostFeedStatusRow(post: post, compact: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

