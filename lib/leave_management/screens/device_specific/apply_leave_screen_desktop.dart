import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/leave_management/models/leave_type.dart';

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 3)),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Session Expired",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => LeaveBloc(LeaveApiService())..add(const LoadLeaveTypes()),
      child: const _ApplyLeaveDesktopView(),
    );
  }
}

class _ApplyLeaveDesktopView extends StatefulWidget {
  const _ApplyLeaveDesktopView();

  @override
  State<_ApplyLeaveDesktopView> createState() => _ApplyLeaveDesktopViewState();
}

class _ApplyLeaveDesktopViewState extends State<_ApplyLeaveDesktopView> {
  String? _errorMessage;
  List<LeaveType>? _cachedLeaveTypes; // Cache the data locally

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Leave Management",
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline, color: Colors.grey)),
          const SizedBox(width: 20),
        ],
      ),
      body: BlocConsumer<LeaveBloc, LeaveState>(
        listener: (context, state) {
          if (state is LeaveTypesLoaded) {
            // Store the leave types in state when they arrive
            setState(() {
              _cachedLeaveTypes = state.leaveTypes;
            });
          }

          if (state is LeaveActionSuccess) {
            setState(() => _errorMessage = null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                width: 400,
                content: Row(children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(state.message)
                ]),
                backgroundColor: const Color(0xFF059669),
              ),
            );
          }
          if (state is LeaveError) {
            setState(() => _errorMessage = state.message);
          }
        },
        builder: (context, state) {
          // Only show loading if we don't have cached data yet
          if ((state is LeaveTypesLoading || state is LeaveInitial) && _cachedLeaveTypes == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBreadcrumbs(),
                    const SizedBox(height: 8),
                    const Text("Request New Leave",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    const SizedBox(height: 32),

                    if (_errorMessage != null) _ErrorBanner(message: _errorMessage!),

                    // Main Form Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4)
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      // USE THE CACHE: This prevents the "Error loading form components"
                      child: (_cachedLeaveTypes != null)
                          ? ApplyLeaveForm(leaveTypes: _cachedLeaveTypes!)
                          : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
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
    );
  }

  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        Text("Dashboard", style: TextStyle(color: Colors.blueGrey.shade400)),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        const Text("Leave Request", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildPolicyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Note: Leave requests must be submitted at least 48 hours in advance for processing.",
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
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
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel, color: Color(0xFFDC2626)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}