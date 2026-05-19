import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'avatar.dart';

class SaasEmployeeTile extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;

  const SaasEmployeeTile({
    super.key,
    required this.employee,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color terracotta = Color(0xFFB35A38);
    const Color darkSlate = Color(0xFF0F172A);
    // Slightly darker version of the cream background for more depth
    const Color midCream = Color(0xFFEBDDCF);

    final String displayName = employee.fullName.isNotEmpty
        ? employee.fullName
        : (employee.name.isNotEmpty ? employee.name : "Employee #${employee.id}");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: midCream,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: terracotta.withOpacity(0.1),
          highlightColor: terracotta.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: darkSlate.withOpacity(0.15), width: 1.5),
            ),
            child: Row(
              children: [
                Avatar(employee: employee, radius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: darkSlate,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        employee.designation?.toUpperCase() ?? 'STAFF',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: terracotta,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: terracotta.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}