import 'package:intl/intl.dart';

class PayrollRecordModel {
  const PayrollRecordModel({
    required this.id,
    this.employeeId,
    this.crmUserId,
    this.mergeEmail,
    required this.employeeName,
    required this.jobTitle,
    required this.monthYearLabel,
    this.paid,
    required this.amountDisplay,
    required this.amountRaw,
    required this.updatedDateLabel,
    required this.avatarInitials,
  });

  final int id;
  /// Employee profile / FK id when API exposes it (for merging rows).
  final int? employeeId;
  /// CRM / auth user id when distinct from [employeeId] (e.g. Employee vs User pk).
  final int? crmUserId;
  /// Lowercased email for merge when ids differ (admins / staff).
  final String? mergeEmail;
  final String employeeName;
  final String jobTitle;
  final String monthYearLabel;
  /// `null` = not set (Select); `false` = pending; `true` = paid.
  final bool? paid;
  final String amountDisplay;
  /// Unformatted numeric string for inline editors (e.g. `8420` or `8420.50`).
  final String amountRaw;
  final String updatedDateLabel;
  final String avatarInitials;

  factory PayrollRecordModel.fromJson(Map<String, dynamic> json) {
    final id = _parseId(json['id']);
    int? employeeId = _parseIdNullable(json['employee_id']);
    String name = '';
    String title = '';

    int? crmUserId = _parseIdNullable(json['user_id']);
    String? mergeEmail;

    final userNode = json['user'];
    if (userNode is int) {
      crmUserId ??= userNode;
    } else if (userNode is num) {
      crmUserId ??= userNode.toInt();
    } else if (userNode is Map) {
      final um = userNode;
      crmUserId ??= _parseIdNullable(um['id'] ?? um['pk']);
      mergeEmail ??= _normEmail(um['email']);
    }

    employeeId ??= crmUserId;
    final emp = json['employee'];
    if (emp is int) {
      employeeId ??= emp;
    } else if (emp is num) {
      employeeId ??= emp.toInt();
    } else if (emp is String) {
      employeeId ??= _parseIdNullable(emp);
    } else if (emp is Map) {
      crmUserId ??= _parseIdNullable(emp['user_id']);
      final rawUser = emp['user'];
      if (rawUser is int) {
        crmUserId ??= rawUser;
      } else if (rawUser is num) {
        crmUserId ??= rawUser.toInt();
      } else if (rawUser is Map) {
        final um = rawUser;
        crmUserId ??= _parseIdNullable(um['id'] ?? um['pk']);
        mergeEmail ??= _normEmail(um['email']);
      }
      employeeId ??= _parseIdNullable(emp['id'] ?? emp['pk'] ?? emp['user']);
      if (emp['user'] is Map) {
        employeeId ??= _parseIdNullable((emp['user'] as Map)['id']);
      }
      employeeId ??= _parseIdNullable(emp['user_id']);
      mergeEmail ??= _normEmail(emp['email']);
      final fn = emp['first_name']?.toString().trim() ?? '';
      final ln = emp['last_name']?.toString().trim() ?? '';
      name = '$fn $ln'.trim();
      if (name.isEmpty) {
        name = emp['name']?.toString().trim() ??
            emp['full_name']?.toString().trim() ??
            '';
      }
      title = emp['job_title']?.toString() ??
          emp['title']?.toString() ??
          emp['position']?.toString() ??
          '';
    } else {
      name = json['employee_name']?.toString().trim() ?? '';
      title = json['job_title']?.toString() ?? '';
    }

    mergeEmail ??= _normEmail(json['email']);

    final month = json['month'] is int
        ? json['month'] as int
        : int.tryParse(json['month']?.toString() ?? '');
    final year = json['year'] is int
        ? json['year'] as int
        : int.tryParse(json['year']?.toString() ?? '');
    String monthYear = '';
    if (month != null && year != null && month >= 1 && month <= 12) {
      monthYear =
          '${DateFormat('MMMM', 'en_US').format(DateTime(year, month))}, $year';
    } else {
      monthYear = json['month_year']?.toString() ??
          json['period']?.toString() ??
          '';
    }

    bool? paid;
    if (json.containsKey('paid')) {
      paid = _parsePaid(json['paid']);
    } else {
      final s = json['status']?.toString().toLowerCase();
      if (s == 'paid') {
        paid = true;
      } else if (s == 'pending') {
        paid = false;
      } else {
        paid = null;
      }
    }

    final amount = json['amount'];
    final amountDisplay = _formatAmount(amount);
    final amountRaw = _rawAmount(amount);

    DateTime? updated;
    final u = json['updated_at'] ?? json['updated'];
    if (u is String) {
      updated = DateTime.tryParse(u);
    }

    final updatedLabel = updated != null
        ? DateFormat('MMM d, y').format(updated.toLocal())
        : (json['updated_display']?.toString() ?? '');

    return PayrollRecordModel(
      id: id,
      employeeId: employeeId,
      crmUserId: crmUserId,
      mergeEmail: mergeEmail,
      employeeName: name.isEmpty ? '—' : name,
      jobTitle: title,
      monthYearLabel: monthYear.isEmpty ? '—' : monthYear,
      paid: paid,
      amountDisplay: amountDisplay,
      amountRaw: amountRaw,
      updatedDateLabel: updatedLabel,
      avatarInitials: _initials(name),
    );
  }

  static int _parseId(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static bool? _parsePaid(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }

  static int? _parseIdNullable(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String? _normEmail(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim().toLowerCase();
    if (s.isEmpty) return null;
    return s;
  }

  static String _rawAmount(dynamic amount) {
    if (amount == null) return '';
    if (amount is num) {
      if (amount is int) return amount.toString();
      final d = amount.toDouble();
      if (d == d.roundToDouble()) return d.toInt().toString();
      return d.toString();
    }
    if (amount is String) {
      return amount
          .replaceAll(r'$', '')
          .replaceAll(',', '')
          .trim();
    }
    return '';
  }

  static String _formatAmount(dynamic amount) {
    if (amount == null) return r'$0.00';
    if (amount is String) {
      if (amount.contains(r'$')) return amount;
      final n = double.tryParse(amount);
      if (n != null) {
        return NumberFormat.currency(symbol: r'$', decimalDigits: 2)
            .format(n);
      }
      return amount;
    }
    if (amount is num) {
      return NumberFormat.currency(symbol: r'$', decimalDigits: 2)
          .format(amount.toDouble());
    }
    return amount.toString();
  }

  static String _initials(String name) {
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2
          ? s.substring(0, 2).toUpperCase()
          : s.toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
