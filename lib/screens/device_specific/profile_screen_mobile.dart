
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/services/api_services.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;

  final ProfileService profileService = ProfileService();   // NEW

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ------------------- Load Profile -------------------

  void loadProfile() async {
    try {
      final data = await profileService.getProfile();
      setState(() => profile = data);
    } catch (e) {
      print("PROFILE LOAD ERROR: $e");
    }
  }

  // ------------------- Pick & Upload Photo -------------------

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final result = await profileService.uploadProfilePhoto(picked.path);

      if (result["profile_photo"] != null) {
        setState(() {
          profile!["profile_photo"] = result["profile_photo"];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated!")),
        );
      }
    } catch (e) {
      print("PHOTO UPLOAD ERROR: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to upload photo")));
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
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: _modernAppBar(),
      body: Stack(
        children: [
          _glowingBG(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                _profileHeader(),
                const SizedBox(height: 25),
                _glassCard(
                  child: Column(
                    children: [
                      _infoRow("Name", profile!["username"]),
                      _infoRow("Employee ID", profile!["employee_id"]),
                      _infoRow("Email", profile!["email"]),
                      _infoRow("Phone", profile!["phone_number"]),
                      _infoRow("Address", profile!["address"]),
                      _infoRow("DOB", profile!["date_of_birth"]),
                      _infoRow("Joining Date", profile!["date_of_joining"]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- AppBar -------------------

  AppBar _modernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: const Text(
        "My Profile",
        style: TextStyle(
          color: Color(0xFF333333),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
    );
  }

  // ------------------- Animated Background -------------------

  Widget _glowingBG() {
    return Stack(
      children: [
        Positioned(top: 80, left: 40, child: _orb(180, const Color(0xFF6A8DFF))),
        Positioned(bottom: 120, right: 40, child: _orb(200, const Color(0xFFF48FB1))),
      ],
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.07),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 120,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  // ------------------- Profile Header -------------------

  Widget _profileHeader() {
    return Column(
      children: [
        const Icon(Icons.business, size: 55, color: Color(0xFF6A8DFF)),
        const SizedBox(height: 6),
        const Text(
          "Dax Arrow",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 25),

        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.indigoAccent.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage(
                _profilePhotoUrl(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _profilePhotoUrl() {
    final photo = profile!["profile_photo"];
    if (photo == null || photo == "") {
      return "https://i.pravatar.cc/200";
    }
    return "http://192.168.1.10:8000$photo";
  }

  // ------------------- Glass Card -------------------

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ------------------- Info Row -------------------

  Widget _infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value == null || value.toString().isEmpty ? "—" : value.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



