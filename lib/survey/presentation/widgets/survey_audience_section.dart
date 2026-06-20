import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/screens/mobile_screen/widget/mobile_audience_picker_sheet.dart';
import 'package:my_app/dashboards/widgets/target_audience_panel.dart';

import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';

class SurveyAudienceSection extends StatelessWidget {
  const SurveyAudienceSection({
    super.key,
    required this.allUsers,
    required this.departmentIds,
    required this.designationIds,
    required this.userIds,
    required this.enabled,
    required this.onChanged,
    this.mobile = false,
    this.showAllUsersToggle = true,
  });

  final bool allUsers;
  final List<int> departmentIds;
  final List<int> designationIds;
  final List<int> userIds;
  final bool enabled;
  final bool mobile;
  final bool showAllUsersToggle;
  final void Function(bool allUsers, List<int> dept, List<int> desig, List<int> users)
      onChanged;

  @override
  Widget build(BuildContext context) {
    if (!mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAllUsersToggle)
            SwitchListTile(
              value: allUsers,
              onChanged: enabled ? (v) => onChanged(v, [], [], []) : null,
              title: const Text('All employees'),
              activeThumbColor: SurveyTheme.purple,
            ),
          if (!allUsers)
            TargetAudiencePanel(
              panelSubtitle: 'Choose who should receive this survey',
              expandWidth: true,
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: allUsers,
          onChanged: enabled
              ? (v) {
                  if (v) {
                    onChanged(true, [], [], []);
                  } else {
                    onChanged(false, departmentIds, designationIds, userIds);
                  }
                }
              : null,
          title: const Text('All employees'),
          activeThumbColor: SurveyMobileTheme.primary,
        ),
        if (!allUsers && enabled) const MobileAudiencePickers(),
      ],
    );
  }
}
