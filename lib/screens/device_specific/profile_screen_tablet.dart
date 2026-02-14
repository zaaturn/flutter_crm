import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/services/api_services.dart';

class ProfileTablet extends StatefulWidget {
  const ProfileTablet({super.key});

  @override
  State<ProfileTablet> createState() => _ProfileTabletState();
}

class _ProfileTabletState extends State<ProfileTablet> {
  Map<String, dynamic>? profile;
  final ProfileService profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await profileService.getProfile();
    setState(() => profile = data);
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final result =
    await profileService.uploadProfilePhoto(picked.path);

    if (result["profile_photo"] != null) {
      setState(() {
        profile!["profile_photo"] = result["profile_photo"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 30),
              _detailsCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 65,
              backgroundImage: NetworkImage(_profilePhotoUrl()),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile!["username"] ?? "—",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile!["email"] ?? "",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pill("Employee ID", profile!["employee_id"]),
              const SizedBox(width: 12),
              _pill("Role", profile!["role"]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$label: ${value ?? '—'}",
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------------- DETAILS ----------------

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow("Phone", profile!["phone_number"]),
          _infoRow("Address", profile!["address"]),
          _infoRow("Date of Birth", profile!["date_of_birth"]),
          _infoRow("Joining Date", profile!["date_of_joining"]),
        ],
      ),
    );
  }

  // ---------------- COMMON ----------------

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "—",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  String _profilePhotoUrl() {
    final photo = profile!["profile_photo"];
    if (photo == null || photo.isEmpty) {
      return "https://i.pravatar.cc/300";
    }
    return "http://192.168.1.10:8000$photo";
  }
}
