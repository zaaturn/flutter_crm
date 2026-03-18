import 'package:my_app/leave_management/models/leave_request.dart';

class LeaveDashboardState {
  final bool isLoading;
  final String? error;

  // Stats for the summary cards
  final int pending;
  final int approved;
  final int rejected;

  // Data lists
  final List<LeaveRequest> allLeaves;
  final List<LeaveRequest> filteredLeaves;
  final String selectedFilter;

  // NEW: Tracking which specific ID is hitting the API (Approve/Reject/Delete)
  final int? processingId;

  // Feedback messages
  final String? successMessage;

  const LeaveDashboardState({
    this.isLoading = false,
    this.error,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.allLeaves = const [],
    this.filteredLeaves = const [],
    this.selectedFilter = "all",
    this.processingId, // Added
    this.successMessage,
  });

  LeaveDashboardState copyWith({
    bool? isLoading,
    String? error,
    int? pending,
    int? approved,
    int? rejected,
    List<LeaveRequest>? allLeaves,
    List<LeaveRequest>? filteredLeaves,
    String? selectedFilter,
    int? processingId, // Added
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearProcessingId = false, // Added helper
  }) {
    return LeaveDashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      pending: pending ?? this.pending,
      approved: approved ?? this.approved,
      rejected: rejected ?? this.rejected,
      allLeaves: allLeaves ?? this.allLeaves,
      filteredLeaves: filteredLeaves ?? this.filteredLeaves,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      processingId: clearProcessingId ? null : (processingId ?? this.processingId),
      successMessage:
      clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}