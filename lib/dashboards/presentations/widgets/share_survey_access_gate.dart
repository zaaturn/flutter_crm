import 'package:flutter/material.dart';

import 'package:my_app/survey/navigation/survey_flow_controller.dart';

/// Shows [child] only when the admin has `admin_modules.surveys` (or is superuser).
class ShareSurveyAccessGate extends StatelessWidget {
  const ShareSurveyAccessGate({
    super.key,
    required this.builder,
  });

  final Widget Function(bool allowed) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SurveyFlowController.canAccess(),
      builder: (context, snap) => builder(snap.data == true),
    );
  }
}
