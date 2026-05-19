import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

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
    final bool hasImage = employee.profilePhoto != null && employee.profilePhoto!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.withOpacity(0.1),
      backgroundImage: hasImage ? NetworkImage(employee.profilePhoto!) : null,
      child: !hasImage
          ? Text(
              employee.initials,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
