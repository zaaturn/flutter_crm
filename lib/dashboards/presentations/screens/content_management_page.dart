import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/user_repository.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/widgets/app_color.dart';
import 'package:my_app/dashboards/widgets/content_sidebar.dart';
import 'package:my_app/dashboards/widgets/target_audience_panel.dart';
import 'package:my_app/dashboards/presentations/screens/culture_board_screen.dart';
import 'package:my_app/dashboards/presentations/screens/shared_item_screen.dart';
import 'package:my_app/dashboards/presentations/screens/announcement_screen.dart';


class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() =>
      _ContentManagementPageState();
}

class _ContentManagementPageState
    extends State<ContentManagementPage> {
  NavSection _active = NavSection.cultureBoards;

  bool get _showAudiencePanel =>
      _active == NavSection.sharedItems ||
          _active == NavSection.announcements;

  bool get _isCultureBoardsView =>
      _active == NavSection.cultureBoards;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AudienceBloc(
        userRepository: ctx.read<UserRepository>(),
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBg,
        body: Row(
          children: [
            // ── Sidebar ──────────────────────────────────────
            ContentSidebar(
              active: _active,
              onChanged: (s) => setState(() => _active = s),
              onBack: () =>
                  setState(() => _active = NavSection.cultureBoards),
              isCultureBoardsView: _isCultureBoardsView,
            ),

            // ── Main content ──────────────────────────────────
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: _buildBody(),
              ),
            ),

            // ── Right panel (conditional) ─────────────────────
            if (_showAudiencePanel)
              TargetAudiencePanel(
                panelSubtitle: _active == NavSection.announcements
                    ? 'Choose who should see this update'
                    : 'Choose who should see this item',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_active) {
      case NavSection.sharedItems:
        return const SharedItemsScreen();
      case NavSection.announcements:
        return const AnnouncementsScreen();
      case NavSection.cultureBoards:
        return const CultureBoardsScreen();
    }
  }
}