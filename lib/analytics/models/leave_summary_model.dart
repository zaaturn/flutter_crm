class LeaveSummaryModel {
  final int year;
  final int month;
  final String? period;
  final int pending;
  final int approved;
  final int rejected;
  final int cancelled;
  final int onLeaveToday;

  const LeaveSummaryModel({
    required this.year,
    required this.month,
    this.period,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.cancelled = 0,
    this.onLeaveToday = 0,
  });

  factory LeaveSummaryModel.fromJson(
    Map<String, dynamic> json, {
    required int year,
    required int month,
  }) {
    final data = _unwrap(json);
    return LeaveSummaryModel(
      year: _int(data['year']) ?? year,
      month: _int(data['month']) ?? month,
      period: data['period']?.toString(),
      pending: _int(data['pending'] ?? data['pending_requests']) ?? 0,
      approved: _int(data['approved']) ?? 0,
      rejected: _int(data['rejected']) ?? 0,
      cancelled: _int(data['cancelled']) ?? 0,
      onLeaveToday: _int(data['on_leave_today']) ?? 0,
    );
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final nested = json['data'] ?? json['leave'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString());
  }
}
