import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/model/task.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/mainscreen_taskcard.dart';

class DesktopTaskSectionModern extends StatefulWidget {
  final List<Task> tasks;
  final VoidCallback? onViewAll;
  final Function(Task)? onTaskTap;

  const DesktopTaskSectionModern({
    super.key,
    required this.tasks,
    this.onViewAll,
    this.onTaskTap,
  });

  @override
  State<DesktopTaskSectionModern> createState() =>
      _DesktopTaskSectionModernState();
}

class _DesktopTaskSectionModernState extends State<DesktopTaskSectionModern> {
  final ScrollController _scrollController = ScrollController();
  late List<Task> _localTasks;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _localTasks = List.from(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant DesktopTaskSectionModern oldWidget) {
    super.didUpdateWidget(oldWidget);
    _localTasks = List.from(widget.tasks);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Task> get _filteredTasks {
    if (_selectedFilter == 'all') return _localTasks;
    return _localTasks
        .where((task) => task.status.trim().toLowerCase() == _selectedFilter)
        .toList();
  }

  int _getCountForFilter(String filter) {
    if (filter == 'all') return _localTasks.length;
    return _localTasks
        .where((t) => t.status.trim().toLowerCase() == filter)
        .length;
  }

  // ── ARCHIVE DOUBLE CONFIRMATION DIALOG ──
  void _showArchiveConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.archive_outlined, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Text("Archive Task?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to approve and archive \"${task.title}\"?"),
            const SizedBox(height: 12),
            const Text(
              "This action is permanent and will remove the task from the active workspace for all users.",
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              // 1. Dispatch BLoC event to archive on Backend
              context.read<AdminDashboardBloc>().add(ApproveTaskRequested(taskId: task.id));

              // 2. Optimistic UI update (remove locally immediately)
              setState(() {
                _localTasks.removeWhere((t) => t.id == task.id);
              });

              Navigator.pop(ctx);
            },
            child: const Text("Confirm & Archive", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredTasks = _filteredTasks;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isDark),
          Divider(
              height: 1,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE8E8ED)),
          const SizedBox(height: 20),
          _buildFilterTabs(isDark),
          const SizedBox(height: 20),
          _buildTaskList(filteredTasks, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D3199), Color(0xFF1E40AF)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Projects & Tasks',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                Text('${_localTasks.length} total tasks',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8B8B9A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterTab('all', 'All Tasks', isDark),
          const SizedBox(width: 8),
          _buildFilterTab('pending', 'Pending', isDark),
          const SizedBox(width: 8),
          _buildFilterTab('in_progress', 'In Progress', isDark),
          const SizedBox(width: 8),
          _buildFilterTab('completed', 'Completed', isDark),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter, String label, bool isDark) {
    final isSelected = _selectedFilter == filter;
    final count = _getCountForFilter(filter);

    return InkWell(
      onTap: () => setState(() => _selectedFilter = filter),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF3B4DE0) : const Color(0xFFEEF0FF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF3B4DE0))
                        : const Color(0xFF6B6B7B))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white24 : const Color(0xFF3B4DE0))
                    : const Color(0xFFE8E8ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> filteredTasks, bool isDark) {
    if (filteredTasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(60),
        child: Center(child: Text('No tasks found in this category')),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 480),
        child: ListView.separated(
          controller: _scrollController,
          itemCount: filteredTasks.length,
          shrinkWrap: true,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            final bool isCompleted = task.status.trim().toLowerCase() == 'completed';

            return ModernTaskCard(
              task: task,
              isDark: isDark,
              onTap: widget.onTaskTap,
              onDelete: (taskToArchive) {
                if (isCompleted) {
                  _showArchiveConfirmation(context, taskToArchive);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Only completed tasks can be archived and approved."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}