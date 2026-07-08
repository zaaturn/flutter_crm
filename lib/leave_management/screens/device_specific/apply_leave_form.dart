import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_balance_response.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/widgets/leave_holiday_date_picker_dialog.dart';

class ApplyLeaveForm extends StatefulWidget {
  final List<LeaveType> leaveTypes;
  final Map<int, LeaveBalanceItem> balanceByTypeId;
  final LeaveRequest? existingLeave;

  /// Desktop dialog: `true` (default). Modal bottom sheet: `false` so only the sheet pops.
  final bool useRootNavigatorForPop;

  const ApplyLeaveForm({
    super.key,
    required this.leaveTypes,
    this.balanceByTypeId = const {},
    this.existingLeave,
    this.useRootNavigatorForPop = true,
  });

  @override
  State<ApplyLeaveForm> createState() => _ApplyLeaveFormState();
}

class _ApplyLeaveFormState extends State<ApplyLeaveForm> {
  final _formKey = GlobalKey<FormState>();

  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  String _duration = 'FULL';

  final _reasonController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  static String _normalizeDuration(String raw) {
    final u = raw.trim().toUpperCase();
    if (u == 'HALF') return 'HALF';
    return 'FULL';
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingLeave != null) {
      final leave = widget.existingLeave!;

      _reasonController.text = leave.reason;
      _startDate = leave.startDate;
      _endDate = leave.endDate;
      _duration = _normalizeDuration(leave.duration);

      _startDateController.text = DateFormat('yyyy-MM-dd').format(leave.startDate);
      _endDateController.text = DateFormat('yyyy-MM-dd').format(leave.endDate);

      if (widget.leaveTypes.isNotEmpty) {
        final id = leave.leaveType?.id;
        if (id != null) {
          try {
            _selectedLeaveType = widget.leaveTypes.firstWhere((type) => type.id == id);
          } catch (_) {
            _selectedLeaveType = null;
          }
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

  void _clampDurationToType() {
    final t = _selectedLeaveType;
    if (t != null && !t.allowHalfDay && _duration == 'HALF') {
      _duration = 'FULL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeaveBloc, LeaveState>(
      listenWhen: (prev, current) {
        if (widget.existingLeave == null) return false;
        return current is LeaveActionSuccess || current is LeaveError;
      },
      listener: (context, state) {
        if (state is LeaveActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(
            context,
            rootNavigator: widget.useRootNavigatorForPop,
          ).pop(state.updatedLeave);
        } else if (state is LeaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputGroup('Leave Category', _buildLeaveTypeDropdown()),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildInputGroup('Start Date', _buildDatePicker(true))),
                const SizedBox(width: 24),
                Expanded(child: _buildInputGroup('End Date', _buildDatePicker(false))),
              ],
            ),
            const SizedBox(height: 24),
            _buildInputGroup('Duration', _buildDurationDropdown()),
            const SizedBox(height: 24),
            _buildInputGroup('Reason for Leave', _buildReasonField()),
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
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: EmployeeDashboardV2Theme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: EmployeeDashboardV2Theme.textMuted),
      filled: true,
      fillColor: EmployeeDashboardV2Theme.cardMuted,
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: EmployeeDashboardV2Theme.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: EmployeeDashboardV2Theme.green),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildLeaveTypeDropdown() {
    return DropdownButtonFormField<LeaveType>(
      value: _selectedLeaveType,
      decoration: _inputDecoration(Icons.category_outlined),
      items: widget.leaveTypes.map((e) {
        final balance = widget.balanceByTypeId[e.id];
        final label = balance != null
            ? '${e.name} (${balance.remainingLabel} days left)'
            : e.name;
        return DropdownMenuItem(value: e, child: Text(label));
      }).toList(),
      onChanged: (v) {
        setState(() {
          _selectedLeaveType = v;
          _clampDurationToType();
        });
      },
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildDurationDropdown() {
    final allowHalf = _selectedLeaveType?.allowHalfDay ?? true;
    final effective = (!allowHalf && _duration == 'HALF') ? 'FULL' : _duration;

    return DropdownButtonFormField<String>(
      value: effective,
      decoration: _inputDecoration(Icons.schedule_outlined),
      items: [
        const DropdownMenuItem(value: 'FULL', child: Text('Full day')),
        if (allowHalf)
          const DropdownMenuItem(value: 'HALF', child: Text('Half day')),
      ],
      onChanged: (v) {
        if (v != null) setState(() => _duration = v);
      },
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
      decoration: _inputDecoration(Icons.edit_note).copyWith(
        hintText: 'Brief explanation…',
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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
              backgroundColor: EmployeeDashboardV2Theme.greenMid,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(widget.existingLeave == null ? 'Submit Request' : 'Resubmit'),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await LeaveHolidayDatePickerDialog.show(
      context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
      title: isStart ? 'Start date' : 'End date',
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
            _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
          }
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  void _submit() {
    _clampDurationToType();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLeaveType == null || _startDate == null || _endDate == null) return;

    if (widget.existingLeave != null) {
      context.read<LeaveBloc>().add(
            UpdateLeave(
              leaveId: widget.existingLeave!.id!,
              leaveTypeId: _selectedLeaveType!.id,
              startDate: _startDate!,
              endDate: _endDate!,
              reason: _reasonController.text.trim(),
              duration: _duration,
            ),
          );
    } else {
      context.read<LeaveBloc>().add(
            ApplyLeave(
              leaveTypeId: _selectedLeaveType!.id,
              startDate: _startDate!,
              endDate: _endDate!,
              reason: _reasonController.text.trim(),
              duration: _duration,
            ),
          );
    }
  }
}
