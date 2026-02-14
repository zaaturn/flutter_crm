import 'package:flutter/material.dart';
import 'package:my_app/services/secure_storage_service.dart';

class GreetingHeader extends StatefulWidget {
  const GreetingHeader({super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader> {
  String username = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }


  Future<void> _loadUser() async {
    final user = await SecureStorageService().readUser();

    if (!mounted) return;


    String rawUsername = (user?["username"] ?? "").toString().trim();


    String cleanName = rawUsername.contains('@')
        ? rawUsername.split('@').first
        : rawUsername;

    setState(() {
      username = cleanName;
    });
  }






  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back, $username 👋",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getTodayDate(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return "${_weekday(now.weekday)}, ${_month(now.month)} ${now.day}";
  }

  String _weekday(int v) {
    const days = [
      "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ];
    return days[v - 1];
  }

  String _month(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m - 1];
  }
}

