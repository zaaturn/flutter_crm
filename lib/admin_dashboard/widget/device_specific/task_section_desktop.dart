import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late List<Task> _localTasks;
  String _selectedFilter = 'all';
  bool _isExpanded = true; // Controls the visibility of the list

  // --- Brand Colors ---
  static const _brandPurple = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _borderPurple = Color(0xFFDDD6FE);

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

  List<Task> get _filteredTasks {
    if (_selectedFilter == 'all') return _localTasks;
    return _localTasks
        .where((task) => task.status.trim().toLowerCase() == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredTasks = _filteredTasks;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        // --- ADDED PURPLE BORDER ---
        border: Border.all(
          color: isDark ? _brandPurple.withOpacity(0.3) : _borderPurple,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _brandPurple.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumHeader(isDark),

          // Animated Visibility for the Dropdown content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                const Divider(height: 1, color: _borderPurple),
                _buildTaskList(filteredTasks, isDark),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _brandPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_motion_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),

          // Title Logic
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace Tasks',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Viewing ${_selectedFilter.replaceAll('_', ' ')} items',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // --- THE DROPDOWN BUTTON ---
          _buildFilterDropdown(isDark),

          const SizedBox(width: 12),

          // Expand/Collapse Toggle
          IconButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: _brandPurple,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _purpleLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderPurple),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          icon: const Icon(Icons.filter_list_rounded, color: _brandPurple, size: 18),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _brandPurple,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
                _isExpanded = true; // Auto expand when filter changes
              });
            }
          },
          items: const [
            DropdownMenuItem(value: 'all', child: Text("All Categories")),
            DropdownMenuItem(value: 'pending', child: Text("Pending Only")),
            DropdownMenuItem(value: 'in_progress', child: Text("In Progress")),
            DropdownMenuItem(value: 'completed', child: Text("Completed")),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> filteredTasks, bool isDark) {
    if (filteredTasks.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, color: _brandPurple.withOpacity(0.2), size: 48),
            const SizedBox(height: 12),
            Text(
              'No tasks in this category',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: filteredTasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return ModernTaskCard(
              task: task,
              isDark: isDark,
              onTap: widget.onTaskTap,
              onDelete: (taskToArchive) {
                if (task.status.trim().toLowerCase() == 'completed') {
                  _showArchiveConfirmation(context, taskToArchive);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Only completed tasks can be archived.")),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  void _showArchiveConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Confirm Archive", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text("Do you want to archive \"${task.title}\"? This action is permanent."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _brandPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              context.read<AdminDashboardBloc>().add(ApproveTaskRequested(taskId: task.id));
              setState(() => _localTasks.removeWhere((t) => t.id == task.id));
              Navigator.pop(ctx);
            },
            child: const Text("Archive Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}