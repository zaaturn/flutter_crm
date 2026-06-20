import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../models/survey_models.dart';

/// Deletes a **draft** or **closed** survey. Active surveys cannot be deleted.
Future<bool> confirmDeleteSurvey(
  BuildContext context, {
  required SurveySummary survey,
  bool popOnSuccess = false,
}) async {
  if (!survey.canDelete) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          survey.status == SurveyStatus.active
              ? 'Active surveys cannot be deleted. Close the survey first, '
                  'then delete it from the Closed tab.'
              : 'Only draft or closed surveys can be deleted.',
        ),
      ),
    );
    return false;
  }

  final label = survey.status == SurveyStatus.draft ? 'draft' : 'closed';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Delete $label survey?'),
      content: Text(
        '"${survey.title}" will be permanently deleted. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  final bloc = context.read<SurveyAdminBloc>();
  bloc.add(SurveyAdminDeleteRequested(survey.id, survey: survey));
  await bloc.stream.firstWhere((s) => !s.actionInProgress);
  if (!context.mounted) return false;

  if (bloc.state.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(bloc.state.error!)),
    );
    return false;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Survey deleted')),
  );
  if (popOnSuccess) {
    Navigator.of(context).pop();
  }
  return true;
}
