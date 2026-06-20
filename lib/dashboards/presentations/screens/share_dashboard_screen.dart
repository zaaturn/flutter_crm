import 'package:flutter/material.dart';

class ShareDashboardScreen extends StatelessWidget {
  final VoidCallback onOpenShared;
  final VoidCallback onOpenCulture;
  final VoidCallback onOpenAnnouncements;
  final VoidCallback? onOpenSurveys;

  const ShareDashboardScreen({
    super.key,
    required this.onOpenShared,
    required this.onOpenCulture,
    required this.onOpenAnnouncements,
    this.onOpenSurveys,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create and publish content for employee dashboards and feed.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _Card(
                title: 'Shared Items',
                subtitle: 'Uploads and shared links',
                icon: Icons.folder_shared_outlined,
                onTap: onOpenShared,
              ),
              _Card(
                title: 'Culture Boards',
                subtitle: 'Quotes, birthdays, new hires',
                icon: Icons.dashboard_customize_outlined,
                onTap: onOpenCulture,
              ),
              _Card(
                title: 'Announcements',
                subtitle: 'Broadcast updates',
                icon: Icons.campaign_outlined,
                onTap: onOpenAnnouncements,
              ),
              if (onOpenSurveys != null)
                _Card(
                  title: 'Surveys',
                  subtitle: 'Create polls & view employee responses',
                  icon: Icons.poll_outlined,
                  onTap: onOpenSurveys!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _Card({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF8A79E5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF8A79E5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF604EB8)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

