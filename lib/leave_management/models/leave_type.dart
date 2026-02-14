class LeaveType {
  final int id;
  final String code;
  final String name;
  final bool allowHalfDay;
  final bool isPaid;

  LeaveType({
    required this.id,
    required this.code,
    required this.name,
    required this.allowHalfDay,
    required this.isPaid,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      allowHalfDay: json['allow_half_day'] ?? false,
      isPaid: json['is_paid'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LeaveType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
