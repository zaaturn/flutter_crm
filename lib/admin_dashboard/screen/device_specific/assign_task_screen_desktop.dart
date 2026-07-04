import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import 'package:my_app/admin_dashboard/repository/admin_repository.dart';
import 'package:my_app/admin_dashboard/model/user.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_search_desktop.dart';

class AssignTaskScreenDesktop extends StatefulWidget {
  const AssignTaskScreenDesktop({super.key});

  @override
  State<AssignTaskScreenDesktop> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreenDesktop> {
  final AdminRepository _repository = AdminRepository();

  List<User> users = [];
  User? selectedUser;

  DateTime? dueDate;
  String priority = "Medium";
  File? attachedFile;
  String? attachedFileName;

  final TextEditingController assignToController = TextEditingController();
  final TextEditingController taskController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await _repository.fetchEmployees();
    if (!mounted) return;
    setState(() => users = data);
  }

  @override
  void dispose() {
    assignToController.dispose();
    taskController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDashboardTheme.shellMint,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding = AdminDashboardTheme.shellPadding;
          if (constraints.maxWidth > 1400) {
            horizontalPadding = (constraints.maxWidth - 1200) / 2;
          } else if (constraints.maxWidth > 1000) {
            horizontalPadding = 40.0;
          }

          bool isWide = constraints.maxWidth > 950;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
            child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AdminDashboardTheme.shellMint,
      elevation: 0,
      centerTitle: false,
      leading: const BackButton(color: AdminDashboardTheme.textDark),
      title: const Text(
        "Assign New Task",
        style: TextStyle(
          color: AdminDashboardTheme.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton.icon(
            onPressed: _resetForm,
            icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.redAccent),
            label: const Text("Reset Form", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
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
              _buildSectionCard(
                title: "Task Information",
                children: [
                  _label("Task Title"),
                  _inputField(
                    controller: taskController,
                    hint: "Enter a descriptive title for the task...",
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 24),
                  _label("Instructions & Description"),
                  _inputField(
                    controller: descriptionController,
                    hint: "Provide step-by-step instructions or project context...",
                    maxLines: 12,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: "Files & Resources",
                children: [_buildFileAttachment()],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSectionCard(
                title: "Configuration",
                children: [
                  _label("Assigned To"),
                  EmployeeSearchField(
                    users: users,
                    controller: assignToController,
                    onSelected: (u) => selectedUser = u,
                  ),
                  const SizedBox(height: 24),
                  _label("Target Date"),
                  _buildDateSelector(),
                  const SizedBox(height: 24),
                  _label("Urgency Level"),
                  _buildPriorityDropdown(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildSectionCard(
          title: "Core Details",
          children: [
            _label("Task Title"),
            _inputField(controller: taskController, hint: "Task Name"),
            const SizedBox(height: 24),
            _label("Assignee"),
            EmployeeSearchField(users: users, controller: assignToController, onSelected: (u) => selectedUser = u),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: "Schedule & Priority",
          children: [
            Row(
              children: [
                Expanded(child: _buildDateSelector()),
                const SizedBox(width: 12),
                Expanded(child: _buildPriorityDropdown()),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: "Documentation",
          children: [
            _inputField(controller: descriptionController, hint: "Detailed description...", maxLines: 6),
            const SizedBox(height: 20),
            _buildFileAttachment(),
          ],
        ),
        const SizedBox(height: 32),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return AdminDashboardPanel(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdminDashboardTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AdminDashboardTheme.textMuted,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _inputField({required TextEditingController controller, required String hint, int maxLines = 1, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: AdminDashboardTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminDashboardTheme.border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, color: AdminDashboardTheme.textDark),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, size: 20, color: AdminDashboardTheme.textMuted) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: AdminDashboardTheme.iconInactive),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AdminDashboardTheme.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminDashboardTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, size: 18, color: AdminDashboardTheme.teal),
            const SizedBox(width: 12),
            Text(
              dueDate == null ? "Set Due Date" : DateFormat("EEE, MMM dd, yyyy").format(dueDate!),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: dueDate == null ? AdminDashboardTheme.iconInactive : AdminDashboardTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AdminDashboardTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminDashboardTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: priority,
          isExpanded: true,
          icon: const Icon(Icons.unfold_more_rounded, size: 20, color: AdminDashboardTheme.textMuted),
          items: ["Low", "Medium", "High"].map((p) {
            final color = p == "High" ? Colors.red : (p == "Medium" ? Colors.orange : Colors.green);
            return DropdownMenuItem(
              value: p,
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                  const SizedBox(width: 12),
                  Text(p, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => priority = v!),
        ),
      ),
    );
  }

  Widget _buildFileAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (attachedFile != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_rounded, color: Color(0xFF0369A1), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(attachedFileName ?? "File", style: const TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  onPressed: () => setState(() => attachedFile = null),
                  icon: const Icon(Icons.cancel_rounded, color: Color(0xFF0369A1), size: 20),
                )
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.file_upload_outlined),
          label: const Text("Attach Project Documentation"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: submitting ? null : _submitTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminDashboardTheme.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: submitting
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Create & Assign Task", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _resetForm() {
    assignToController.clear();
    taskController.clear();
    descriptionController.clear();
    setState(() {
      selectedUser = null;
      dueDate = null;
      priority = "Medium";
      attachedFile = null;
      attachedFileName = null;
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: dueDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminDashboardTheme.teal,
              onPrimary: Colors.white,
              onSurface: AdminDashboardTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null && mounted) setState(() => dueDate = date);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        attachedFile = File(result.files.single.path!);
        attachedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submitTask() async {
    if (selectedUser == null || taskController.text.isEmpty || dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => submitting = true);

    try {
      await _repository.createTask(
        assignedTo: selectedUser!.id,
        title: taskController.text.trim(),
        description: descriptionController.text.trim(),
        priority: priority,
        dueDate: DateFormat("yyyy-MM-dd").format(dueDate!),
      );

      if (mounted) {
        // --- THE SUCCESS SNACKBAR ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text("Task assigned to ${selectedUser!.username} successfully!"),
              ],
            ),
            backgroundColor: const Color(0xFF10B981), // Modern Emerald Green
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            duration: const Duration(seconds: 3),
          ),
        );

        // Return true so the calling screen knows it was successful
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}