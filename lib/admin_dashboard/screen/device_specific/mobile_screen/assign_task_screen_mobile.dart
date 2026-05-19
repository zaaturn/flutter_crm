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
  final AdminRepository _repository = AdminRepository();

  List<User> users = [];
  User? selectedUser;
  bool submitting = false;

  // Updated Theme Tokens
  static const terracotta = Color(0xFFB35A38);
  static const darkSlate = Color(0xFF0F172A);
  static const lightCream = Color(0xFFFAF9F6);
  static const midCream = Color(0xFFEBDDCF); // Slightly darker for card depth

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
      if (mounted) _showErrorSnackBar("Error loading users: ${e.toString()}");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: darkSlate,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightCream,
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
            _buildTerracottaButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: lightCream,
      elevation: 0,
      scrolledUnderElevation: 0, // Prevents white color change on scroll
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: darkSlate),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Create New Task",
        style: GoogleFonts.manrope(
          color: darkSlate,
          fontWeight: FontWeight.w900,
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
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: terracotta,
        ),
      ),
    );
  }

  Widget _buildAssigneePicker() {
    return Container(
      decoration: _cardDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: terracotta.withOpacity(0.1),
          child: selectedUser == null
              ? const Icon(Icons.person_add_alt_1_rounded, color: terracotta)
              : Text(selectedUser!.displayName[0].toUpperCase(),
              style: const TextStyle(color: terracotta, fontWeight: FontWeight.w900)),
        ),
        title: Text(
            selectedUser?.assignmentLabel ?? "Assignee",
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: darkSlate)
        ),
        subtitle: Text(
            selectedUser?.username != null ? "@${selectedUser!.username}" : "Search member",
            style: GoogleFonts.manrope(color: darkSlate.withOpacity(0.5), fontSize: 12)
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: terracotta),
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
        style: GoogleFonts.manrope(color: darkSlate, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: terracotta, size: 22) : null,
          hintStyle: GoogleFonts.manrope(color: darkSlate.withOpacity(0.3), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
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
            const Icon(Icons.calendar_month_rounded, size: 20, color: terracotta),
            const SizedBox(height: 8),
            Text(
              dueDate == null ? "Due Date" : DateFormat("MMM dd").format(dueDate!),
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 14, color: darkSlate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: _cardDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: priority,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: terracotta),
          isExpanded: true,
          dropdownColor: midCream,
          items: ["Low", "Medium", "High"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 14, color: darkSlate)),
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
          color: midCream.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: terracotta.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(Icons.attachment_rounded, color: terracotta, size: 28),
            const SizedBox(height: 8),
            Text(
              attachedFileName ?? "Attach Files",
              style: GoogleFonts.manrope(color: terracotta, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerracottaButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: submitting ? null : _submitTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: terracotta,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: submitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          "CREATE TASK",
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: midCream, // Updated to match your tile theme
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: darkSlate.withOpacity(0.1), width: 1.5),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: terracotta, onPrimary: Colors.white, surface: lightCream),
          ),
          child: child!,
        );
      },
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
          initialChildSize: 0.7,
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
      _showErrorSnackBar("Please complete all required fields");
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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => submitting = false);
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
  static const _bg = Color(0xFFFAF9F6);
  static const _terracotta = Color(0xFFB35A38);
  static const _dark = Color(0xFF0F172A);
  static const _card = Color(0xFFEBDDCF);

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matches(User u, String q) {
    if (q.isEmpty) return true;
    final t = q.toLowerCase();
    final a = u.assignmentLabel.toLowerCase();
    final d = u.displayName.toLowerCase();
    final un = u.username.toLowerCase();
    return a.contains(t) || d.contains(t) || un.contains(t);
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.users.where((u) => _matches(u, _query)).toList(growable: false);

    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _dark.withValues(alpha: 0.08)),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim()),
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: _terracotta),
                  hintText: 'Search staff name / username',
                  hintStyle: GoogleFonts.manrope(
                    color: _dark.withValues(alpha: 0.35),
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No results',
                      style: GoogleFonts.manrope(
                        color: _dark.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: widget.scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      final initial = user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _terracotta.withValues(alpha: 0.10),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: _terracotta,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        title: Text(
                          user.assignmentLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                        ),
                        subtitle: user.username.isNotEmpty
                            ? Text(
                                '@${user.username}',
                                style: GoogleFonts.manrope(
                                  color: _dark.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
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