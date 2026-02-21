import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'package:my_app/leave_management/models/approver.dart';

class ApplyLeaveForm extends StatefulWidget {
  final List<LeaveType> leaveTypes;
  final List<Approver>? approvers;

  const ApplyLeaveForm({
    super.key,
    required this.leaveTypes,
    this.approvers,
  });

  @override
  State<ApplyLeaveForm> createState() => _ApplyLeaveFormState();
}

class _ApplyLeaveFormState extends State<ApplyLeaveForm> {
  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  Approver? _selectedApprover;

  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Leave & Approver
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputGroup("Leave Type", _buildLeaveTypeDropdown()),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildInputGroup("Approver", _buildApproverDropdown()),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section 2: Dates
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputGroup("Start Date", _buildDatePicker(true)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildInputGroup("End Date", _buildDatePicker(false)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section 3: Reason
          _buildInputGroup("Reason for Request", _buildReasonField()),

          const SizedBox(height: 40),

          // Bottom Action Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                ),
                child: const Text("Cancel", style: TextStyle(color: Color(0xFF6B7280))),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Apply for Leave', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI Layout Helpers ---

  Widget _buildInputGroup(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // --- Individual Input Builders ---

  Widget _buildLeaveTypeDropdown() {
    return DropdownButtonFormField<LeaveType>(
      value: _selectedLeaveType,
      decoration: _inputDecoration(Icons.assignment_outlined),
      items: widget.leaveTypes.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
      onChanged: (v) => setState(() => _selectedLeaveType = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildApproverDropdown() {
    return DropdownButtonFormField<Approver>(
      value: _selectedApprover,
      decoration: _inputDecoration(Icons.person_search_outlined),
      items: widget.approvers?.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList() ?? [],
      onChanged: (v) => setState(() => _selectedApprover = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildDatePicker(bool isStart) {
    return TextFormField(
      controller: isStart ? _startDateController : _endDateController,
      readOnly: true,
      onTap: () => _pickDate(isStart),
      decoration: _inputDecoration(Icons.calendar_today_rounded),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Please explain why you are requesting leave...",
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
    );
  }

  // --- Logical Operations ---

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
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
      if (_selectedApprover == null) return; // Safety check

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