import 'package:flutter/material.dart';

// Welcome
import 'package:my_app/screens/welcome_screen.dart';

// Login
import 'package:my_app/screens/device_specific/login_mobile.dart';
import 'package:my_app/screens/device_specific/welcome_desktop.dart';

// Profile
import 'package:my_app/screens/profile_screen.dart';
import 'package:my_app/screens/device_specific/profile_screen_desktop.dart';

// Dashboard
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen.dart';
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen_desktop.dart';
import 'package:my_app/admin_dashboard/screen/admin_dashboard.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';

// Calendar (ADD BOTH)
import 'package:my_app/event_management/features/presentation/screen/calendar_screen.dart';

import 'package:my_app/event_management/features/presentation/screen/calendar_screen_desktop.dart';


// Core
import 'package:my_app/core/layout/adaptive_layout.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

    // =====================
    // WELCOME
    // =====================
      case '/':
        return MaterialPageRoute(
          builder: (_) => const WelcomePage(),
        );

    // =====================
    // EMPLOYEE LOGIN
    // =====================
      case '/employeeLogin':
        return MaterialPageRoute(
          builder: (_) => AdaptiveLayout(
            mobile: const LoginMobile(role: "Employee"),
            tablet: const LoginMobile(role: "Employee"),
            webDesktop: const LoginScreen(),
          ),
        );

    // =====================
    // ADMIN LOGIN
    // =====================
      case '/adminLogin':
        return MaterialPageRoute(
          builder: (_) => const AdaptiveLayout(
            mobile: LoginMobile(role: 'Admin',),
            tablet: LoginMobile(role: 'Admin',),
            webDesktop: LoginScreen(),
          ),
        );


    // =====================
    // EMPLOYEE DASHBOARD
    // =====================
      case '/employeeDashboard':
        return MaterialPageRoute(
          builder: (_) => AdaptiveLayout(
            mobile: const EmployeeDashboardScreen(),
            tablet: const EmployeeDashboardScreen(),
            webDesktop: const EmployeeDashboardDesktop(),
          ),
        );

    // =====================
    // ADMIN DASHBOARD
    // =====================
      case '/adminDashboard':
        return MaterialPageRoute(
          builder: (_) => AdaptiveLayout(
            mobile: const AdminDashboardScreen(),
            tablet: const AdminDashboardScreen(),
            webDesktop: const AdminDashboardDesktop(),
          ),
        );

    // =====================
    // PROFILE
    // =====================
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => AdaptiveLayout(
            mobile: const ProfileScreen(),
            tablet: const ProfileScreen(),
            webDesktop: const ProfileDesktop(),
          ),
        );

    // =====================
    // CALENDAR  ✅ UPDATED
    // =====================
      case '/calendar':
        return MaterialPageRoute(
          builder: (_) => AdaptiveLayout(
            mobile: const CalendarScreenMobile(),
            tablet: const CalendarScreenMobile(),
            webDesktop: const CalendarScreenDesktop(),
          ),
        );

    // =====================
    // FALLBACK
    // =====================
      default:
        return MaterialPageRoute(
          builder: (_) => const WelcomePage(),
        );
    }
  }
}
