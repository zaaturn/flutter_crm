import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_v2_widgets.dart';
import 'package:my_app/main.dart' show navigatorKey;
import 'package:my_app/services/secure_storage_service.dart';

import 'apply_leave_form.dart';

class ApplyLeaveScreenDesktop extends StatefulWidget {
  const ApplyLeaveScreenDesktop({super.key});

  @override
  State<ApplyLeaveScreenDesktop> createState() =>
      _ApplyLeaveScreenDesktopState();
}

class _ApplyLeaveScreenDesktopState extends State<ApplyLeaveScreenDesktop> {
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final token = await SecureStorageService().readToken();
    if (!mounted) return;

    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: EmployeeDashboardV2Theme.shell,
        body: const Center(
          child: CircularProgressIndicator(
            color: EmployeeDashboardV2Theme.green,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: EmployeeDashboardV2Theme.shell,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_person_outlined,
                size: 64,
                color: EmployeeDashboardV2Theme.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'Session Expired',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: EmployeeDashboardV2Theme.textDark,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EmployeeDashboardV2Theme.greenMid,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return const _ApplyLeaveDesktopView();
  }
}

class _ApplyLeaveDesktopView extends StatefulWidget {
  const _ApplyLeaveDesktopView();

  @override
  State<_ApplyLeaveDesktopView> createState() => _ApplyLeaveDesktopViewState();
}

class _ApplyLeaveDesktopViewState extends State<_ApplyLeaveDesktopView> {
  String? _errorMessage;
  List<LeaveType>? _cachedLeaveTypes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<LeaveBloc>();
      bloc.add(const LoadLeaveTypes());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDashboardV2Theme.shell,
      body: SafeArea(
        child: Column(
          children: [
            const LeaveV2TopBar(title: 'Apply Leave'),
            Expanded(
              child: BlocConsumer<LeaveBloc, LeaveState>(
                listener: (context, state) {
                  if (state is LeaveTypesLoaded) {
                    setState(() => _cachedLeaveTypes = state.leaveTypes);
                  }

                  if (state is LeaveActionSuccess) {
                    setState(() => _errorMessage = null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        width: 400,
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(state.message),
                          ],
                        ),
                        backgroundColor: EmployeeDashboardV2Theme.greenMid,
                      ),
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) return;
                      final rootCtx = navigatorKey.currentContext ?? context;
                      EmployeeDashboardNavigator.dashboard(rootCtx);
                    });
                  }
                  if (state is LeaveError) {
                    setState(() => _errorMessage = state.message);
                  }
                },
                builder: (context, state) {
                  if ((state is LeaveTypesLoading || state is LeaveInitial) &&
                      _cachedLeaveTypes == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: EmployeeDashboardV2Theme.green,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LeaveV2PageTitle(
                              title: 'Request New Leave',
                              subtitle:
                                  'Submit your leave request for manager approval.',
                            ),
                            const SizedBox(height: 24),
                            if (_errorMessage != null)
                              _ErrorBanner(message: _errorMessage!),
                            LeaveV2ContentCard(
                              padding: const EdgeInsets.all(32),
                              child: _cachedLeaveTypes != null
                                  ? ApplyLeaveForm(
                                      leaveTypes: _cachedLeaveTypes!,
                                    )
                                  : const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: CircularProgressIndicator(
                                          color: EmployeeDashboardV2Theme.green,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 24),
                            _buildPolicyNotice(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EmployeeDashboardV2Theme.greenLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EmployeeDashboardV2Theme.green.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: EmployeeDashboardV2Theme.greenMid,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Note: Leave requests must be submitted at least 48 hours in advance for processing.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: EmployeeDashboardV2Theme.textBody,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel, color: Color(0xFFDC2626)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
