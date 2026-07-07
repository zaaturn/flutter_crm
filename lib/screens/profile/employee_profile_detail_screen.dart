import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/employee_dashboard/model/employee_profile.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/employee_dashboard/widget/employee_avatar.dart';
import 'package:my_app/screens/profile/profile_form_widgets.dart';
import 'package:my_app/services/api_services.dart';

/// Read-only colleague profile — `GET /profile/<user_id>/`.
class EmployeeProfileDetailScreen extends StatefulWidget {
  const EmployeeProfileDetailScreen({
    super.key,
    required this.userId,
    this.title,
  });

  final int userId;
  final String? title;

  @override
  State<EmployeeProfileDetailScreen> createState() =>
      _EmployeeProfileDetailScreenState();
}

class _EmployeeProfileDetailScreenState
    extends State<EmployeeProfileDetailScreen> {
  final _service = ProfileService();
  EmployeeProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _service.fetchEmployeeProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDashboardV2Theme.shell,
      appBar: AppBar(
        backgroundColor: EmployeeDashboardV2Theme.shell,
        elevation: 0,
        title: Text(
          widget.title ?? 'Team member',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: EmployeeDashboardV2Theme.textDark,
          ),
        ),
        iconTheme: const IconThemeData(color: EmployeeDashboardV2Theme.textDark),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: EmployeeDashboardV2Theme.green,
              ),
            )
          : _error != null
              ? Center(child: Text(_error!))
              : _body(_profile!),
    );
  }

  Widget _body(EmployeeProfile profile) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              EmployeeAvatar.fromProfile(
                profile,
                size: 96,
                borderRadius: BorderRadius.circular(48),
              ),
              const SizedBox(height: 12),
              Text(
                profile.displayName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: EmployeeDashboardV2Theme.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ProfileReadOnlyTile(
          label: 'Employee ID',
          value: profileDisplayValue(profile.employeeId),
        ),
        ProfileReadOnlyTile(
          label: 'Email',
          value: profileDisplayValue(profile.email),
        ),
        ProfileReadOnlyTile(
          label: 'Role',
          value: profileDisplayValue(profile.roleDisplay ?? profile.role),
        ),
        ProfileReadOnlyTile(
          label: 'Department',
          value: profileDisplayValue(profile.department),
        ),
        ProfileReadOnlyTile(
          label: 'Designation',
          value: profileDisplayValue(profile.designation),
        ),
        ProfileReadOnlyTile(
          label: 'Work location',
          value: profileDisplayValue(
            profile.workLocationDisplay ?? profile.workLocation,
          ),
        ),
        ProfileReadOnlyTile(
          label: 'Phone',
          value: profileDisplayValue(profile.phoneNumber),
        ),
      ],
    );
  }
}
