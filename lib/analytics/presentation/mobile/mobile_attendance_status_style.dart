import 'package:flutter/material.dart';

/// Visual tokens for mobile attendance employee cards.
abstract final class MobileAttendanceStatusStyle {
  static MobileAttendanceStatus look({
    required String status,
    bool onLeave = false,
  }) {
    final normalized = status.toLowerCase().trim();

    if (onLeave || normalized.contains('leave')) {
      return const MobileAttendanceStatus(
        label: 'ON LEAVE',
        strip: Color(0xFFC9A84C),
        badgeBg: Color(0xFFFFF4D6),
        badgeFg: Color(0xFF8A6A12),
      );
    }
    if (normalized == 'absent') {
      return const MobileAttendanceStatus(
        label: 'ABSENT',
        strip: Color(0xFFE57373),
        badgeBg: Color(0xFFFFE8E8),
        badgeFg: Color(0xFFC62828),
      );
    }
    if (normalized == 'working') {
      return const MobileAttendanceStatus(
        label: 'WORKING',
        strip: Color(0xFF66BB6A),
        badgeBg: Color(0xFFE8F7E9),
        badgeFg: Color(0xFF2E7D32),
      );
    }
    if (normalized == 'logged_out' ||
        normalized == 'auto_logout' ||
        normalized.contains('logout') ||
        normalized.contains('done') ||
        normalized.contains('complete')) {
      return const MobileAttendanceStatus(
        label: 'DONE',
        strip: Color(0xFF5C8FD6),
        badgeBg: Color(0xFFE7F1FC),
        badgeFg: Color(0xFF2563EB),
      );
    }

    final label = status.isEmpty ? '—' : status.replaceAll('_', ' ').toUpperCase();
    return MobileAttendanceStatus(
      label: label,
      strip: const Color(0xFFB0BEC5),
      badgeBg: const Color(0xFFF1F5F9),
      badgeFg: const Color(0xFF64748B),
    );
  }

  static String initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}

class MobileAttendanceStatus {
  final String label;
  final Color strip;
  final Color badgeBg;
  final Color badgeFg;

  const MobileAttendanceStatus({
    required this.label,
    required this.strip,
    required this.badgeBg,
    required this.badgeFg,
  });
}
