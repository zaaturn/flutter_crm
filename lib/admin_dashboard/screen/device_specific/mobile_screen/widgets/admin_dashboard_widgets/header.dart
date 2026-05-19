import 'package:flutter/material.dart';

import 'package:my_app/screens/device_specific/welcome_mobile.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  static Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout from Daxarrow?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true) return;


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logging out..."), duration: Duration(seconds: 1)),
    );

    // TODO: Clear your Django tokens here


    if (context.mounted) {

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreenmobile()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFE11D48),
              size: 24,
            ),
          ),

          const Text(
            'Admin Panel',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF4456BA),
            ),
          ),

          const Icon(
            Icons.notifications_rounded,
            color: Color(0xFF4456BA),
            size: 26,
          ),
        ],
      ),
    );
  }
}