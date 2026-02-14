import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/services/api_services.dart';

class ProfileDesktop extends StatefulWidget {
  const ProfileDesktop({super.key});

  @override
  State<ProfileDesktop> createState() => _ProfileDesktopState();
}

class _ProfileDesktopState extends State<ProfileDesktop> {
  Map<String, dynamic>? profile;
  final ProfileService profileService = ProfileService();
  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await profileService.getProfile();
      if (mounted) {
        setState(() {
          profile = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load profile";
          _isLoading = false;
        });
      }
      print("PROFILE LOAD ERROR: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final result = await profileService.uploadProfilePhoto(picked.path);

      if (result["profile_photo"] != null && mounted) {
        setState(() {
          profile!["profile_photo"] = result["profile_photo"];
          _isUploadingPhoto = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile photo updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to upload photo: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("PHOTO UPLOAD ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.business, size: 28, color: Colors.blue[700]),
            const SizedBox(width: 12),
            const Text(
              "Dax Arrow - My Profile",
              style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: loadProfile,
            tooltip: 'Refresh Profile',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  // ---------------- ERROR STATE ----------------

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: loadProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- MAIN CONTENT ----------------

  Widget _buildContent() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT PANEL
            _leftPanel(),

            const SizedBox(width: 40),

            // RIGHT PANEL
            Expanded(child: _rightPanel()),
          ],
        ),
      ),
    );
  }

  // ---------------- LEFT PANEL ----------------

  Widget _leftPanel() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(40),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Profile Photo with Upload Indicator
          Stack(
            children: [
              GestureDetector(
                onTap: _isUploadingPhoto ? null : _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage(_profilePhotoUrl()),
                    child: _isUploadingPhoto
                        ? Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
              ),
              if (!_isUploadingPhoto)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),

          // Name
          Text(
            profile!["username"] ?? "—",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            profile!["email"] ?? "—",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 30),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 30),

          // Company Info
          Icon(Icons.business, size: 40, color: Colors.blue[700]),
          const SizedBox(height: 12),
          const Text(
            "Dax Arrow",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "CRM Platform",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 30),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 20),

          // Quick Info
          _miniInfo("Employee ID", profile!["employee_id"]),
          _miniInfo("Role", profile!["role"] ?? "Employee"),
          _miniInfo("Status", "Active"),
        ],
      ),
    );
  }

  Widget _miniInfo(String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value?.toString() ?? "—",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- RIGHT PANEL ----------------

  Widget _rightPanel() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, size: 28, color: Colors.blue[700]),
              const SizedBox(width: 12),
              const Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          _infoSection("Contact Details", [
            _infoRow(Icons.phone_outlined, "Phone", profile!["phone_number"]),
            _infoRow(Icons.email_outlined, "Email", profile!["email"]),
            _infoRow(Icons.location_on_outlined, "Address", profile!["address"]),
          ]),

          const SizedBox(height: 30),

          _infoSection("Employment Details", [
            _infoRow(Icons.badge_outlined, "Employee ID", profile!["employee_id"]),
            _infoRow(Icons.calendar_today_outlined, "Date of Birth",
                profile!["date_of_birth"]),
            _infoRow(Icons.work_outline, "Joining Date",
                profile!["date_of_joining"]),
          ]),
        ],
      ),
    );
  }

  Widget _infoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue[700], size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value?.toString() ?? "Not provided",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- COMMON ----------------

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  String _profilePhotoUrl() {
    final photo = profile!["profile_photo"];
    if (photo == null || photo.toString().isEmpty) {
      return "https://i.pravatar.cc/300";
    }
    return "http://192.168.1.10:8000$photo";
  }
}