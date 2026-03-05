import 'package:flutter/material.dart';
import 'package:my_app/dashboards/widgets/app_color.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _ctrl = TextEditingController();
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(
            () => setState(() => _hasContent = _ctrl.text.trim().isNotEmpty));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Announcement',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Share updates and important news with your team.',
            style: TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),

          // Compose box
          _ComposeBox(
            controller: _ctrl,
            hasContent: _hasContent,
            onPublish: _onPublish,
          ),
          const SizedBox(height: 20),

          // Info banner
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.infoIcon, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'This announcement will be distributed based on your '
                        'selected audience targeting on the right. Pinned '
                        'announcements stay active on the dashboard for 48 hours.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPublish() {
    // TODO: dispatch PublishAnnouncement event / call PostBloc
  }
}

// ── Compose box ───────────────────────────────────────────────────────────────

class _ComposeBox extends StatelessWidget {
  final TextEditingController controller;
  final bool hasContent;
  final VoidCallback onPublish;

  const _ComposeBox({
    required this.controller,
    required this.hasContent,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text area with avatar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.cyanLight,
                  child: const Icon(Icons.person,
                      color: AppColors.cyan, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 8,
                    maxLines: 12,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Write something to announce...',
                      hintStyle: TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Toolbar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _ToolbarBtn(icon: Icons.image_outlined),
                _ToolbarBtn(icon: Icons.attach_file_outlined),
                _ToolbarBtn(
                    icon: Icons.emoji_emotions_outlined),
                _ToolbarBtn(icon: Icons.text_fields_outlined),
                const Spacer(),
                const Text(
                  'Draft saved 2m ago',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: hasContent ? onPublish : null,
                  icon: const Text(
                    'Publish',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  label: const Icon(Icons.arrow_forward,
                      size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    AppColors.cyan.withOpacity(0.45),
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8)),
                    elevation: 0,
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

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  const _ToolbarBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: AppColors.textSecondary),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    );
  }
}