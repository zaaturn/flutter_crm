import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:my_app/services/api_client.dart';

import '../models/asset_models.dart';

class AssetApiException implements Exception {
  AssetApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// HTTP layer for `/api/assets/` (Bearer via [ApiClient] interceptors).
class AssetApiService {
  AssetApiService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;
  static const _base = '/api/assets';

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw AssetApiException('Unexpected asset response shape');
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in const ['results', 'data', 'items', 'assets', 'rows']) {
        final nested = map[key];
        if (nested is List) return _asMapList(nested);
      }
    }
    return const [];
  }

  String _errorMessage(dynamic data, String fallback) {
    if (data is Map) {
      final detail = data['detail'] ?? data['error'] ?? data['message'];
      if (detail != null) {
        if (detail is List) return detail.map((e) => '$e').join(', ');
        return '$detail';
      }
      final parts = <String>[];
      data.forEach((key, value) {
        if (value is List) {
          parts.add('$key: ${value.map((e) => '$e').join(', ')}');
        } else if (value != null) {
          parts.add('$key: $value');
        }
      });
      if (parts.isNotEmpty) return parts.join('\n');
    } else if (data is String && data.trim().isNotEmpty) {
      final trimmed = data.trim();
      if (trimmed.length > 180) return fallback;
      return trimmed;
    } else if (data is List && data.isNotEmpty) {
      return data.map((e) => '$e').join(', ');
    }
    return fallback;
  }

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = _errorMessage(
        e.response?.data,
        e.message ?? 'Request failed',
      );
      throw AssetApiException(msg, statusCode: code);
    }
  }

  // ─── CRUD ───────────────────────────────────────────────────────────────

  Future<List<Asset>> listAssets({
    String? status,
    String? assetType,
    String? department,
  }) =>
      _guard(() async {
        final q = <String, dynamic>{};
        if (status != null && status.isNotEmpty) q['status'] = status;
        if (assetType != null && assetType.isNotEmpty) {
          q['asset_type'] = assetType;
        }
        if (department != null && department.isNotEmpty) {
          q['department'] = department;
        }
        final res = await _dio.get<dynamic>(
          '$_base/',
          queryParameters: q.isEmpty ? null : q,
        );
        return _asMapList(res.data).map(Asset.fromJson).toList();
      });

  Future<Asset> createAsset(CreateAssetPayload payload) => _guard(() async {
        final res = await _dio.post<dynamic>(
          '$_base/',
          data: payload.toJson(),
        );
        return Asset.fromJson(_asMap(res.data));
      });

  Future<Asset> getAsset(String assetCode) => _guard(() async {
        final res = await _dio.get<dynamic>('$_base/$assetCode/');
        return Asset.fromJson(_asMap(res.data));
      });

  Future<Asset> updateAsset(
    String assetCode,
    Map<String, dynamic> body,
  ) =>
      _guard(() async {
        final res = await _dio.patch<dynamic>(
          '$_base/$assetCode/',
          data: body,
        );
        return Asset.fromJson(_asMap(res.data));
      });

  /// Permanently delete an asset from inventory.
  Future<void> deleteAsset(
    String assetCode, {
    String? reason,
  }) =>
      _guard(() async {
        await _dio.delete<dynamic>(
          '$_base/$assetCode/',
          data: {
            if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
          },
        );
      });

  // ─── QR / labels ─────────────────────────────────────────────────────────

  Future<Uint8List> downloadQrPng(
    String assetCode, {
    bool forceDownload = true,
    /// tiny | small | standard — small fits cameras / compact gear stickers.
    String size = 'small',
  }) =>
      _guard(() async {
        final res = await _dio.get<List<int>>(
          '$_base/$assetCode/qr/',
          queryParameters: {
            'size': size,
            if (forceDownload) 'download': 1,
          },
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (code) => code != null && code >= 200 && code < 400,
          ),
        );
        final data = res.data;
        if (data == null || data.isEmpty) {
          throw AssetApiException('QR image was empty');
        }
        final bytes = Uint8List.fromList(data);
        if (bytes.isNotEmpty && (bytes[0] == 0x7B || bytes[0] == 0x5B)) {
          throw AssetApiException('QR endpoint returned JSON instead of an image');
        }
        return bytes;
      });

  Future<Uint8List> downloadLabelPdf(
    String assetCode, {
    /// small (equipment sticker) | standard (desk label)
    String size = 'small',
  }) =>
      _guard(() async {
        final res = await _dio.get<List<int>>(
          '$_base/$assetCode/label/',
          queryParameters: {'size': size},
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(res.data ?? const []);
      });

  Future<Uint8List> printLabelSheet(List<String> assetCodes) =>
      _guard(() async {
        final res = await _dio.post<List<int>>(
          '$_base/labels/print-sheet/',
          data: {'asset_codes': assetCodes},
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(res.data ?? const []);
      });

  // ─── Employee actions ────────────────────────────────────────────────────

  Future<Asset> scanAsset(String assetCode) => _guard(() async {
        final res = await _dio.get<dynamic>('$_base/scan/$assetCode/');
        return Asset.fromJson(_asMap(res.data));
      });

  Future<void> requestAsset(
    String assetCode, {
    required String purpose,
    required String expectedReturnDate,
    String? notes,
  }) =>
      _guard(() async {
        await _dio.post<dynamic>(
          '$_base/$assetCode/request/',
          data: {
            'purpose': purpose,
            'expected_return_date': expectedReturnDate,
            if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
          },
        );
      });

  Future<void> returnAsset(String assetCode) => _guard(() async {
        await _dio.post<dynamic>('$_base/$assetCode/return/');
      });

  Future<void> reportDamage(String assetCode, {required String description}) =>
      _guard(() async {
        await _dio.post<dynamic>(
          '$_base/$assetCode/report-damage/',
          data: {'description': description},
        );
      });

  Future<List<AssetTimelineEvent>> getHistory(String assetCode) =>
      _guard(() async {
        final res = await _dio.get<dynamic>('$_base/$assetCode/history/');
        return _asMapList(res.data).map(AssetTimelineEvent.fromJson).toList();
      });

  Future<List<MyAssetAssignment>> myAssets() => _guard(() async {
        final res = await _dio.get<dynamic>('$_base/my-assets/');
        return _asMapList(res.data).map(MyAssetAssignment.fromJson).toList();
      });

  Future<List<Asset>> search(String query) => _guard(() async {
        final res = await _dio.get<dynamic>(
          '$_base/search/',
          queryParameters: {'q': query},
        );
        return _asMapList(res.data).map(Asset.fromJson).toList();
      });

  // ─── Admin approvals ─────────────────────────────────────────────────────

  Future<List<AssetRequest>> pendingRequests() => _guard(() async {
        final res = await _dio.get<dynamic>('$_base/requests/pending/');
        return _asMapList(res.data).map(AssetRequest.fromJson).toList();
      });

  Future<void> approveRequest(int id) => _guard(() async {
        await _dio.post<dynamic>('$_base/requests/$id/approve/');
      });

  Future<void> rejectRequest(int id, {String? comment}) => _guard(() async {
        await _dio.post<dynamic>(
          '$_base/requests/$id/reject/',
          data: {
            if (comment != null && comment.trim().isNotEmpty)
              'comment': comment.trim(),
          },
        );
      });

  Future<List<AssetReturnItem>> pendingReturns() => _guard(() async {
        final res = await _dio.get<dynamic>('$_base/returns/pending/');
        return _asMapList(res.data).map(AssetReturnItem.fromJson).toList();
      });

  Future<void> verifyReturn(int id) => _guard(() async {
        await _dio.post<dynamic>('$_base/returns/$id/verify/');
      });

  Future<void> rejectReturn(int id, {String? comment}) => _guard(() async {
        await _dio.post<dynamic>(
          '$_base/returns/$id/reject/',
          data: {
            if (comment != null && comment.trim().isNotEmpty)
              'comment': comment.trim(),
          },
        );
      });

  Future<List<AssetDamageReport>> pendingDamage() => _guard(() async {
        final res = await _dio.get<dynamic>('$_base/damage/pending/');
        return _asMapList(res.data).map(AssetDamageReport.fromJson).toList();
      });

  Future<void> startRepair(int id) => _guard(() async {
        await _dio.post<dynamic>('$_base/damage/$id/start-repair/');
      });

  Future<void> completeRepair(int id, {String? resolutionNotes}) =>
      _guard(() async {
        await _dio.post<dynamic>(
          '$_base/damage/$id/complete-repair/',
          data: {
            if (resolutionNotes != null && resolutionNotes.trim().isNotEmpty)
              'resolution_notes': resolutionNotes.trim(),
          },
        );
      });

  // ─── Calendar / dashboard / reports ──────────────────────────────────────

  Future<List<AssetCalendarEvent>> calendar({
    required int year,
    required int month,
  }) =>
      _guard(() async {
        final res = await _dio.get<dynamic>(
          '$_base/calendar/',
          queryParameters: {'year': year, 'month': month},
        );
        return _asMapList(res.data).map(AssetCalendarEvent.fromJson).toList();
      });

  Future<AssetDashboardStats> dashboard() => _guard(() async {
        final res = await _dio.get<dynamic>('$_base/dashboard/');
        return AssetDashboardStats.fromJson(_asMap(res.data));
      });

  Future<List<AssetDepartmentReportRow>> reportByDepartment() =>
      _guard(() async {
        final res = await _dio.get<dynamic>('$_base/reports/by-department/');
        return _asMapList(res.data)
            .map(AssetDepartmentReportRow.fromJson)
            .toList();
      });

  Future<List<AssetEmployeeReportRow>> reportByEmployee() => _guard(() async {
        final res = await _dio.get<dynamic>('$_base/reports/by-employee/');
        return _asMapList(res.data)
            .map(AssetEmployeeReportRow.fromJson)
            .toList();
      });

  // ─── Guest access (admin) ────────────────────────────────────────────────

  Future<List<AssetGuestAccess>> listGuests() => _guard(() async {
        final res = await _dio.get<dynamic>('$_base/guests/');
        return _asMapList(res.data).map(AssetGuestAccess.fromJson).toList();
      });

  Future<AssetGuestCredentials> createGuest(CreateAssetGuestPayload payload) =>
      _guard(() async {
        final res = await _dio.post<dynamic>(
          '$_base/guests/',
          data: payload.toJson(),
        );
        return AssetGuestCredentials.fromJson(_asMap(res.data));
      });

  Future<void> revokeGuest(int userId) => _guard(() async {
        await _dio.post<dynamic>('$_base/guests/$userId/revoke/');
      });
}
