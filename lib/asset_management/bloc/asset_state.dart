import 'package:equatable/equatable.dart';

import '../models/asset_models.dart';
import 'asset_event.dart';

class AssetState extends Equatable {
  const AssetState({
    this.isAdmin = false,
    this.tab = AssetShellTab.myAssets,
    this.loading = false,
    this.actionLoading = false,
    this.error,
    this.successMessage,
    this.assets = const [],
    this.myAssets = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.typeFilter,
    this.pendingRequests = const [],
    this.pendingReturns = const [],
    this.pendingDamage = const [],
    this.calendarEvents = const [],
    this.calendarYear,
    this.calendarMonth,
    this.dashboard,
    this.byDepartment = const [],
    this.byEmployee = const [],
    this.selectedCodes = const {},
    this.lastCreatedAsset,
  });

  final bool isAdmin;
  final AssetShellTab tab;
  final bool loading;
  final bool actionLoading;
  final String? error;
  final String? successMessage;
  final List<Asset> assets;
  final List<MyAssetAssignment> myAssets;
  final List<Asset> searchResults;
  final String searchQuery;
  final String? statusFilter;
  final String? typeFilter;
  final List<AssetRequest> pendingRequests;
  final List<AssetReturnItem> pendingReturns;
  final List<AssetDamageReport> pendingDamage;
  final List<AssetCalendarEvent> calendarEvents;
  final int? calendarYear;
  final int? calendarMonth;
  final AssetDashboardStats? dashboard;
  final List<AssetDepartmentReportRow> byDepartment;
  final List<AssetEmployeeReportRow> byEmployee;
  final Set<String> selectedCodes;
  final Asset? lastCreatedAsset;

  AssetState copyWith({
    bool? isAdmin,
    AssetShellTab? tab,
    bool? loading,
    bool? actionLoading,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    List<Asset>? assets,
    List<MyAssetAssignment>? myAssets,
    List<Asset>? searchResults,
    String? searchQuery,
    String? statusFilter,
    bool clearStatusFilter = false,
    String? typeFilter,
    bool clearTypeFilter = false,
    List<AssetRequest>? pendingRequests,
    List<AssetReturnItem>? pendingReturns,
    List<AssetDamageReport>? pendingDamage,
    List<AssetCalendarEvent>? calendarEvents,
    int? calendarYear,
    int? calendarMonth,
    AssetDashboardStats? dashboard,
    List<AssetDepartmentReportRow>? byDepartment,
    List<AssetEmployeeReportRow>? byEmployee,
    Set<String>? selectedCodes,
    Asset? lastCreatedAsset,
    bool clearLastCreated = false,
  }) {
    return AssetState(
      isAdmin: isAdmin ?? this.isAdmin,
      tab: tab ?? this.tab,
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      assets: assets ?? this.assets,
      myAssets: myAssets ?? this.myAssets,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      pendingRequests: pendingRequests ?? this.pendingRequests,
      pendingReturns: pendingReturns ?? this.pendingReturns,
      pendingDamage: pendingDamage ?? this.pendingDamage,
      calendarEvents: calendarEvents ?? this.calendarEvents,
      calendarYear: calendarYear ?? this.calendarYear,
      calendarMonth: calendarMonth ?? this.calendarMonth,
      dashboard: dashboard ?? this.dashboard,
      byDepartment: byDepartment ?? this.byDepartment,
      byEmployee: byEmployee ?? this.byEmployee,
      selectedCodes: selectedCodes ?? this.selectedCodes,
      lastCreatedAsset: clearLastCreated
          ? null
          : (lastCreatedAsset ?? this.lastCreatedAsset),
    );
  }

  @override
  List<Object?> get props => [
        isAdmin,
        tab,
        loading,
        actionLoading,
        error,
        successMessage,
        assets,
        myAssets,
        searchResults,
        searchQuery,
        statusFilter,
        typeFilter,
        pendingRequests,
        pendingReturns,
        pendingDamage,
        calendarEvents,
        calendarYear,
        calendarMonth,
        dashboard,
        byDepartment,
        byEmployee,
        selectedCodes,
        lastCreatedAsset,
      ];
}
