import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/services/api_client.dart';

import '../models/survey_models.dart';

class SurveyApiException implements Exception {
  final int? statusCode;
  final String message;

  const SurveyApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SurveyApiService {
  SurveyApiService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;
  static const _base = '/api/surveys';

  Future<List<SurveySummary>> listSurveys({SurveyStatus? status}) async {
    final q = <String, dynamic>{};
    if (status != null && status != SurveyStatus.unknown) {
      q['status'] = status.name;
    }
    final res = await _dio.get(_base, queryParameters: q.isEmpty ? null : q);
    return _parseList(res.data, SurveySummary.fromJson);
  }

  Future<SurveyDetail> createSurvey(Map<String, dynamic> body) async {
    final res = await _dio.post(_base, data: body);
    return SurveyDetail.fromJson(_asMap(res.data));
  }

  Future<SurveyDetail> getSurvey(int id) async {
    final res = await _dio.get('$_base/$id/');
    return SurveyDetail.fromJson(_asMap(res.data));
  }

  Future<SurveyDetail> updateSurvey(int id, Map<String, dynamic> body) async {
    final res = await _dio.patch('$_base/$id/', data: body);
    return SurveyDetail.fromJson(_asMap(res.data));
  }

  Future<void> deleteSurvey(int id) async {
    await _dio.delete('$_base/$id/');
  }

  Future<SurveyQuestion> addQuestion(int surveyId, Map<String, dynamic> body) async {
    final res = await _dio.post('$_base/$surveyId/questions/', data: body);
    return SurveyQuestion.fromJson(_asMap(res.data));
  }

  Future<SurveyQuestion> getQuestion(int surveyId, int questionId) async {
    final res = await _dio.get('$_base/$surveyId/questions/$questionId/');
    return SurveyQuestion.fromJson(_asMap(res.data));
  }

  Future<SurveyQuestion> updateQuestion(
    int surveyId,
    int questionId,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.patch('$_base/$surveyId/questions/$questionId/', data: body);
    return SurveyQuestion.fromJson(_asMap(res.data));
  }

  Future<void> deleteQuestion(int surveyId, int questionId) async {
    await _dio.delete('$_base/$surveyId/questions/$questionId/');
  }

  Future<SurveyDetail> launchSurvey(int id) async {
    final res = await _dio.post('$_base/$id/launch/');
    return SurveyDetail.fromJson(_asMap(res.data));
  }

  Future<SurveyDetail> closeSurvey(int id) async {
    final res = await _dio.post('$_base/$id/close/');
    return SurveyDetail.fromJson(_asMap(res.data));
  }

  Future<SurveyResults> getResults(int id) async {
    final res = await _dio.get('$_base/$id/results/');
    return SurveyResults.fromJson(_asMap(res.data), fallbackSurveyId: id);
  }

  Future<List<SurveyIndividualResponse>> getIndividualResponses(int id) async {
    final res = await _dio.get('$_base/$id/results/responses/');
    final map = _asMap(res.data);
    final rows = map['user_responses'];
    if (rows is List) {
      return rows
          .whereType<Map>()
          .map((e) => SurveyIndividualResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return _parseList(res.data, SurveyIndividualResponse.fromJson);
  }

  Future<Uint8List> downloadFullReportPdf(int surveyId) async {
    return _downloadPdfBytes('$_base/$surveyId/results/download/');
  }

  Future<Uint8List> downloadIndividualReportPdf(
    int surveyId,
    int responseId,
  ) async {
    return _downloadPdfBytes(
      '$_base/$surveyId/results/responses/$responseId/download/',
    );
  }

  Future<Uint8List> _downloadPdfBytes(String path) async {
    final res = await _dio.get<List<int>>(
      path,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': 'application/pdf'},
      ),
    );
    if (res.statusCode != 200) {
      throw SurveyApiException('Download failed', statusCode: res.statusCode);
    }
    final bytes = Uint8List.fromList(res.data ?? const <int>[]);
    if (!_looksLikePdf(bytes)) {
      throw const SurveyApiException('Download did not return a PDF file');
    }
    return bytes;
  }

  bool _looksLikePdf(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  Future<List<SurveySummary>> getActiveSurveys() async {
    final res = await _dio.get('$_base/active/');
    return _parseActiveSurveys(res.data);
  }

  List<SurveySummary> _parseActiveSurveys(dynamic data) {
    if (data is Map &&
        (data.containsKey('id') ||
            data.containsKey('survey_id') ||
            data.containsKey('survey'))) {
      final single = SurveySummary.fromActiveFeedJson(
        Map<String, dynamic>.from(data),
      );
      if (single.id > 0) return [single];
    }

    final rows = _extractJsonList(data);
    final surveys = rows
        .map(SurveySummary.fromActiveFeedJson)
        .where((s) => s.id > 0)
        .toList();

    // De-dupe by id while preserving order.
    final seen = <int>{};
    return surveys.where((s) => seen.add(s.id)).toList();
  }

  List<Map<String, dynamic>> _extractJsonList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      for (final key in const [
        'results',
        'surveys',
        'data',
        'responses',
        'items',
        'pending',
        'pending_surveys',
        'active',
        'active_surveys',
      ]) {
        final v = data[key];
        if (v is List) {
          return v
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return [];
  }

  Future<SurveyDetail> getSurveyForm(int id) async {
    final res = await _dio.get('$_base/$id/form/');
    return SurveyDetail.fromJson(_asMap(res.data));
  }

  Future<void> submitSurvey(int id, List<SurveyAnswerPayload> answers) async {
    await _dio.post(
      '$_base/$id/submit/',
      data: {
        'answers': answers.map((a) => a.toJson()).toList(),
      },
    );
  }

  Future<SurveyMyResponse> getMyResponse(int id) async {
    final res = await _dio.get('$_base/$id/my-response/');
    return SurveyMyResponse.fromJson(_asMap(res.data));
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map) {
      final results = data['results'];
      if (results is List) {
        return results
            .whereType<Map>()
            .map((e) => fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return [];
  }

  static String messageFrom(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final payload = error.error ?? error.response?.data;
      if (AuthSessionRedirect.isAuthFailure(payload, statusCode: statusCode)) {
        return AuthSessionRedirect.defaultMessage;
      }

      final data = error.response?.data;
      if (data is Map) {
        final detail = data['detail'] ?? data['message'] ?? data['error'];
        if (detail != null) return detail.toString();
        final nonField = data['non_field_errors'];
        if (nonField is List && nonField.isNotEmpty) {
          return nonField.first.toString();
        }
      }
      if (data is String && data.isNotEmpty) {
        if (AuthSessionRedirect.isAuthFailure(data, statusCode: statusCode)) {
          return AuthSessionRedirect.defaultMessage;
        }
        return data;
      }
      final inline = error.error?.toString();
      if (inline != null &&
          AuthSessionRedirect.isAuthFailure(inline, statusCode: statusCode)) {
        return AuthSessionRedirect.defaultMessage;
      }
      return error.message ?? 'Request failed';
    }
    if (AuthSessionRedirect.isAuthFailure(error)) {
      return AuthSessionRedirect.defaultMessage;
    }
    return error.toString();
  }
}
