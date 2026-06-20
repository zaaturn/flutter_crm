import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';
import 'package:my_app/admin_dashboard/model/task.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/task_card_desktop.dart';
import 'package:my_app/tasks/task_dashboard_navigation.dart';

class TaskTrackerScreenDesktop extends StatelessWidget {
  const TaskTrackerScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<AdminDashboardBloc>();
      return const _TaskTrackerView();
    } catch (_) {
      return BlocProvider(
        create: (_) => AdminDashboardBloc(
          repository: AdminRepository(),
        )..add(const AdminDashboardStarted()),
        child: const _TaskTrackerView(),
      );
    }
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

  void _confirmApproval(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Archive Task?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to approve \"${task.title}\"? It will be removed from the active workspace."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<AdminDashboardBloc>().add(ApproveTaskRequested(taskId: task.id));
              Navigator.pop(ctx);
            },
            child: const Text("Approve & Archive", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openTaskDetail(BuildContext context, int taskId) {
    openTaskDetailForDashboard(
      context,
      taskId: taskId,
      onUpdated: (updated) => applyTaskEditToDashboard(context, updated),
    );
  }

  void _openTaskEdit(BuildContext context, int taskId) {
    openTaskEditForDashboard(context, taskId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildEnterpriseAppBar(context),
      body: BlocListener<AdminDashboardBloc, AdminDashboardState>(
        listenWhen: (prev, curr) => curr.successMessage != null || curr.error != null,
        listener: (context, state) {
          if (state.successMessage != null) {
            _showSnackBar(context, state.successMessage!, const Color(0xFF10B981));
          }
          if (state.error != null) {
            _showSnackBar(context, state.error!, const Color(0xFFEF4444));
          }
        },
        child: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B4DE0)));
            }

            final List<Task> tasks = state.tasks;

            final filteredTasks = tasks.where((t) {
              final matchesStatus = t.status.trim().toLowerCase() == selectedStatus.toLowerCase();
              final query = searchQuery.toLowerCase();
              return matchesStatus &&
                  (query.isEmpty ||
                      t.title.toLowerCase().contains(query) ||
                      t.assignedToName.toLowerCase().contains(query));
            }).toList();

            return Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: _buildControlPanel(tasks),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: filteredTasks.isEmpty
                            ? _buildEmptyState()
                            : _buildTaskGrid(filteredTasks),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildEnterpriseAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        "Workspace / Management / Tasks",
        style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 20),
          onPressed: () => context.read<AdminDashboardBloc>().add(const AdminTasksRefreshed()),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildControlPanel(List<Task> tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Task Overview",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -1),
                  ),
                  Text("Monitor and manage team productivity", style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
              _TaskSearchBar(onChanged: (value) => setState(() => searchQuery = value)),
            ],
          ),
          const SizedBox(height: 32),
          _TaskStatusTabs(
            tasks: tasks,
            selectedStatus: selectedStatus,
            onChanged: (status) => setState(() => selectedStatus = status),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskGrid(List<Task> filteredTasks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return ModrenLevelTaskRow(
          task: task,
          onTap: () => _openTaskDetail(context, task.id),
          onEdit: () => _openTaskEdit(context, task.id),
          onDelete: () {},
          onApprove: () => _confirmApproval(context, task),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No tasks found in this category", style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _TaskSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _TaskSearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search tasks...",
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B4DE0), width: 1.5)),
        ),
      ),
    );
  }
}

class _TaskStatusTabs extends StatelessWidget {
  final List<Task> tasks;
  final String selectedStatus;
  final Function(String) onChanged;

  const _TaskStatusTabs({required this.tasks, required this.selectedStatus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusPill(
          label: "Pending",
          count: tasks.where((t) => t.status.toLowerCase() == 'pending').length,
          isActive: selectedStatus == 'pending',
          color: const Color(0xFFF59E0B),
          onTap: () => onChanged('pending'),
        ),
        const SizedBox(width: 12),
        _StatusPill(
          label: "In Progress",
          count: tasks.where((t) => t.status.toLowerCase() == 'in_progress').length,
          isActive: selectedStatus == 'in_progress',
          color: const Color(0xFF3B82F6),
          onTap: () => onChanged('in_progress'),
        ),
        const SizedBox(width: 12),
        _StatusPill(
          label: "Completed",
          count: tasks.where((t) => t.status.toLowerCase() == 'completed').length,
          isActive: selectedStatus == 'completed',
          color: const Color(0xFF10B981),
          onTap: () => onChanged('completed'),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _StatusPill({required this.label, required this.count, required this.isActive, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? color : const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: isActive ? color : const Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: isActive ? color : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
              child: Text(count.toString(), style: TextStyle(color: isActive ? Colors.white : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}