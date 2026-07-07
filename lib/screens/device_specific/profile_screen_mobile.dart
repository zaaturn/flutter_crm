import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'package:my_app/employee_dashboard/model/employee_profile.dart';
import 'package:my_app/employee_dashboard/widget/employee_avatar.dart';
import 'package:my_app/screens/profile/profile_form_widgets.dart';
import 'package:my_app/services/api_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _bg = Color(0xFFFAF3E0);
  static const _cardColor = Color(0xFFEADBC8);
  static const _terracotta = Color(0xFFC05E41);
  static const _textDark = Color(0xFF3E2723);
  static const _textMuted = Color(0xFF8D6E63);

  final _profileService = ProfileService();
  final _picker = ImagePicker();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  EmployeeProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  bool _uploading = false;

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
    setState(() => _loading = true);
    try {
      final profile = await _profileService.fetchMyProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
      syncProfileControllers(
        profile,
        firstName: _firstName,
        lastName: _lastName,
        phone: _phone,
        address: _address,
      );
      context.read<EmployeeBloc>().add(EmployeeProfileUpdated(profile));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Failed to load profile');
    }
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
      syncProfileControllers(
        updated,
        firstName: _firstName,
        lastName: _lastName,
        phone: _phone,
        address: _address,
      );
      context.read<EmployeeBloc>().add(EmployeeProfileUpdated(updated));
      _snack('Profile updated', success: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Save failed');
    }
  }

  Future<void> _pickPhoto() async {
    if (_uploading) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final photoUrl = await _profileService.uploadProfilePhoto(picked);
      if (!mounted) return;
      final updated = (_profile ?? await _profileService.fetchMyProfile())
          .copyWith(profilePhoto: photoUrl);
      setState(() {
        _profile = updated;
        _uploading = false;
      });
      context.read<EmployeeBloc>().add(EmployeeProfileUpdated(updated));
      _snack('Photo updated', success: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      _snack('Upload failed');
    }
  }

  void _snack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? const Color(0xFF2F7D32) : _terracotta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _terracotta))
          : _profile == null
              ? const Center(child: Text('Could not load profile'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _avatarCard(_profile!),
                    const SizedBox(height: 16),
                    _card(
                      title: 'Work details',
                      children: [
                        _infoRow('Employee ID', profileDisplayValue(_profile!.employeeId)),
                        _infoRow('Email', profileDisplayValue(_profile!.email)),
                        _infoRow('Role', profileDisplayValue(_profile!.roleDisplay ?? _profile!.role)),
                        _infoRow('Department', profileDisplayValue(_profile!.department)),
                        _infoRow('Designation', profileDisplayValue(_profile!.designation)),
                        _infoRow(
                          'Work location',
                          profileDisplayValue(
                            _profile!.workLocationDisplay ?? _profile!.workLocation,
                          ),
                        ),
                        _infoRow('Joining date', profileDisplayValue(_profile!.dateOfJoining)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _card(
                      title: 'Personal details',
                      children: [
                        _field('First name', _firstName),
                        _field('Last name', _lastName),
                        _field('Phone', _phone),
                        _field('Address', _address, maxLines: 2),
                        _infoRow(
                          'Date of birth',
                          profileDisplayValue(_profile!.dateOfBirth),
                        ),
                        _infoRow(
                          'Gender',
                          profileDisplayValue(
                            _profile!.genderDisplay ?? _profile!.gender,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _saving ? null : _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: _terracotta,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save changes',
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _avatarCard(EmployeeProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _terracotta.withValues(alpha: 0.18)),
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
                backgroundColor: const Color(0xFFF6E7D2),
                foregroundColor: _terracotta,
                border: Border.all(color: _terracotta.withValues(alpha: 0.25)),
              ),
              if (_uploading)
                const CircularProgressIndicator(color: _terracotta),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profile.displayName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          TextButton.icon(
            onPressed: _uploading ? null : _pickPhoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Change photo'),
            style: TextButton.styleFrom(foregroundColor: _terracotta),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _terracotta.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: _bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _terracotta.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _terracotta.withValues(alpha: 0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
