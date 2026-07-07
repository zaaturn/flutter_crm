import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/employee_dashboard/model/employee_profile.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';

String profileDisplayValue(String? value) {
  final v = value?.trim();
  if (v == null || v.isEmpty) return '—';
  return v;
}

Future<String?> pickProfileDate(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: initial ?? DateTime(1995, 6, 15),
    firstDate: firstDate ?? DateTime(1950),
    lastDate: lastDate ?? DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: EmployeeDashboardV2Theme.green,
            onPrimary: Colors.white,
            onSurface: EmployeeDashboardV2Theme.textDark,
          ),
        ),
        child: child!,
      );
    },
  );
  if (picked == null) return null;
  return DateFormat('yyyy-MM-dd').format(picked);
}

DateTime? parseProfileDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  return DateTime.tryParse(raw.trim());
}

class ProfileReadOnlyTile extends StatelessWidget {
  const ProfileReadOnlyTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: EmployeeDashboardV2Theme.cardMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: EmployeeDashboardV2Theme.cardBorder),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: EmployeeDashboardV2Theme.textMuted),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: EmployeeDashboardV2Theme.textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: EmployeeDashboardV2Theme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: EmployeeDashboardV2Theme.textDark,
            ),
            decoration: InputDecoration(
              suffixIcon: suffix,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: EmployeeDashboardV2Theme.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: EmployeeDashboardV2Theme.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: EmployeeDashboardV2Theme.green,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> buildProfilePatchBody({
  required EmployeeProfile original,
  required String firstName,
  required String lastName,
  required String phone,
  required String address,
}) {
  final body = <String, dynamic>{};
  void put(String key, dynamic value, dynamic originalValue) {
    final v = value?.toString().trim() ?? '';
    final o = originalValue?.toString().trim() ?? '';
    if (v != o) body[key] = v.isEmpty ? null : v;
  }

  put('first_name', firstName, original.firstName);
  put('last_name', lastName, original.lastName);
  put('phone_number', phone, original.phoneNumber);
  put('address', address, original.address);
  return body;
}

void syncProfileControllers(
  EmployeeProfile profile, {
  required TextEditingController firstName,
  required TextEditingController lastName,
  required TextEditingController phone,
  required TextEditingController address,
}) {
  firstName.text = profile.firstName?.trim() ?? '';
  lastName.text = profile.lastName?.trim() ?? '';
  phone.text = profile.phoneNumber?.trim() ?? '';
  address.text = profile.address?.trim() ?? '';
}
