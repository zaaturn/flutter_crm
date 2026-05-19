class LeaveDashboardModel {
  final int pending;
  final int approved;
  final int rejected;

  LeaveDashboardModel({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory LeaveDashboardModel.fromJson(Map<String, dynamic> json) {
    return LeaveDashboardModel(
      pending: _toInt(json['pending']),
      approved: _toInt(json['approved']),
      rejected: _toInt(json['rejected']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }
}

class ApiMessageModel {
  final String message;

  ApiMessageModel({required this.message});

  factory ApiMessageModel.fromJson(Map<String, dynamic> json) {
    return ApiMessageModel(
      message: json['detail'] ?? '',
    );
  }
}