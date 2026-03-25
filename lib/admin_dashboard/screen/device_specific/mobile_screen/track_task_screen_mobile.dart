import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure this is in pubspec.yaml

import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';
import 'package:my_app/admin_dashboard/model/task.dart';

class SaasTheme {
  static const primary = Color(0xFF4F46E5); // Modern Indigo
  static const surface = Colors.white;
  static const background = Color(0xFFF9FAFB);
  static const border = Color(0xFFF1F5F9);

  static const textMain = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
}

class TaskTrackerScreenMobile extends StatelessWidget {
  const TaskTrackerScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardBloc(
        repository: AdminRepository(),
      )..add(const AdminDashboardStarted()),
      child: const _TaskTrackerView(),
    );
  }
}

class _TaskTrackerView extends StatefulWidget {
  const _TaskTrackerView();

  @override
  State<_TaskTrackerView> createState() => _TaskTrackerViewState();
}

class _TaskTrackerViewState extends State<_TaskTrackerView> {
  String selectedStatus = 'pending';
  String searchQuery = '';

  void _handleApprove(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            const Text("Confirm Approval", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("By approving \"${task.title}\", it will be marked as finalized and moved from the active tracker.",
                textAlign: TextAlign.center, style: TextStyle(color: SaasTheme.textMuted)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AdminDashboardBloc>().add(ApproveTaskRequested(taskId: task.id));
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SaasTheme.success,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Approve Now", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaasTheme.background,
      appBar: AppBar(
        backgroundColor: SaasTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SaasTheme.textMain, size: 20),
          // MODIFIED: Navigate back to Project Options
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Task Tracker",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: SaasTheme.textMain)),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminDashboardBloc>().add(const AdminTasksRefreshed()),
            icon: const Icon(Icons.refresh_rounded, color: SaasTheme.textMuted),
          )
        ],
      ),
      body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());

          final filteredTasks = state.tasks.where((t) {
            final matchesStatus = t.status.toLowerCase() == selectedStatus;
            return matchesStatus && t.title.toLowerCase().contains(searchQuery);
          }).toList();

          return Column(
            children: [
              Container(
                color: SaasTheme.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    _SaaSSearchBar(onChanged: (v) => setState(() => searchQuery = v.toLowerCase())),
                    const SizedBox(height: 16),
                    _SaaSStatusTabs(
                      selected: selectedStatus,
                      onChanged: (s) => setState(() => selectedStatus = s),
                    ),
                  ],
                ),
              ),


              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(child: Text("No tasks found", style: GoogleFonts.inter(color: SaasTheme.textMuted)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) => _TaskListItem(
                    task: filteredTasks[index],
                    onApprove: filteredTasks[index].status == 'completed'
                        ? () => _handleApprove(context, filteredTasks[index])
                        : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SaaSSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SaaSSearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: "Search tasks...",
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: SaasTheme.textMuted),
        filled: true,
        fillColor: SaasTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }
}

class _SaaSStatusTabs extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const _SaaSStatusTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab("Pending", 'pending'),
        const SizedBox(width: 8),
        _buildTab("In Progress", 'in_progress'),
        const SizedBox(width: 8),
        _buildTab("Completed", 'completed'),
      ],
    );
  }

  Widget _buildTab(String label, String key) {
    bool isActive = selected == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? SaasTheme.primary : SaasTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? SaasTheme.primary : SaasTheme.border),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : SaasTheme.textMuted
              )),
        ),
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onApprove;

  const _TaskListItem({required this.task, this.onApprove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SaasTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SaasTheme.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: SaasTheme.background, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.assignment_rounded, color: SaasTheme.primary, size: 20),
          ),
          title: Text(task.title,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: SaasTheme.textMain)),
          subtitle: Text("Assigned to ${task.assignedToName}",
              style: GoogleFonts.inter(fontSize: 12, color: SaasTheme.textMuted)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: SaasTheme.border),
                  const SizedBox(height: 12),
                  Text("Description", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(task.description, style: GoogleFonts.inter(color: SaasTheme.textMuted, height: 1.5)),
                  if (onApprove != null) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text("Approve & Close Task"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SaasTheme.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    )
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}