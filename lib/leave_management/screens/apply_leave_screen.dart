import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../block/leave_bloc.dart';
import '../block/leave_event.dart';
import '../block/leave_state.dart';
import '../models/leave_type.dart';
import '../services/leave_api_services.dart';

class ApplyLeaveScreen extends StatelessWidget {
  const ApplyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaveBloc(LeaveApiService())..add(const LoadLeaveTypes()),
      child: const _ApplyLeaveView(),
    );
  }
}

class _ApplyLeaveView extends StatefulWidget {
  const _ApplyLeaveView();

  @override
  State<_ApplyLeaveView> createState() => _ApplyLeaveViewState();
}

class _ApplyLeaveViewState extends State<_ApplyLeaveView> {
  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;

  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Apply for Leave',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<LeaveBloc, LeaveState>(
        listener: (context, state) {
          if (state is LeaveActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }

          if (state is LeaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LeaveTypesLoading || state is LeaveInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LeaveTypesLoaded) {
            return _buildForm(state.leaveTypes);
          }

          return const Center(child: Text("Failed to load leave types"));
        },
      ),
    );
  }

  Widget _buildForm(List<LeaveType> types) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// Leave Type
              _buildSectionCard(
                icon: Icons.category_outlined,
                iconColor: Colors.purple,
                title: 'Leave Type',
                child: DropdownButtonFormField<LeaveType>(
                  value: _selectedLeaveType,
                  decoration: _inputDecoration('Select leave type'),
                  items: types
                      .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.name),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedLeaveType = v),
                  validator: (v) =>
                  v == null ? 'Please select leave type' : null,
                ),
              ),

              const SizedBox(height: 16),

              /// Dates
              _buildSectionCard(
                icon: Icons.calendar_today,
                iconColor: Colors.green,
                title: 'Duration',
                child: Row(
                  children: [
                    Expanded(
                      child: _datePicker(
                        'Start Date',
                        _startDate,
                            (d) => setState(() => _startDate = d),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _datePicker(
                        'End Date',
                        _endDate,
                            (d) => setState(() => _endDate = d),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// Reason
              _buildSectionCard(
                icon: Icons.edit_note,
                iconColor: Colors.orange,
                title: 'Reason',
                child: TextFormField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: _inputDecoration('Enter reason for leave'),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter reason' : null,
                ),
              ),

              const SizedBox(height: 16),

              /// Approver (automatic)
              _buildSectionCard(
                icon: Icons.person,
                iconColor: Colors.blue,
                title: 'Approver',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        "Automatically assigned to Admin",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _canSubmit() ? _submit : null,
                  child: const Text("Submit Leave Request"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool _canSubmit() {
    return _selectedLeaveType != null &&
        _startDate != null &&
        _endDate != null &&
        _reasonController.text.isNotEmpty;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
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

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Text(
                title,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _datePicker(String label, DateTime? value, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (d != null) onPick(d);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 5),
            Text(
              value == null
                  ? "Select date"
                  : "${value.day}/${value.month}/${value.year}",
            )
          ],
        ),
      ),
    );
  }
}