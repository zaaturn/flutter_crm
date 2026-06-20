import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/admin_dashboard/model/user.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_search_desktop.dart';
import 'package:my_app/tasks/models/crm_task.dart';
import 'package:my_app/tasks/services/crm_task_api_service.dart';

class TaskEditScreen extends StatefulWidget {
  final int taskId;

  const TaskEditScreen({super.key, required this.taskId});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  // Dashboard purple palette (matches sidebar + task tracker).
  static const _purple = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _purpleDark = Color(0xFF4C1D95);
  static const _borderPurple = Color(0xFFEDE9FE);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _labelMuted = Color(0xFF94A3B8);
  static const _fieldBg = Color(0xFFF8FAFC);
  static const _border = Color(0xFFE2E8F0);

  final _api = CrmTaskApiService();
  final _repo = AdminRepository();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _assigneeCtrl = TextEditingController();

  List<User> _users = [];
  User? _assignee;
  DateTime? _dueDate;
  String _priority = 'MEDIUM';
  PlatformFile? _attachment;
  bool _loading = true;
  bool _saving = false;

  static const _priorities = ['HIGH', 'MEDIUM', 'LOW'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _assigneeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _api.getTask(widget.taskId),
        _repo.fetchEmployees(),
      ]);
      final task = results[0] as CrmTask;
      final users = results[1] as List<User>;
      if (task.isApproved) {
        if (!mounted) return;
        _showSnack('Approved tasks cannot be edited', isError: true);
        Navigator.of(context).pop(false);
        return;
      }
      User? assignee;
      if (task.assignedTo != null) {
        for (final u in users) {
          if (u.id == task.assignedTo) {
            assignee = u;
            break;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _users = users;
        _assignee = assignee;
        _title.text = task.title;
        _description.text = task.description;
        _priority = task.priority;
        if (assignee != null) {
          _assigneeCtrl.text = assignee.assignmentLabel;
        }
        if (task.dueDate != null && task.dueDate!.isNotEmpty) {
          _dueDate = DateTime.tryParse(task.dueDate!);
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Failed to load task: $e', isError: true);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _purple,
              onPrimary: Colors.white,
              onSurface: _textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _attachment = result.files.first);
    }
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _dueDate == null || _assignee == null) {
      _showSnack('Title, due date and assignee are required', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await _api.updateTask(
        widget.taskId,
        {
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'due_date': DateFormat('yyyy-MM-dd').format(_dueDate!),
          'priority': _priority,
          'assigned_to': _assignee!.id,
        },
        attachment: _attachment,
      );
      if (!mounted) return;
      _showSnack('Task updated successfully');
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Update failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purpleLight,
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : LayoutBuilder(
              builder: (context, constraints) {
                double horizontalPadding = 24;
                if (constraints.maxWidth > 1400) {
                  horizontalPadding = (constraints.maxWidth - 1200) / 2;
                } else if (constraints.maxWidth > 1000) {
                  horizontalPadding = 40;
                }

                final isWide = constraints.maxWidth > 950;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 32,
                  ),
                  child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
                );
              },
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: const BackButton(color: _textPrimary),
      title: Text(
        'Edit Task',
        style: GoogleFonts.plusJakartaSans(
          color: _textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _borderPurple, height: 1),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _sectionCard(
                title: 'Task information',
                icon: Icons.assignment_outlined,
                children: [
                  _label('Task title'),
                  _inputField(
                    controller: _title,
                    hint: 'Enter a descriptive title for the task...',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 24),
                  _label('Instructions & description'),
                  _inputField(
                    controller: _description,
                    hint: 'Provide step-by-step instructions or project context...',
                    maxLines: 12,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionCard(
                title: 'Files & resources',
                icon: Icons.attach_file_rounded,
                children: [_fileAttachment()],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _sectionCard(
            title: 'Configuration',
            icon: Icons.tune_rounded,
            children: [
              _label('Assigned to'),
              EmployeeSearchField(
                users: _users,
                controller: _assigneeCtrl,
                onSelected: (u) => setState(() => _assignee = u),
              ),
              const SizedBox(height: 24),
              _label('Target date'),
              _dateSelector(),
              const SizedBox(height: 24),
              _label('Urgency level'),
              _priorityDropdown(),
              const SizedBox(height: 40),
              _submitButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _sectionCard(
          title: 'Core details',
          icon: Icons.edit_note_rounded,
          children: [
            _label('Task title'),
            _inputField(controller: _title, hint: 'Task name'),
            const SizedBox(height: 20),
            _label('Assignee'),
            EmployeeSearchField(
              users: _users,
              controller: _assigneeCtrl,
              onSelected: (u) => setState(() => _assignee = u),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sectionCard(
          title: 'Schedule & priority',
          icon: Icons.calendar_month_rounded,
          children: [
            _dateSelector(),
            const SizedBox(height: 16),
            _priorityDropdown(),
          ],
        ),
        const SizedBox(height: 20),
        _sectionCard(
          title: 'Documentation',
          icon: Icons.description_outlined,
          children: [
            _inputField(
              controller: _description,
              hint: 'Detailed description...',
              maxLines: 6,
            ),
            const SizedBox(height: 20),
            _fileAttachment(),
          ],
        ),
        const SizedBox(height: 32),
        _submitButton(),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderPurple),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderPurple),
                ),
                child: Icon(icon, size: 18, color: _purple),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: _labelMuted,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: _textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: _textMuted)
              : null,
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: _labelMuted),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _dateSelector() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, size: 18, color: _purple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dueDate == null
                    ? 'Set due date'
                    : DateFormat('EEE, MMM dd, yyyy').format(_dueDate!),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: _dueDate == null ? _labelMuted : _textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _priorityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _priorities.contains(_priority) ? _priority : 'MEDIUM',
          isExpanded: true,
          icon: const Icon(Icons.unfold_more_rounded, size: 20, color: _textMuted),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
          items: _priorities.map((p) {
            final color = switch (p) {
              'HIGH' => const Color(0xFFEF4444),
              'LOW' => const Color(0xFF10B981),
              _ => _purple,
            };
            return DropdownMenuItem(
              value: p,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                  const SizedBox(width: 12),
                  Text(p[0] + p.substring(1).toLowerCase()),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _priority = v);
          },
        ),
      ),
    );
  }

  Widget _fileAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_attachment != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderPurple),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_rounded, color: _purple, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _attachment!.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: _purpleDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _attachment = null),
                  icon: const Icon(Icons.cancel_rounded, color: _purple, size: 20),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.file_upload_outlined, color: _purple),
          label: Text(
            'Attach project documentation',
            style: GoogleFonts.plusJakartaSans(
              color: _purple,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            side: const BorderSide(color: _borderPurple),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _purple.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _saving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Save changes',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
