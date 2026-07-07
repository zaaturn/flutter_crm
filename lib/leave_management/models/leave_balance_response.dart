class LeaveBalanceItem {
  final int leaveTypeId;
  final String code;
  final String name;
  final bool isPaid;
  final bool allowHalfDay;
  final double allocated;
  final double used;
  final double remaining;

  const LeaveBalanceItem({
    required this.leaveTypeId,
    required this.code,
    required this.name,
    required this.isPaid,
    required this.allowHalfDay,
    required this.allocated,
    required this.used,
    required this.remaining,
  });

  double get usageFraction =>
      allocated <= 0 ? 0 : (used / allocated).clamp(0.0, 1.0);

  String get remainingLabel => _formatDays(remaining);

  String get allocatedLabel => _formatDays(allocated);

  String get usedLabel => _formatDays(used);

  static String _formatDays(double days) {
    if (days == days.roundToDouble()) return '${days.toInt()}';
    return days.toStringAsFixed(1);
  }

  factory LeaveBalanceItem.fromJson(Map<String, dynamic> j) => LeaveBalanceItem(
        leaveTypeId: (j['leave_type_id'] as num).toInt(),
        code: j['code']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        isPaid: j['is_paid'] as bool? ?? true,
        allowHalfDay: j['allow_half_day'] as bool? ?? false,
        allocated: double.tryParse(j['allocated'].toString()) ?? 0,
        used: double.tryParse(j['used'].toString()) ?? 0,
        remaining: double.tryParse(j['remaining'].toString()) ?? 0,
      );
}

class LeaveBalanceResponse {
  final int year;
  final String? gender;
  final List<LeaveBalanceItem> balances;

  const LeaveBalanceResponse({
    required this.year,
    required this.gender,
    required this.balances,
  });

  bool get hasGender =>
      gender != null && gender!.trim().isNotEmpty;

  factory LeaveBalanceResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['balances'];
    final list = raw is List
        ? raw
            .map((e) => LeaveBalanceItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList()
        : <LeaveBalanceItem>[];

    final g = json['gender'];
    return LeaveBalanceResponse(
      year: json['year'] as int? ?? DateTime.now().year,
      gender: g == null ? null : g.toString(),
      balances: list,
    );
  }
}
