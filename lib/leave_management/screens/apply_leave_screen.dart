import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../block/leave_bloc.dart';
import '../block/leave_event.dart';
import '../block/leave_state.dart';
import '../models/leave_type.dart';
import '../models/approver.dart';
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
  Approver? _selectedApprover;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _approverController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LeaveApiService _api = LeaveApiService();

  @override
  void dispose() {
    _reasonController.dispose();
    _approverController.dispose();
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
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            );
            Navigator.pop(context);
          }
          if (state is LeaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            );
          }
        },
        builder: (context, state) {if (state is LeaveTypesLoading || state is LeaveInitial) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade600,
                    ),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading leave types...',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is LeaveTypesLoaded) {
            return _buildForm(state.leaveTypes);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Failed to load leave types',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(List<LeaveType> types) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leave Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Fill in the details below',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Form Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leave Type Card
                  _buildSectionCard(
                    icon: Icons.category_outlined,
                    iconColor: Colors.purple,
                    title: 'Leave Type',
                    child: DropdownButtonFormField<LeaveType>(
                      value: _selectedLeaveType,
                      decoration: _inputDecoration('Select leave type'),
                      dropdownColor: Colors.white,
                      items: types.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                      onChanged: (v) => setState(() => _selectedLeaveType = v),
                      validator: (v) => v == null ? 'Please select leave type' : null,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Duration Card
                  _buildSectionCard(
                    icon: Icons.calendar_today_outlined,
                    iconColor: Colors.green,
                    title: 'Duration',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _datePicker('Start Date', _startDate, (d) => setState(() => _startDate = d)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _datePicker('End Date', _endDate, (d) => setState(() => _endDate = d)),
                            ),
                          ],
                        ),
                        if (_startDate != null && _endDate != null && !_endDate!.isBefore(_startDate!))
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green.shade400, Colors.green.shade600],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.event_available, size: 20, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${_endDate!.difference(_startDate!).inDays + 1} day(s) leave',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reason Card
                  _buildSectionCard(
                    icon: Icons.edit_note,
                    iconColor: Colors.orange,
                    title: 'Reason',
                    child: TextFormField(
                      controller: _reasonController,
                      maxLines: 5,
                      decoration: _inputDecoration('Enter reason for leave').copyWith(
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please provide a reason' : null,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Approver Card
                  _buildSectionCard(
                    icon: Icons.person_search,
                    iconColor: Colors.blue,
                    title: 'Select Approver',
                    child: Column(
                      children: [
                        Autocomplete<Approver>(
                          displayStringForOption: (a) => a.name,
                          optionsBuilder: (TextEditingValue value) async {
                            if (value.text.trim().isEmpty) {
                              return const <Approver>[];
                            }
                            return await _api.searchAdmins(value.text);
                          },
                          onSelected: (Approver approver) {
                            setState(() {
                              _selectedApprover = approver;
                            });
                          },
                          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                            _approverController.text = controller.text;
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: _inputDecoration('Search by name or ID'),
                              validator: (_) => _selectedApprover == null ? 'Please select an approver' : null,
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  width: MediaQuery.of(context).size.width - 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder: (context, index) => Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Colors.grey.shade100,
                                    ),
                                    itemBuilder: (context, index) {
                                      final approver = options.elementAt(index);
                                      return InkWell(
                                        onTap: () => onSelected(approver),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    approver.name.isNotEmpty
                                                        ? approver.name[0].toUpperCase()
                                                        : 'A',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  approver.name,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF1a1a1a),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (_selectedApprover != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _selectedApprover!.name.isNotEmpty
                                            ? _selectedApprover!.name[0].toUpperCase()
                                            : 'A',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedApprover!.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1a1a1a),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Selected Approver',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      color: Colors.grey[600],
                                      onPressed: () {
                                        setState(() {
                                          _selectedApprover = null;
                                          _approverController.clear();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _canSubmit() ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Submit Leave Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  bool _canSubmit() =>
      _selectedLeaveType != null &&
          _startDate != null &&
          _endDate != null &&
          _selectedApprover != null &&
          _reasonController.text.isNotEmpty;

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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade600, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.blue.shade600,
                  onPrimary: Colors.white,
                  onSurface: Colors.grey.shade900,
                ),
              ),
              child: child!,
            );
          },
        );
        if (d != null) onPick(d);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null ? 'Select date' : '${value.day}/${value.month}/${value.year}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.blue.shade600),
              ],
            ),
          ],
        ),
      ),
    );
  }
}