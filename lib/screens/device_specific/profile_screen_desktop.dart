import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'package:my_app/employee_dashboard/model/employee_profile.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/employee_dashboard/widget/employee_avatar.dart';
import 'package:my_app/screens/profile/profile_form_widgets.dart';
import 'package:my_app/services/api_services.dart';

class ProfileScreenDesktop extends StatefulWidget {
  const ProfileScreenDesktop({super.key});

  @override
  State<ProfileScreenDesktop> createState() => _ProfileScreenDesktopState();
}

class _ProfileScreenDesktopState extends State<ProfileScreenDesktop> {
  final _profileService = ProfileService();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  EmployeeProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _profileService.fetchMyProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
      _bindControllers(profile);
      context.read<EmployeeBloc>().add(EmployeeProfileUpdated(profile));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _bindControllers(EmployeeProfile profile) {
    syncProfileControllers(
      profile,
      firstName: _firstName,
      lastName: _lastName,
      phone: _phone,
      address: _address,
    );
  }

  Future<void> _save() async {
    final profile = _profile;
    if (profile == null || _saving) return;

    final body = buildProfilePatchBody(
      original: profile,
      firstName: _firstName.text,
      lastName: _lastName.text,
      phone: _phone.text,
      address: _address.text,
    );

    if (body.isEmpty) {
      _snack('No changes to save');
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await _profileService.updateMyProfile(body);
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _saving = false;
      });
      _bindControllers(updated);
      context.read<EmployeeBloc>().add(EmployeeProfileUpdated(updated));
      _snack('Profile updated', success: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Save failed: $e');
    }
  }

  Future<void> _pickPhoto() async {
    if (_uploading) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _uploading = true);
    try {
      final file = result.files.single;
      if (file.bytes == null) throw Exception('No image data');
      final xFile = XFile.fromData(
        file.bytes!,
        name: file.name,
        mimeType: 'image/jpeg',
      );
      final photoUrl = await _profileService.uploadProfilePhoto(xFile);
      if (!mounted) return;
      final updated = _profile?.copyWith(profilePhoto: photoUrl) ??
          await _profileService.fetchMyProfile();
      setState(() {
        _profile = updated.copyWith(profilePhoto: photoUrl);
        _uploading = false;
      });
      context.read<EmployeeBloc>().add(EmployeeProfileUpdated(_profile!));
      _snack('Photo updated', success: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      _snack('Upload failed: $e');
    }
  }

  void _snack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? EmployeeDashboardV2Theme.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: EmployeeDashboardV2Theme.green),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final profile = _profile!;

    return Container(
      width: 420,
      color: EmployeeDashboardV2Theme.shell,
      child: Column(
        children: [
          _header(profile),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _sectionTitle('Work details'),
                ProfileReadOnlyTile(
                  label: 'Employee ID',
                  value: profileDisplayValue(profile.employeeId),
                  icon: Icons.badge_outlined,
                ),
                ProfileReadOnlyTile(
                  label: 'Email',
                  value: profileDisplayValue(profile.email),
                  icon: Icons.alternate_email_rounded,
                ),
                ProfileReadOnlyTile(
                  label: 'Role',
                  value: profileDisplayValue(
                    profile.roleDisplay ?? profile.role,
                  ),
                  icon: Icons.work_outline_rounded,
                ),
                ProfileReadOnlyTile(
                  label: 'Department',
                  value: profileDisplayValue(profile.department),
                  icon: Icons.apartment_rounded,
                ),
                ProfileReadOnlyTile(
                  label: 'Designation',
                  value: profileDisplayValue(profile.designation),
                  icon: Icons.engineering_outlined,
                ),
                ProfileReadOnlyTile(
                  label: 'Work location',
                  value: profileDisplayValue(
                    profile.workLocationDisplay ?? profile.workLocation,
                  ),
                  icon: Icons.location_on_outlined,
                ),
                ProfileReadOnlyTile(
                  label: 'Date of joining',
                  value: profileDisplayValue(profile.dateOfJoining),
                  icon: Icons.event_available_outlined,
                ),
                const SizedBox(height: 8),
                _sectionTitle('Personal details'),
                ProfileTextField(label: 'First name', controller: _firstName),
                ProfileTextField(label: 'Last name', controller: _lastName),
                ProfileTextField(label: 'Phone', controller: _phone),
                ProfileTextField(
                  label: 'Address',
                  controller: _address,
                  maxLines: 2,
                ),
                ProfileReadOnlyTile(
                  label: 'Date of birth',
                  value: profileDisplayValue(profile.dateOfBirth),
                  icon: Icons.cake_outlined,
                ),
                ProfileReadOnlyTile(
                  label: 'Gender',
                  value: profileDisplayValue(
                    profile.genderDisplay ?? profile.gender,
                  ),
                  icon: Icons.wc_outlined,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: EmployeeDashboardV2Theme.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save changes',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(EmployeeProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: EmployeeDashboardV2Theme.cardBorder)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              EmployeeAvatar.fromProfile(
                profile,
                size: 88,
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: EmployeeDashboardV2Theme.cardBorder, width: 2),
              ),
              if (_uploading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: EmployeeDashboardV2Theme.green,
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: EmployeeDashboardV2Theme.green,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _uploading ? null : _pickPhoto,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profile.displayName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: EmployeeDashboardV2Theme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profileDisplayValue(profile.roleDisplay ?? profile.designation),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _uploading ? null : _pickPhoto,
            icon: const Icon(Icons.photo_camera_outlined, size: 18),
            label: const Text('Change photo'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: EmployeeDashboardV2Theme.textDark,
        ),
      ),
    );
  }
}
