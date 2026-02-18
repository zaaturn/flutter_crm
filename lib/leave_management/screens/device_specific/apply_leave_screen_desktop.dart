import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'package:my_app/leave_management/models/approver.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';
import 'package:my_app/services/secure_storage_service.dart';

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
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (!_isAuthenticated) {
      return _buildAuthRequired(context);
    }

    return BlocProvider(
      create: (_) =>
      LeaveBloc(LeaveApiService())..add(const LoadLeaveTypes()),
      child: const _ApplyLeaveDesktopView(),
    );
  }

  Widget _buildAuthRequired(BuildContext context) {
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
}

class _ApplyLeaveDesktopView extends StatefulWidget {
  const _ApplyLeaveDesktopView();

  @override
  State<_ApplyLeaveDesktopView> createState() => _ApplyLeaveDesktopViewState();
}

class _ApplyLeaveDesktopViewState extends State<_ApplyLeaveDesktopView> {
  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  Approver? _selectedApprover;

  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final LeaveApiService _api = LeaveApiService();

  @override
  void dispose() {
    _reasonController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // background-light from HTML
      appBar: AppBar(
        title: const Text('Apply for Leave', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF4F46E5),
              child: Text('JD', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      body: BlocConsumer<LeaveBloc, LeaveState>(
        listener: (context, state) {
          if (state is LeaveActionSuccess) {
            Navigator.of(context).maybePop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            });
          }
          if (state is LeaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is LeaveTypesLoading || state is LeaveInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LeaveTypesLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672), // max-w-2xl
                  child: Column(
                    children: [
                      // Header Section
                      const Text('New Request', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      const Text('Fill in the details below to submit your leave application.', style: TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 40),

                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: _buildForm(state.leaveTypes),
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        "Your request will be sent to your immediate manager for approval.",
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildForm(List<LeaveType> types) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFieldLabelWrapper(
                  'Leave Type',
                  DropdownButtonFormField<LeaveType>(
                    value: _selectedLeaveType,
                    icon: const Icon(Icons.expand_more),
                    decoration: _inputDecoration(Icons.category),
                    items: types.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                    onChanged: (v) => setState(() => _selectedLeaveType = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Approver
              Expanded(
                child: _buildFieldLabelWrapper(
                  'Approver',
                  Autocomplete<Approver>(
                    displayStringForOption: (a) => a.name,
                    optionsBuilder: (v) async {
                      if (v.text.isEmpty) return const [];
                      return await _api.searchAdmins(v.text);
                    },
                    onSelected: (a) => setState(() => _selectedApprover = a),
                    fieldViewBuilder: (c, ctrl, focus, onSubmit) {
                      return TextFormField(
                        controller: ctrl,
                        focusNode: focus,
                        decoration: _inputDecoration(Icons.person),
                        validator: (_) => _selectedApprover == null ? 'Required' : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Start Date
              Expanded(
                child: _buildFieldLabelWrapper(
                  'Start Date',
                  TextFormField(
                    controller: _startDateController,
                    readOnly: true,
                    onTap: () => _pickDate(true),
                    decoration: _inputDecoration(Icons.calendar_today),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // End Date
              Expanded(
                child: _buildFieldLabelWrapper(
                  'End Date',
                  TextFormField(
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () => _pickDate(false),
                    decoration: _inputDecoration(Icons.calendar_today),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Reason
          _buildFieldLabelWrapper(
            'Reason',
            TextFormField(
              controller: _reasonController,
              maxLines: 5,
              decoration: _inputDecoration(Icons.description).copyWith(
                hintText: 'Briefly describe the reason...',
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(height: 32),
          // Bottom Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                  shadowColor: const Color(0xFF4F46E5).withOpacity(0.4),
                ),
                child: Row(
                  children: const [
                    Text('Apply for Leave', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabelWrapper(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4F46E5)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<LeaveBloc>().add(
        ApplyLeave(
          leaveTypeId: _selectedLeaveType!.id,
          startDate: _startDate!,
          endDate: _endDate!,
          approverId: _selectedApprover!.id,
          reason: _reasonController.text.trim(),
        ),
      );
    }
  }
}