import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/admin_dashboard/model/user.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';

class AssignTaskScreenMobile extends StatefulWidget {
  const AssignTaskScreenMobile({super.key});

  @override
  State<AssignTaskScreenMobile> createState() => _AssignTaskScreenMobileState();
}

class _AssignTaskScreenMobileState extends State<AssignTaskScreenMobile> {
  // Dependencies
  final AdminRepository _repository = AdminRepository();

  // State
  List<User> users = [];
  User? selectedUser;
  bool submitting = false;

  // SaaS Design Tokens
  static const primaryColor = Color(0xFF6366F1);
  static const successColor = Color(0xFF10B981);
  static const surfaceColor = Colors.white;
  static const scaffoldBg = Color(0xFFF8FAFC);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);

  String priority = "Medium";
  DateTime? dueDate;
  String? attachedFileName;
  File? attachedFile;

  final TextEditingController taskController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await _repository.fetchEmployees();
      if (mounted) setState(() => users = data);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Error loading users: ${e.toString()}");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: _buildModernAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Who's responsible?"),
              _buildAssigneePicker(),
              const SizedBox(height: 24),

              _buildSectionHeader("Task Details"),
              _buildModernTextField(
                controller: taskController,
                hint: "What needs to be done?",
                icon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 16),

              _buildModernTextField(
                controller: descriptionController,
                hint: "Add more context or instructions...",
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildDatePicker()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPriorityPicker()),
                ],
              ),
              const SizedBox(height: 24),

              _buildAttachmentSection(),
              const SizedBox(height: 40),

              _buildGradientSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        "Create New Task",
        style: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: textSecondary,
        ),
      ),
    );
  }

  Widget _buildAssigneePicker() {
    return Container(
      decoration: _cardDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0E7FF),
          child: selectedUser == null
              ? const Icon(Icons.person_outline_rounded, color: primaryColor)
              : Text(selectedUser!.displayName[0].toUpperCase(), style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ),
        title: Text(
            selectedUser?.displayName ?? "Assignee",
            style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: selectedUser == null ? textSecondary : textPrimary)
        ),
        subtitle: Text(
            selectedUser?.username != null ? "@${selectedUser!.username}" : "Search or select member",
            style: const TextStyle(color: textSecondary, fontSize: 13)
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: textSecondary),
        onTap: _showEmployeeSearch,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: textSecondary, size: 20) : null,
          hintStyle: const TextStyle(color: textSecondary, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: primaryColor),
            const SizedBox(height: 8),
            Text(
              dueDate == null ? "Set Due Date" : DateFormat("MMM dd, yyyy").format(dueDate!),
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _cardDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: priority,
          icon: const Icon(Icons.expand_more_rounded, color: textSecondary),
          isExpanded: true,
          items: ["Low", "Medium", "High"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            );
          }).toList(),
          onChanged: (v) => setState(() => priority = v!),
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined, color: primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              attachedFileName ?? "Drop files here or browse",
              style: GoogleFonts.inter(color: textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryColor, Color(0xFF4F46E5)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: submitting ? null : _submitTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: submitting
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
          "Create Task",
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date != null) setState(() => dueDate = date);
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

  void _showEmployeeSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return EmployeeSearchSheet(
              scrollController: controller,
              users: users,
              onSelect: (user) {
                setState(() => selectedUser = user);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _submitTask() async {
    if (selectedUser == null || taskController.text.isEmpty || dueDate == null) {
      _showErrorSnackBar("Please fill all required fields (Assignee, Title, and Date)");
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
        // Success Notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text("Task assigned successfully!", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => submitting = false);
        _showErrorSnackBar("Error: ${e.toString()}");
      }
    }
  }
}

class EmployeeSearchSheet extends StatefulWidget {
  final ScrollController scrollController;
  final List<User> users;
  final ValueChanged<User> onSelect;

  const EmployeeSearchSheet({
    super.key,
    required this.scrollController,
    required this.users,
    required this.onSelect,
  });

  @override
  State<EmployeeSearchSheet> createState() => _EmployeeSearchSheetState();
}

class _EmployeeSearchSheetState extends State<EmployeeSearchSheet> {
  String searchQuery = '';
  late List<User> filteredUsers;

  @override
  void initState() {
    super.initState();
    filteredUsers = widget.users;
  }

  void _filterUsers(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      filteredUsers = widget.users.where((user) {
        return user.displayName.toLowerCase().contains(lowerCaseQuery) ||
            user.username.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: "Search team members...",
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text("No members found", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Text(user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                  ),
                  title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text("@${user.username}", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  onTap: () => widget.onSelect(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}