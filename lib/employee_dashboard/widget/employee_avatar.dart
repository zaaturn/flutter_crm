import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/employee_profile.dart';
import 'device_specific/v2/employee_dashboard_v2_theme.dart';

/// Photo when available, otherwise initials (e.g. SU for Sumanth).
class EmployeeAvatar extends StatelessWidget {
  const EmployeeAvatar({
    super.key,
    this.photoUrl,
    required this.initials,
    this.size = 40,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
  });

  final String? photoUrl;
  final String initials;
  final double size;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BoxBorder? border;

  factory EmployeeAvatar.fromProfile(
    EmployeeProfile profile, {
    double size = 40,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
    BoxBorder? border,
  }) {
    return EmployeeAvatar(
      photoUrl: profile.profilePhoto,
      initials: profile.avatarInitials,
      size: size,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      border: border,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? EmployeeDashboardV2Theme.greenLight;
    final fg = foregroundColor ?? EmployeeDashboardV2Theme.greenDark;
    final radius = borderRadius ?? BorderRadius.circular(size / 2);
    final fontSize = (size * 0.34).clamp(10.0, 18.0);
    final url = photoUrl?.trim() ?? '';
    final label = initials.isNotEmpty ? initials : 'U';

    Widget initialsChild() => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: border,
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              color: fg,
            ),
          ),
        );

    if (url.isEmpty) return initialsChild();

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(border: border),
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => initialsChild(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return initialsChild();
          },
        ),
      ),
    );
  }
}
