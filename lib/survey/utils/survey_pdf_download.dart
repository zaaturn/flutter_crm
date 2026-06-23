import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import 'package:my_app/billing/utils/pdf_saver.dart';
import 'package:my_app/services/api_client.dart';

import '../repository/survey_repository.dart';
import '../services/survey_api_service.dart';

class SurveyPdfDownload {
  SurveyPdfDownload._();

  static String _safeFilename(String raw) =>
      raw.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').replaceAll(RegExp(r'\s+'), '-');

  static Future<void> downloadFullReport(
    BuildContext context, {
    required int surveyId,
    SurveyRepository? repository,
  }) {
    return _download(
      context,
      filename: 'survey-$surveyId-full-report.pdf',
      fetch: () => (repository ?? SurveyRepository()).downloadFullReportPdf(surveyId),
    );
  }

  static Future<void> downloadIndividualReport(
    BuildContext context, {
    required int surveyId,
    required int responseId,
    required String employeeName,
    SurveyRepository? repository,
  }) {
    final name = _safeFilename(employeeName);
    if (name.isEmpty) {
      return _download(
        context,
        filename: 'survey-$surveyId-response-$responseId.pdf',
        fetch: () => (repository ?? SurveyRepository())
            .downloadIndividualReportPdf(surveyId, responseId),
      );
    }
    return _download(
      context,
      filename: 'survey-$surveyId-$name.pdf',
      fetch: () => (repository ?? SurveyRepository())
          .downloadIndividualReportPdf(surveyId, responseId),
    );
  }

  static Future<void> _download(
    BuildContext context, {
    required String filename,
    required Future<Uint8List> Function() fetch,
  }) async {
    ApiClient.showLoader();
    try {
      final bytes = await fetch();
      final path = await savePdfBytes(bytes: bytes, filename: filename);
      if (!context.mounted) return;

      if (path != null) {
        final res = await OpenFilex.open(path);
        if (res.type != ResultType.done) {
          await Share.shareXFiles([XFile(path)], text: 'Survey report');
        }
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            path == null ? 'Report download started' : 'Report saved',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB91C1C),
          content: Text(SurveyApiService.messageFrom(e)),
        ),
      );
    } finally {
      ApiClient.hideLoader();
    }
  }
}
