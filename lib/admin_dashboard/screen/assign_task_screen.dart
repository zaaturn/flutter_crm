import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../repository/admin_repository.dart';
import '../model/user.dart';
import '../../admin_dashboard/widget/employee_search_field.dart';
import '../../admin_dashboard/widget/section_card.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final AdminRepository _repository = AdminRepository();

  List<User> users = [];
  User? selectedUser;

  DateTime? dueDate;
  String priority = "Medium";
  File? attachedFile;

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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Assign Task",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: const Text("Reset"),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Assign To"),
                    SectionCard(
                      child: EmployeeSearchField(
                        users: users,
                        controller: assignToController,
                        onSelected: (u) => selectedUser = u,
                      ),
                    ),

                    _label("Task Name"),
                    SectionCard(
                      child: TextField(
                        controller: taskController,
                        decoration: const InputDecoration(
                          hintText: "e.g. Update Landing Page Copy",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Due Date"),
                              SectionCard(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: _pickDate,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            dueDate == null
                                                ? "Select date"
                                                : DateFormat("dd/MM/yyyy")
                                                .format(dueDate!),
                                            style: TextStyle(
                                              color: dueDate == null
                                                  ? Colors.black38
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                            Icons.keyboard_arrow_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Priority"),
                              SectionCard(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: priority,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                          value: "Low", child: Text("Low")),
                                      DropdownMenuItem(
                                          value: "Medium",
                                          child: Text("Medium")),
                                      DropdownMenuItem(
                                          value: "High", child: Text("High")),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => priority = v!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    _label("Description"),
                    SectionCard(
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                          "Enter detailed instructions for the task...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    TextButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text("Attach Files"),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitting ? null : _submitTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF18A0FB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Assign Task",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
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
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date != null && mounted) {
      setState(() => dueDate = date);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      attachedFile = File(result.files.single.path!);
    }
  }

  Future<void> _submitTask() async {
    if (selectedUser == null ||
        taskController.text.isEmpty ||
        dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => submitting = true);

    await _repository.createTask(
      assignedTo: selectedUser!.id,
      title: taskController.text.trim(),
      description: descriptionController.text.trim(),
      priority: priority,
      dueDate: DateFormat("yyyy-MM-dd").format(dueDate!),
    );

    if (mounted) Navigator.pop(context);
  }
}








