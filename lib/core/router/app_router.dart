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
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/admin_dashboard_mobile.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';

import 'package:my_app/employee_dashboard/screen/employee_feed_screen_desktop.dart';
import 'package:my_app/dashboards/presentations/screens/feed_screen_mobile.dart';

import 'package:my_app/event_management/features/calendar/presentation/screen/calendar_screen_mobile.dart';
import 'package:my_app/event_management/features/calendar/presentation/screen/calendar_screen_desktop.dart';


import 'package:my_app/core/layout/adaptive_layout.dart';
import 'package:my_app/core/auth/admin_access_guard.dart';
import 'package:my_app/core/router/startup_gate.dart';

import 'package:my_app/auth/screens/dashboard_chooser_screen.dart';
import 'package:my_app/auth/screens/superadmin_users_screen.dart';

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
          builder: (_) => const AdminRouteGuard(
            child: AdaptiveLayout(
              mobile: AdminDashboardMobile(),
              tablet: AdminDashboardMobile(),
              webDesktop: AdminDashboardDesktop(),
            ),
          ),
        );

      case '/dashboardChooser':
        return MaterialPageRoute(
          builder: (_) => const AdminRouteGuard(
            child: DashboardChooserScreen(),
          ),
        );

      case '/superadmin':
        return MaterialPageRoute(
          builder: (_) => const SuperadminUsersScreen(),
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
            tablet: const CalendarScreenDesktop(),
            webDesktop: const CalendarScreenDesktop(),
          ),
        );

    // =====================
    // FEED (Shared posts)
    // =====================
      case '/feed':
        return MaterialPageRoute(
          builder: (_) => AdaptiveLayout(
            mobile: const FeedScreenMobile(),
            tablet: const FeedScreenMobile(),
            webDesktop: const EmployeeFeedScreenDesktop(),
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
// mobile SPLASH ENTRY (OUTSIDE CLASS)
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