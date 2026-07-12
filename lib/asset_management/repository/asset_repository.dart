import 'dart:typed_data';

import '../models/asset_models.dart';
import '../services/asset_api_service.dart';

class AssetRepository {
  AssetRepository({AssetApiService? api}) : _api = api ?? AssetApiService();

  final AssetApiService _api;

  Future<List<Asset>> listAssets({
    String? status,
    String? assetType,
    String? department,
  }) =>
      _api.listAssets(
        status: status,
        assetType: assetType,
        department: department,
      );

  Future<Asset> createAsset(CreateAssetPayload payload) =>
      _api.createAsset(payload);

  Future<Asset> getAsset(String assetCode) => _api.getAsset(assetCode);

  Future<Asset> updateAsset(String assetCode, Map<String, dynamic> body) =>
      _api.updateAsset(assetCode, body);

  /// Permanently delete an asset from inventory.
  Future<void> deleteAsset(
    String assetCode, {
    String? reason,
  }) =>
      _api.deleteAsset(assetCode, reason: reason);

  Future<Uint8List> downloadQrPng(
    String assetCode, {
    String size = 'small',
  }) =>
      _api.downloadQrPng(assetCode, size: size);

  Future<Uint8List> downloadLabelPdf(
    String assetCode, {
    String size = 'small',
  }) =>
      _api.downloadLabelPdf(assetCode, size: size);

  Future<Uint8List> printLabelSheet(List<String> assetCodes) =>
      _api.printLabelSheet(assetCodes);

  Future<Asset> scanAsset(String assetCode) => _api.scanAsset(assetCode);

  Future<void> requestAsset(
    String assetCode, {
    required String purpose,
    required String expectedReturnDate,
    String? notes,
  }) =>
      _api.requestAsset(
        assetCode,
        purpose: purpose,
        expectedReturnDate: expectedReturnDate,
        notes: notes,
      );

  Future<void> returnAsset(String assetCode) => _api.returnAsset(assetCode);

  Future<void> reportDamage(String assetCode, {required String description}) =>
      _api.reportDamage(assetCode, description: description);

  Future<List<AssetTimelineEvent>> getHistory(String assetCode) =>
      _api.getHistory(assetCode);

  Future<List<MyAssetAssignment>> myAssets() => _api.myAssets();

  Future<List<Asset>> search(String query) => _api.search(query);

  Future<List<AssetRequest>> pendingRequests() => _api.pendingRequests();

  Future<void> approveRequest(int id) => _api.approveRequest(id);

  Future<void> rejectRequest(int id, {String? comment}) =>
      _api.rejectRequest(id, comment: comment);

  Future<List<AssetReturnItem>> pendingReturns() => _api.pendingReturns();

  Future<void> verifyReturn(int id) => _api.verifyReturn(id);

  Future<void> rejectReturn(int id, {String? comment}) =>
      _api.rejectReturn(id, comment: comment);

  Future<List<AssetDamageReport>> pendingDamage() => _api.pendingDamage();

  Future<void> startRepair(int id) => _api.startRepair(id);

  Future<void> completeRepair(int id, {String? resolutionNotes}) =>
      _api.completeRepair(id, resolutionNotes: resolutionNotes);

  Future<List<AssetCalendarEvent>> calendar({
    required int year,
    required int month,
  }) =>
      _api.calendar(year: year, month: month);

  Future<AssetDashboardStats> dashboard() => _api.dashboard();

  Future<List<AssetDepartmentReportRow>> reportByDepartment() =>
      _api.reportByDepartment();

  Future<List<AssetEmployeeReportRow>> reportByEmployee() =>
      _api.reportByEmployee();

  Future<List<AssetGuestAccess>> listGuests() => _api.listGuests();

  Future<AssetGuestCredentials> createGuest(CreateAssetGuestPayload payload) =>
      _api.createGuest(payload);

  Future<void> revokeGuest(int userId) => _api.revokeGuest(userId);
}
