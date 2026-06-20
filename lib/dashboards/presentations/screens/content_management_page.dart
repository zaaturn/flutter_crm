import 'package:flutter/material.dart';

import 'package:my_app/dashboards/widgets/app_color.dart';
import 'package:my_app/dashboards/widgets/content_sidebar.dart';
import 'package:my_app/dashboards/widgets/target_audience_panel.dart';
import 'package:my_app/dashboards/presentations/screens/culture_board_screen.dart';
import 'package:my_app/dashboards/presentations/screens/shared_item_screen.dart';
import 'package:my_app/dashboards/presentations/screens/announcement_screen.dart';
import 'package:my_app/survey/navigation/survey_flow_controller.dart';
import 'package:my_app/dashboards/presentations/widgets/share_survey_access_gate.dart';
import 'package:my_app/dashboards/presentations/screens/share_dashboard_screen.dart';



class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() =>
      _ContentManagementPageState();
}

class _ContentManagementPageState
    extends State<ContentManagementPage> {
  NavSection _active = NavSection.dashboard;

  bool get _showAudiencePanel =>
      _active == NavSection.sharedItems ||
          _active == NavSection.announcements ||
          _active == NavSection.cultureBoards;

  bool get _isCultureBoardsView => _active == NavSection.cultureBoards;

  String get _headerTitle => switch (_active) {
        NavSection.dashboard => 'Share Dashboard',
        NavSection.sharedItems => 'Shared Items',
        NavSection.cultureBoards => 'Culture Boards',
        NavSection.announcements => 'Announcements',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Stack(
        children: [
          // Background watermark (requires asset file)
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/images/share_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.60)),
          ),
          Row(
            children: [
              // Sidebar
              ContentSidebar(
                active: _active,
                onChanged: (s) => setState(() => _active = s),
                onBack: () => Navigator.of(context).pop(),
                isCultureBoardsView: _isCultureBoardsView,
              ),

              // Main area + header
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      alignment: Alignment.centerLeft,
                      color: Colors.white.withValues(alpha: 0.10),
                      child: Text(
                        _headerTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildBody(),
                    ),
                  ],
                ),
              ),

              // Right panel (filters / audience)
              if (_showAudiencePanel)
                TargetAudiencePanel(
                  panelSubtitle: _active == NavSection.announcements
                      ? 'Choose who should see this update'
                      : 'Choose who should see this item',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_active) {
      case NavSection.dashboard:
        return ShareSurveyAccessGate(
          builder: (allowed) => ShareDashboardScreen(
            onOpenShared: () => setState(() => _active = NavSection.sharedItems),
            onOpenCulture: () =>
                setState(() => _active = NavSection.cultureBoards),
            onOpenAnnouncements: () =>
                setState(() => _active = NavSection.announcements),
            onOpenSurveys: allowed
                ? () => SurveyFlowController.openCreateSurvey(context)
                : null,
          ),
        );
      case NavSection.sharedItems:
        return const SharedItemsScreen();
      case NavSection.announcements:
        return const AnnouncementsScreen();
      case NavSection.cultureBoards:
        return const CultureBoardsScreen();
    }
  }
}