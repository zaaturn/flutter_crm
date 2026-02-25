import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:my_app/services/api_services.dart';

class ProfileScreenDesktop extends StatefulWidget {
  const ProfileScreenDesktop({super.key});

  @override
  State<ProfileScreenDesktop> createState() => _ProfileScreenDesktopState();
}

class _ProfileScreenDesktopState extends State<ProfileScreenDesktop> {
  Map<String, dynamic>? profile;
  final ProfileService profileService = ProfileService();
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    try {
      final data = await profileService.getProfile();
      setState(() => profile = data);
    } catch (e) {
      debugPrint("PROFILE LOAD ERROR: $e");
    }
  }

  String _getFormattedImageUrl() {
    final photo = profile?["profile_photo"];

    if (photo == null || photo.toString().isEmpty) {
      return "https://ui-avatars.com/api/?name=${profile?['username'] ?? 'User'}&background=7B52EF&color=fff";
    }

    // Extract root domain from API base
    final apiBase = profileService.baseUrl;
    final uri = Uri.parse(apiBase);

    final root =
        "${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}";

    final cleanPath = photo.toString().startsWith('/')
        ? photo.toString()
        : "/${photo.toString()}";

    return "$root$cleanPath";
  }


  Future<void> _handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null) return;

    setState(() => isUploading = true);

    try {
      final platformFile = result.files.single;

      if (platformFile.bytes == null) {
        throw Exception("No file bytes received.");
      }

      final xFile = XFile.fromData(
        platformFile.bytes!,
        name: platformFile.name,
        mimeType: 'image/jpeg',
      );

      final uploadResult =
      await profileService.uploadProfilePhoto(xFile);

      if (uploadResult["profile_photo"] != null) {
        setState(() {
          profile!["profile_photo"] =
          uploadResult["profile_photo"];
        });

        _showSnackBar("Success", "Profile photo updated!", Colors.green);
      }
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      _showSnackBar(
          "Upload Failed", "Could not update photo.", Colors.redAccent);
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _showSnackBar(String title, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title: $message"),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          _buildBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 50),
                _buildHeader(),
                const SizedBox(height: 20),
                _infoTile("Email Address", profile!["email"],
                    Icons.alternate_email),
                _infoTile("Phone Number", profile!["phone_number"],
                    Icons.phone_iphone),
                _infoTile("Employee ID", profile!["employee_id"],
                    Icons.badge_outlined),
                _infoTile("Address", profile!["address"],
                    Icons.map_outlined),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 110,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5C35C9), Color(0xFF7B52EF)],
            ),
          ),
        ),
        Positioned(bottom: -40, left: 24, child: _avatarWidget()),
        Positioned(
          bottom: 12,
          left: 125,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile!["username"] ?? "User",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const Text(
                "Active Employee",
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3)),
          child: CircleAvatar(
            radius: 42,
            backgroundColor: Colors.grey[100],
            backgroundImage: NetworkImage(_getFormattedImageUrl()),
          ),
        ),
        if (isUploading)
          const CircularProgressIndicator(
              color: Color(0xFF5C35C9)),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isUploading ? null : _handleImagePick,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: isUploading
                  ? Colors.grey
                  : const Color(0xFF5C35C9),
              child: const Icon(Icons.edit,
                  size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Details",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A1A2E))),
        TextButton(onPressed: () {}, child: const Text("Edit")),
      ],
    );
  }

  Widget _infoTile(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFF8F8FC),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 18,
                color: const Color(0xFF5C35C9)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight:
                          FontWeight.bold)),
                  Text(value?.toString() ?? "—",
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}