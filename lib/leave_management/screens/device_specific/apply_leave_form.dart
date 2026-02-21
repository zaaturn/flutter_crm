import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  State<ApplyLeaveForm> createState() =>
      _ApplyLeaveFormState();
}

class _ApplyLeaveFormState
    extends State<ApplyLeaveForm> {
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<LeaveType>(
            value: _selectedLeaveType,
            items: widget.leaveTypes
                .map((e) =>
                DropdownMenuItem(
                    value: e,
                    child: Text(e.name)))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedLeaveType = v),
            validator: (v) =>
            v == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _startDateController,
            readOnly: true,
            onTap: () => _pickDate(true),
            validator: (v) =>
            v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _endDateController,
            readOnly: true,
            onTap: () => _pickDate(false),
            validator: (v) =>
            v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reasonController,
            maxLines: 4,
            validator: (v) =>
            v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text =
              DateFormat('yyyy-MM-dd')
                  .format(picked);
        } else {
          _endDate = picked;
          _endDateController.text =
              DateFormat('yyyy-MM-dd')
                  .format(picked);
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<LeaveBloc>().add(
        ApplyLeave(
          leaveTypeId:
          _selectedLeaveType!.id,
          startDate: _startDate!,
          endDate: _endDate!,
          approverId:
          _selectedApprover!.id,
          reason:
          _reasonController.text.trim(),
        ),
      );
    }
  }
}