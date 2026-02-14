import 'package:flutter/material.dart';
// Using your actual model path
import 'package:my_app/admin_dashboard/model/task.dart';

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
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Task> get _filteredTasks {
    if (_selectedFilter == 'all') return widget.tasks;
    return widget.tasks
        .where((task) => task.status.trim().toLowerCase() == _selectedFilter)
        .toList();
  }

  int _getCountForFilter(String filter) {
    if (filter == 'all') return widget.tasks.length;
    return widget.tasks
        .where((t) => t.status.trim().toLowerCase() == filter)
        .length;
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
          Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE8E8ED)),
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
            width: 48, height: 48,
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                Text('${widget.tasks.length} total tasks',
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
          color: isSelected ? (isDark ? const Color(0xFF3B4DE0) : const Color(0xFFEEF0FF)) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                    color: isSelected ? (isDark ? Colors.white : const Color(0xFF3B4DE0)) : const Color(0xFF6B6B7B))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? (isDark ? Colors.white24 : const Color(0xFF3B4DE0)) : const Color(0xFFE8E8ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count', style: const TextStyle(fontSize: 12, color: Colors.white)),
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
            return _ModernTaskCard(
              task: filteredTasks[index],
              isDark: isDark,
              onTap: widget.onTaskTap,
            );
          },
        ),
      ),
    );
  }
}

class _ModernTaskCard extends StatelessWidget {
  final Task task;
  final bool isDark;
  final Function(Task)? onTap;

  const _ModernTaskCard({required this.task, required this.isDark, this.onTap});

  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'completed': return const Color(0xFF10B981);
      case 'in_progress': return const Color(0xFF3B82F6);
      default: return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(task.status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFE6E8EC)),
      ),
      child: InkWell(
        onTap: () => onTap?.call(task),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF2563EB),
                    child: Text(task.assignedToName.isNotEmpty ? task.assignedToName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(task.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                  ),
                  _Badge(label: task.priority, color: _getPriorityColor(task.priority)),
                ],
              ),
              const SizedBox(height: 12),
              // WRAP prevents the overflow bug that kills your taps
              Wrap(
                spacing: 16,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const SizedBox(width: 44), // Alignment offset
                  Text(task.assignedToName, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  _StatusChip(status: task.status, color: statusColor),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Text(task.dueDate, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String p) {
    if (p.toLowerCase() == 'high') return const Color(0xFFFF4757);
    if (p.toLowerCase() == 'low') return const Color(0xFF10B981);
    return const Color(0xFFFF9800);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(label.toUpperCase(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}