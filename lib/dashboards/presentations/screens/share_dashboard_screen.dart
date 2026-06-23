import 'package:flutter/material.dart';
import 'package:my_app/core/widgets/app_material_icon.dart';
import 'package:my_app/core/widgets/survey_icons.dart';

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

  List<_CardData> _cardItems() {
    return [
      _CardData(
        title: 'Shared Items',
        subtitle: 'Uploads and shared links',
        icon: Icons.folder_shared_outlined,
        onTap: onOpenShared,
      ),
      _CardData(
        title: 'Culture Boards',
        subtitle: 'Quotes, birthdays, new hires',
        icon: Icons.dashboard_customize_outlined,
        onTap: onOpenCulture,
      ),
      _CardData(
        title: 'Announcements',
        subtitle: 'Broadcast updates',
        icon: Icons.campaign_outlined,
        onTap: onOpenAnnouncements,
      ),
      if (onOpenSurveys != null)
        _CardData(
          title: 'Surveys',
          subtitle: 'Create polls & view employee responses',
          iconWidget: const SurveyIcon(
            type: SurveyIconType.poll,
            size: 22,
            color: Color(0xFF604EB8),
          ),
          onTap: onOpenSurveys!,
        ),
    ];
  }

  int _crossAxisCount(double width, int itemCount) {
    if (width >= 1200) return itemCount.clamp(1, 4);
    if (width >= 900) return itemCount.clamp(1, 3);
    if (width >= 560) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final items = _cardItems();

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
          SizedBox(
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : MediaQuery.sizeOf(context).width - 64;
                final crossAxisCount = _crossAxisCount(width, items.length);

                return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 96,
                ),
                itemBuilder: (context, index) => _Card(
                  title: items[index].title,
                  subtitle: items[index].subtitle,
                  icon: items[index].icon,
                  iconWidget: items[index].iconWidget,
                  onTap: items[index].onTap,
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CardData {
  const _CardData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconWidget,
    required this.onTap,
  }) : assert(icon != null || iconWidget != null);

  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onTap;
}

class _Card extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onTap;

  const _Card({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconWidget,
    required this.onTap,
  }) : assert(icon != null || iconWidget != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF8A79E5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: iconWidget ??
                    AppMaterialIcon(icon!, color: const Color(0xFF604EB8)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}
