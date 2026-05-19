import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/main.dart' show navigatorKey;
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
  static const Color _bg = Color(0xFFFAF3E0);
  static const Color _card = Color(0xFFEADBC8);
  static const Color _terracotta = Color(0xFFC05E41);
  static const Color _terracottaDark = Color(0xFF8E3F2A);
  static const Color _textDark = Color(0xFF3E2723);
  static const Color _textMuted = Color(0xFF8D6E63);

  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;

  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<LeaveType> _typesCache = const [];
  bool _handledSuccess = false;

  @override
  void initState() {
    super.initState();
    // Ensure submit button enables/disables as user types.
    _reasonController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        foregroundColor: _textDark,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Apply for Leave',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<LeaveBloc, LeaveState>(
        listenWhen: (prev, curr) =>
            curr is LeaveActionSuccess || curr is LeaveError,
        listener: (context, state) {
          if (state is LeaveActionSuccess) {
            _handledSuccess = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Root [Navigator] via [navigatorKey]; avoid context from this route on web.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              final rootCtx = navigatorKey.currentContext ?? context;
              EmployeeDashboardNavigator.dashboard(rootCtx);
            });
          }

          if (state is LeaveError) {
            // After submit success, ignore unrelated follow-up errors.
            if (_handledSuccess) return;
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
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: _terracotta,
              ),
            );
          }

          if (state is LeaveTypesLoaded) {
            _typesCache = state.leaveTypes;
            return _buildForm(state.leaveTypes);
          }

          // Keep showing the form during submit / success, and avoid confusing fallback.
          if ((state is LeaveSubmitting || state is LeaveActionSuccess) &&
              _typesCache.isNotEmpty) {
            return _buildForm(_typesCache);
          }
          if (state is LeaveError && _typesCache.isNotEmpty) {
            return _buildForm(_typesCache);
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
                iconColor: _terracotta,
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
                iconColor: _terracotta,
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
                iconColor: _terracotta,
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
                iconColor: _terracotta,
                title: 'Approver',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user, color: _terracotta),
                      SizedBox(width: 10),
                      Text(
                        "Automatically assigned to Admin",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _terracotta,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _terracotta.withValues(alpha: 0.30),
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.75),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Submit Leave Request",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
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
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _terracotta.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style:
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                ),
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
      hintStyle: const TextStyle(color: _textMuted, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.55),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _terracotta.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _terracotta.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _terracotta.withValues(alpha: 0.35), width: 1.5),
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
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: _terracotta,
                    onPrimary: Colors.white,
                    surface: _bg,
                    onSurface: _textDark,
                  ),
            ),
            child: child!,
          ),
        );
        if (d != null) onPick(d);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.55),
          border: Border.all(color: _terracotta.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: _textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value == null
                  ? "Select date"
                  : "${value.day}/${value.month}/${value.year}",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            )
          ],
        ),
      ),
    );
  }
}