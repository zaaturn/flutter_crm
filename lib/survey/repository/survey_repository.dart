import '../models/survey_models.dart';
import '../services/survey_api_service.dart';

class SurveyRepository {
  SurveyRepository({SurveyApiService? api})
      : _api = api ?? SurveyApiService();

  final SurveyApiService _api;

  Future<List<SurveySummary>> listSurveys({SurveyStatus? status}) =>
      _api.listSurveys(status: status);

  Future<SurveyDetail> createSurvey(Map<String, dynamic> body) =>
      _api.createSurvey(body);

  Future<SurveyDetail> getSurvey(int id) => _api.getSurvey(id);

  Future<SurveyDetail> updateSurvey(int id, Map<String, dynamic> body) =>
      _api.updateSurvey(id, body);

  Future<void> deleteSurvey(int id) => _api.deleteSurvey(id);

  Future<SurveyQuestion> addQuestion(int surveyId, Map<String, dynamic> body) =>
      _api.addQuestion(surveyId, body);

  Future<SurveyQuestion> getQuestion(int surveyId, int questionId) =>
      _api.getQuestion(surveyId, questionId);

  Future<SurveyQuestion> updateQuestion(
    int surveyId,
    int questionId,
    Map<String, dynamic> body,
  ) =>
      _api.updateQuestion(surveyId, questionId, body);

  Future<void> deleteQuestion(int surveyId, int questionId) =>
      _api.deleteQuestion(surveyId, questionId);

  Future<SurveyDetail> launchSurvey(int id) => _api.launchSurvey(id);

  Future<SurveyDetail> closeSurvey(int id) => _api.closeSurvey(id);

  Future<SurveyResults> getResults(int id) => _api.getResults(id);

  Future<List<SurveyIndividualResponse>> getIndividualResponses(int id) =>
      _api.getIndividualResponses(id);

  Future<List<SurveySummary>> getActiveSurveys() => _api.getActiveSurveys();

  Future<SurveyDetail> getSurveyForm(int id) => _api.getSurveyForm(id);

  Future<void> submitSurvey(int id, List<SurveyAnswerPayload> answers) =>
      _api.submitSurvey(id, answers);

  Future<SurveyMyResponse> getMyResponse(int id) => _api.getMyResponse(id);
}
