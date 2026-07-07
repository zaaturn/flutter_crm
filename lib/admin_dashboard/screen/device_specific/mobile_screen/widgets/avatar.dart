import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/employee_dashboard/model/employee_profile.dart';
import 'package:my_app/employee_dashboard/widget/employee_avatar.dart';

class Avatar extends StatelessWidget {
  final Employee employee;
  final double radius;

  const Avatar({
    super.key,
    required this.employee,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return EmployeeAvatar(
      photoUrl: resolveProfilePhotoUrl(employee.profilePhoto),
      initials: employee.initials,
      size: size,
      backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
      foregroundColor: const Color(0xFF3B82F6),
    );
  }
}
