import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';
import 'package:my_app/services/secure_storage_service.dart';

import 'apply_leave_form.dart';

class ApplyLeaveScreenDesktop extends StatefulWidget {
  const ApplyLeaveScreenDesktop({super.key});

  @override
  State<ApplyLeaveScreenDesktop> createState() =>
      _ApplyLeaveScreenDesktopState();
}

class _ApplyLeaveScreenDesktopState
    extends State<ApplyLeaveScreenDesktop> {
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/login'),
            child: const Text('Go to Login'),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) =>
      LeaveBloc(LeaveApiService())..add(const LoadLeaveTypes()),
      child: const _ApplyLeaveDesktopView(),
    );
  }
}

class _ApplyLeaveDesktopView extends StatefulWidget {
  const _ApplyLeaveDesktopView();

  @override
  State<_ApplyLeaveDesktopView> createState() =>
      _ApplyLeaveDesktopViewState();
}

class _ApplyLeaveDesktopViewState
    extends State<_ApplyLeaveDesktopView> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<LeaveBloc, LeaveState>(
        listener: (context, state) {
          if (state is LeaveActionSuccess) {
            setState(() => _errorMessage = null);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is LeaveError) {
            setState(() => _errorMessage = state.message);
          }
        },
        builder: (context, state) {
          if (state is LeaveTypesLoading ||
              state is LeaveInitial) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (state is LeaveTypesLoaded) {
            return Center(
              child: ConstrainedBox(
                constraints:
                const BoxConstraints(maxWidth: 672),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    if (_errorMessage != null)
                      _ErrorBanner(message: _errorMessage!),

                    ApplyLeaveForm(
                      leaveTypes: state.leaveTypes,
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
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
        border:
        Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFB91C1C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Color(0xFF7F1D1D),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}