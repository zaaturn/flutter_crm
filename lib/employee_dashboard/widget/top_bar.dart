import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For the modern dialog look
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/screens/device_specific/welcome_mobile.dart';
import '../utils/design_tokens.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final BuildContext scaffoldContext;

  const TopBar({
    super.key,
    required this.scaffoldContext,
  });

  // --- LOGOUT CONFIRMATION DIALOG ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: const Text(
            "Are you sure you want to logout from Zaaturn?",
            style: TextStyle(color: Color(0xFF666666)),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF9E9E9E)),
              ),
            ),
            // Confirm Logout Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _executeLogout(context); // Run navigation
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  // --- ACTUAL NAVIGATION LOGIC ---
  void _executeLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreenmobile(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        final employee = state.employee;
        final String firstName = employee?.name ?? "User";
        final String profilePic = employee?.profilePhoto ?? "";
        final String initials = firstName.isNotEmpty
            ? firstName[0].toUpperCase()
            : "U";

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- LEFT: PROFILE & NAME ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: profilePic.isNotEmpty
                        ? NetworkImage(profilePic)
                        : null,
                    child: profilePic.isEmpty
                        ? Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome Back,",
                        style: AppTextStyles.label(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        firstName,
                        style: AppTextStyles.headline(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // --- RIGHT: ACTIONS (BELL & LOGOUT) ---
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {},
                  ),

                  Container(
                    height: 18,
                    width: 1,
                    color: AppColors.onSurfaceVariant.withOpacity(0.15),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),

                  // --- LOGOUT ICON TRIGGERS DIALOG ---
                  IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFDC3545),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}