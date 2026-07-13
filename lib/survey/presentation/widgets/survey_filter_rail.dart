import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final items = <(SurveyStatus?, String, IconData)>[
      (null, 'All surveys', Icons.list_alt_outlined),
      (SurveyStatus.draft, 'Draft', Icons.edit_note_outlined),
      (SurveyStatus.active, 'Active', Icons.play_circle_outline),
      (SurveyStatus.closed, 'Closed', Icons.inventory_2_outlined),
    ];

    return SurveyAdminCompactRail(
      onBack: onBack,
      footer: onCreate == null
          ? null
          : SurveyAdminRailIcon(
              icon: Icons.add,
              tooltip: 'Create survey',
              selected: false,
              onTap: onCreate!,
            ),
      children: [
        for (final item in items)
          SurveyAdminRailIcon(
            icon: item.$3,
            tooltip: item.$2,
            selected: selected == item.$1,
            onTap: () => _onFilterTap(context, item.$1),
          ),
      ],
    );
  }
}
