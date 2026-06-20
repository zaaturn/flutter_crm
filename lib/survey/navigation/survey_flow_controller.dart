import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/core/layout/adaptive_layout.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../bloc/survey_admin_bloc.dart';
import '../bloc/survey_admin_event.dart';
import '../bloc/survey_employee_bloc.dart';
import '../bloc/survey_employee_event.dart';
import '../repository/survey_repository.dart';
import '../presentation/screen/survey_list_screen.dart';
import '../presentation/mobile/screen/survey_list_screen_mobile.dart';
import '../presentation/mobile/screen/take_survey_screen_mobile.dart';
import '../presentation/screen/take_survey_screen.dart';

class SurveyFlowController {
  SurveyFlowController._();

  static const String moduleKey = 'surveys';

  static Future<bool> _sessionAllows() async {
    final raw = await SecureStorageService().readAuthSessionJson();
    final session = AuthSession.fromStorageString(raw);
    if (session == null) return false;
    if (session.isSuperuser) return true;
    if (!session.isAdmin) return false;
    return session.adminModules[moduleKey] == true;
  }

  static Future<bool> canAccess() => _sessionAllows();

  static Future<void> openWithPermissionCheck(BuildContext context) async {
    final allowed = await _sessionAllows();
    if (!context.mounted) return;
    if (!allowed) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Limited access'),
          content: const Text(
            'Your admin account does not include Surveys. '
            'Contact a superadmin if you need access.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }
    await openAdmin(context);
  }

  static Future<void> openAdmin(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => SurveyAdminBloc(
            repository: SurveyRepository(),
          )..add(const SurveyAdminStarted()),
          child: AdaptiveLayout(
            mobile: const SurveyListScreenMobile(),
            tablet: const SurveyListScreenMobile(),
            webDesktop: const SurveyListScreen(),
          ),
        ),
      ),
    );
  }

  static Future<void> openCreateSurvey(BuildContext context) async {
    final allowed = await _sessionAllows();
    if (!context.mounted) return;
    if (!allowed) {
      await openWithPermissionCheck(context);
      return;
    }
    await openAdmin(context);
  }

  static Future<bool?> openTakeSurvey(BuildContext context, int surveyId) async {
    return Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider(
          create: (_) => SurveyEmployeeBloc(repository: SurveyRepository())
            ..add(SurveyEmployeeLoadForm(surveyId)),
          child: AdaptiveLayout(
            mobile: TakeSurveyScreenMobile(surveyId: surveyId),
            tablet: TakeSurveyScreenMobile(surveyId: surveyId),
            webDesktop: TakeSurveyScreen(surveyId: surveyId),
          ),
        ),
      ),
    );
  }
}
