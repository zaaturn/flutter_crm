import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'package:my_app/leave_management/models/approver.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';

class ApplyLeaveForm extends StatefulWidget {
  final List<LeaveType> leaveTypes;

  const ApplyLeaveForm({
    super.key,
    required this.leaveTypes,
  });

  @override
  State<ApplyLeaveForm> createState() => _ApplyLeaveFormState();
}

class _ApplyLeaveFormState extends State<ApplyLeaveForm> {
  final _formKey = GlobalKey<FormState>();
  final _api = LeaveApiService();

  // State Variables
  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  Approver? _selectedApprover;

  final _reasonController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _adminSearchController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _adminSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Leave Type & Admin Search
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInputGroup("Leave Category", _buildLeaveTypeDropdown())),
              const SizedBox(width: 24),
              Expanded(child: _buildInputGroup("Search Approver (Name/ID)", _buildApproverSearchField())),
            ],
          ),
          const SizedBox(height: 24),

          // Section 2: Dates
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInputGroup("Start Date", _buildDatePicker(true))),
              const SizedBox(width: 24),
              Expanded(child: _buildInputGroup("End Date", _buildDatePicker(false))),
            ],
          ),
          const SizedBox(height: 24),

          // Section 3: Reason
          _buildInputGroup("Reason for Leave", _buildReasonField()),

          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // --- Search Logic & UI ---

  Widget _buildApproverSearchField() {
    if (_selectedApprover != null) {
      // Selected User View
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF2563EB),
              radius: 16,
              child: Text(_selectedApprover!.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedApprover!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                  Text("ID: ${_selectedApprover!.id}",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF60A5FA))),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF1E40AF)),
              onPressed: () => setState(() => _selectedApprover = null),
            )
          ],
        ),
      );
    }

    // Search Input View
    return Autocomplete<Approver>(
      displayStringForOption: (Approver a) => a.name,
      optionsBuilder: (TextEditingValue textValue) async {
        if (textValue.text.length < 2) return const Iterable<Approver>.empty();
        return await _api.searchAdmins(textValue.text);
      },
      onSelected: (Approver a) => setState(() => _selectedApprover = a),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: _inputDecoration(Icons.search).copyWith(hintText: "Type name"),
          validator: (v) => _selectedApprover == null ? 'Please select an admin' : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 360),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final Approver option = options.elementAt(index);
                  return ListTile(
                    leading: const Icon(Icons.person_outline, color: Color(0xFF2563EB)),
                    title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("User ID: ${option.id}"),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Standard UI Components ---

  Widget _buildInputGroup(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildLeaveTypeDropdown() {
    return DropdownButtonFormField<LeaveType>(
      value: _selectedLeaveType,
      decoration: _inputDecoration(Icons.list_alt),
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
      decoration: _inputDecoration(Icons.calendar_today_rounded),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      maxLines: 3,
      decoration: _inputDecoration(Icons.edit_note).copyWith(hintText: "Enter the purpose of your leave"),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Color(0xFF6B7280))),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text("Submit Application", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // --- Core Logic ---

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100)
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
    if (_formKey.currentState!.validate() && _selectedApprover != null) {
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