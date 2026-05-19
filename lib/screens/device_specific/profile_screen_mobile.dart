import 'package:flutter/material.dart';
import 'package:my_app/services/api_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;

  final ProfileService profileService = ProfileService();

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
      debugPrint("PROFILE LOAD ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const bg = Color(0xFFFAF3E0);
    const card = Color(0xFFEADBC8);
    const terracotta = Color(0xFFC05E41);
    const textDark = Color(0xFF3E2723);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _card(
              cardColor: card,
              borderColor: terracotta.withValues(alpha: 0.18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _infoRow('Name', _fullName()),
                    _infoRow('Employee ID', profile!['employee_id']),
                    _infoRow('Email', profile!['email']),
                    _infoRow('Phone', profile!['phone_number']),
                    _infoRow('Address', profile!['address']),
                    _infoRow('DOB', profile!['date_of_birth']),
                    _infoRow('Joining Date', profile!['date_of_joining']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fullName() {
    final first = (profile?['first_name'] ?? profile?['firstName'] ?? '').toString().trim();
    final last = (profile?['last_name'] ?? profile?['lastName'] ?? '').toString().trim();
    final full = ('$first $last').trim();
    if (full.isNotEmpty) return full;
    return (profile?['username'] ?? '—').toString();
  }

  Widget _card({
    required Widget child,
    Color cardColor = Colors.white,
    Color borderColor = const Color(0xFFE2E8F0),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
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
              fontSize: 13,
              color: Color(0xFF8D6E63),
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value == null || value.toString().isEmpty ? "—" : value.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3E2723),
              ),
            ),
          ),
        ],
      ),
    );
  }
}