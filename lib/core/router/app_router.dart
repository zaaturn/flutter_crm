import 'package:flutter/material.dart';

// Welcome
import 'package:my_app/screens/welcome_screen.dart';

// Login
import 'package:my_app/screens/device_specific/welcome_mobile.dart';
import 'package:my_app/screens/device_specific/welcome_desktop.dart';

// Profile
import 'package:my_app/screens/device_specific/profile_screen_mobile.dart';
import 'package:my_app/screens/device_specific/profile_screen_desktop.dart';

// Dashboard
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen.dart';
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen_desktop.dart';
import 'package:my_app/admin_dashboard/screen/admin_dashboard.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/admin_dashboard_mobile.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';


import 'package:my_app/event_management/features/presentation/screen/calendar_screen.dart';
import 'package:my_app/event_management/features/presentation/screen/calendar_screen_desktop.dart';


import 'package:my_app/core/layout/adaptive_layout.dart';
import 'package:my_app/core/router/startup_gate.dart';


import 'package:my_app/screens/splash_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

    // =====================
    // ROOT (SPLASH CONTROL)
    // =====================
      case '/':
        return MaterialPageRoute(
          builder: (_) => const MobileSplashEntry(),
        );

    // =====================
    // EMPLOYEE LOGIN
    // =====================
      case '/employeeLogin':
        return MaterialPageRoute(
          builder: (_) => AdaptiveLayout(
            mobile: const LoginScreenmobile(),
            tablet: const LoginScreenmobile(),
            webDesktop: const LoginScreen(),
          ),
        );

    // =====================
    // ADMIN LOGIN
    // =====================
      case '/adminLogin':
        return MaterialPageRoute(
          builder: (_) => const AdaptiveLayout(
            mobile: LoginScreenmobile(),
            tablet: LoginScreenmobile(),
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
            mobile: const AdminDashboardMobile(),
            tablet: const AdminDashboardMobile(),
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
            webDesktop: const ProfileScreenDesktop(),
          ),
        );

    // =====================
    // CALENDAR
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

// =====================
// MOBILE SPLASH ENTRY (OUTSIDE CLASS)
// =====================
class MobileSplashEntry extends StatelessWidget {
  const MobileSplashEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mobile: const SplashScreen(),
      tablet: const SplashScreen(),
      webDesktop: const StartupGate(),
    );
  }
}