import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'package:my_app/leave_management/models/leave_request.dart';

class ApplyLeaveForm extends StatefulWidget {
  final List<LeaveType> leaveTypes;
  final LeaveRequest? existingLeave;

  const ApplyLeaveForm({
    super.key,
    required this.leaveTypes,
    this.existingLeave,
  });

  @override
  State<ApplyLeaveForm> createState() => _ApplyLeaveFormState();
}

class _ApplyLeaveFormState extends State<ApplyLeaveForm> {
  final _formKey = GlobalKey<FormState>();

  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;

  final _reasonController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingLeave != null) {
      final leave = widget.existingLeave!;

      _reasonController.text = leave.reason ?? "";
      _startDate = leave.startDate;
      _endDate = leave.endDate;

      _startDateController.text = DateFormat('yyyy-MM-dd').format(leave.startDate);
      _endDateController.text = DateFormat('yyyy-MM-dd').format(leave.endDate);

      if (widget.leaveTypes.isNotEmpty) {
        try {
          _selectedLeaveType = widget.leaveTypes.firstWhere(
                (type) => type.id == leave.leaveType,
          );
        } catch (_) {
          _selectedLeaveType = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state is LeaveActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // 1. Close the dialog immediately
          Navigator.of(context, rootNavigator: true).pop();

          // 2. CRITICAL FIX: Reset state back to 'Loaded' so the second edit works
          // This removes the "LeaveActionSuccess" state which causes the loader loop
          context.read<LeaveBloc>().add(const LoadLeaveTypes());

          // 3. Refresh the list on the background screen
          context.read<LeaveBloc>().add(const LoadMyLeaves(status: 'PENDING'));
        } else if (state is LeaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputGroup("Leave Category", _buildLeaveTypeDropdown()),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildInputGroup("Start Date", _buildDatePicker(true))),
                const SizedBox(width: 24),
                Expanded(child: _buildInputGroup("End Date", _buildDatePicker(false))),
              ],
            ),
            const SizedBox(height: 24),
            _buildInputGroup("Reason for Leave", _buildReasonField()),
            const SizedBox(height: 32),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputGroup(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB))),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildLeaveTypeDropdown() {
    return DropdownButtonFormField<LeaveType>(
      value: _selectedLeaveType, // Changed from initialValue to value for better state tracking
      decoration: _inputDecoration(Icons.category_outlined),
      items: widget.leaveTypes.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
      onChanged: (v) => setState(() => _selectedLeaveType = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildDatePicker(bool isStart) {
    return TextFormField(
      controller: isStart ? _startDateController : _endDateController,
      readOnly: true,
      onTap: () => _pickDate(isStart),
      decoration: _inputDecoration(Icons.calendar_today_outlined),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      maxLines: 3,
      decoration: _inputDecoration(Icons.edit_note).copyWith(hintText: "Brief explanation..."),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildSubmitSection() {
    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {
        if (state is LeaveSubmitting) {
          return const Align(
            alignment: Alignment.centerRight,
            child: CircularProgressIndicator(strokeWidth: 3),
          );
        }
        return Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(widget.existingLeave == null ? "Submit Request" : "Update Request"),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
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
      if (widget.existingLeave != null) {
        context.read<LeaveBloc>().add(
          UpdateLeave(
            leaveId: widget.existingLeave!.id!,
            leaveTypeId: _selectedLeaveType!.id,
            startDate: _startDate!,
            endDate: _endDate!,
            reason: _reasonController.text.trim(),
          ),
        );
      } else {
        context.read<LeaveBloc>().add(
          ApplyLeave(
            leaveTypeId: _selectedLeaveType!.id,
            startDate: _startDate!,
            endDate: _endDate!,
            reason: _reasonController.text.trim(),
          ),
        );
      }
    }
  }
}