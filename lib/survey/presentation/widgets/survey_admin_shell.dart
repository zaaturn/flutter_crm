import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/core/widgets/survey_icons.dart';
import 'package:my_app/survey/theme/survey_theme.dart';

/// Mint admin canvas + compact icon rail + white content panel.
class SurveyAdminShell extends StatelessWidget {
  const SurveyAdminShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.rail,
    this.actions,
    this.onBack,
    this.showBackInHeader = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? rail;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBackInHeader;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SurveyTheme.shell,
      body: Padding(
        padding: const EdgeInsets.all(AdminDashboardTheme.shellPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            rail ?? SurveyAdminCompactRail(onBack: onBack),
            const SizedBox(width: AdminDashboardTheme.panelGap),
            Expanded(
              child: AdminDashboardPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SurveyAdminHeader(
                      title: title,
                      subtitle: subtitle,
                      actions: actions,
                      onBack: showBackInHeader ? onBack : null,
                    ),
                    const Divider(height: 1, color: AdminDashboardTheme.border),
                    Expanded(child: body),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SurveyAdminCompactRail extends StatelessWidget {
  const SurveyAdminCompactRail({
    super.key,
    this.onBack,
    this.children = const [],
    this.footer,
  });

  final VoidCallback? onBack;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AdminDashboardTheme.railWidth,
      child: Column(
        children: [
          _logoMark(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AdminDashboardTheme.iconRailBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  if (onBack != null)
                    SurveyAdminRailIcon(
                      tooltip: 'Back',
                      onTap: onBack!,
                      child: const SurveyIcon(
                        type: SurveyIconType.arrowBack,
                        size: 22,
                        color: AdminDashboardTheme.iconInactive,
                      ),
                    ),
                  ...children,
                  if (footer != null) ...[
                    const SizedBox(height: 8),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoMark() {
    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: ColoredBox(
          color: AdminDashboardTheme.tealLight,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SurveyIcon(
              type: SurveyIconType.poll,
              color: AdminDashboardTheme.teal,
            ),
          ),
        ),
      ),
    );
  }
}

class SurveyAdminRailIcon extends StatelessWidget {
  const SurveyAdminRailIcon({
    super.key,
    required this.tooltip,
    required this.onTap,
    required this.child,
    this.selected = false,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AdminDashboardTheme.accentYellow
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _SurveyAdminHeader extends StatelessWidget {
  const _SurveyAdminHeader({
    required this.title,
    this.subtitle,
    this.actions,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: const SurveyIcon(
                type: SurveyIconType.arrowBack,
                size: 22,
                color: AdminDashboardTheme.textDark,
              ),
              color: AdminDashboardTheme.textDark,
              tooltip: 'Back',
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: SurveyTheme.textMain,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SurveyTheme.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
