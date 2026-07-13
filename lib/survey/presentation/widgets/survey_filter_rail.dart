import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/core/widgets/survey_icons.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../models/survey_models.dart';
import 'survey_admin_shell.dart';

/// Status filter icons for survey admin list + detail screens.
class SurveyFilterRail extends StatelessWidget {
  const SurveyFilterRail({
    super.key,
    required this.selected,
    this.onBack,
    this.onCreate,
    this.popOnFilterChange = false,
  });

  final SurveyStatus? selected;
  final VoidCallback? onBack;
  final VoidCallback? onCreate;
  final bool popOnFilterChange;

  void _onFilterTap(BuildContext context, SurveyStatus? status) {
    context.read<SurveyAdminBloc>().add(SurveyAdminStatusFilterChanged(status));
    if (popOnFilterChange && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <(SurveyStatus?, String, SurveyIconType)>[
      (null, 'All surveys', SurveyIconType.list),
      (SurveyStatus.draft, 'Draft', SurveyIconType.draft),
      (SurveyStatus.active, 'Active', SurveyIconType.active),
      (SurveyStatus.closed, 'Closed', SurveyIconType.closed),
    ];

    return SurveyAdminCompactRail(
      onBack: onBack,
      footer: onCreate == null
          ? null
          : SurveyAdminRailIcon(
              tooltip: 'Create survey',
              selected: false,
              onTap: onCreate!,
              child: const SurveyIcon(
                type: SurveyIconType.add,
                size: 22,
                color: AdminDashboardTheme.iconInactive,
              ),
            ),
      children: [
        for (final item in items)
          SurveyAdminRailIcon(
            tooltip: item.$2,
            selected: selected == item.$1,
            onTap: () => _onFilterTap(context, item.$1),
            child: SurveyIcon(
              type: item.$3,
              size: 22,
              color: selected == item.$1
                  ? AdminDashboardTheme.textDark
                  : AdminDashboardTheme.iconInactive,
            ),
          ),
      ],
    );
  }
}
