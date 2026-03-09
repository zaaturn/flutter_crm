class AttendanceModel {
  final bool isCheckedIn;
  final bool onBreak;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final Duration? totalHours;

  AttendanceModel({
    required this.isCheckedIn,
    required this.onBreak,
    this.checkInTime,
    this.checkOutTime,
    this.totalHours,
  });

  /// ADD THIS METHOD
  AttendanceModel copyWith({
    bool? isCheckedIn,
    bool? onBreak,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    Duration? totalHours,
  }) {
    return AttendanceModel(
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      onBreak: onBreak ?? this.onBreak,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      totalHours: totalHours ?? this.totalHours,
    );
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> m) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v.toLocal();

      try {
        return DateTime.parse(v.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    Duration? parseDuration(dynamic v) {
      if (v == null) return null;

      // If backend sends minutes
      if (v is int) {
        return Duration(minutes: v);
      }

      // If backend sends decimal hours
      final d = double.tryParse(v.toString());
      if (d != null) {
        final hours = d.floor();
        final minutes = ((d - hours) * 60).round();
        return Duration(hours: hours, minutes: minutes);
      }

      return null;
    }

    return AttendanceModel(
      isCheckedIn: m['is_checked_in'] == true,
      onBreak: m['on_break'] == true,
      checkInTime: parseDate(m['check_in_time']),
      checkOutTime: parseDate(m['check_out_time']),
      totalHours: parseDuration(m['total_hours']),
    );
  }
}