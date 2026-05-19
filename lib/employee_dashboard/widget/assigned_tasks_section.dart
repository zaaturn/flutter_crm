import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';
// Ensure this path matches your project structure
import '../utils/design_tokens.dart';

class AssignedTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(int, String) onStatusChange;

  const AssignedTasksSection({
    super.key,
    required this.tasks,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Sort tasks so the highest ID (most recent) is first.
    final sortedTasks = List<TaskModel>.from(tasks)
      ..sort((a, b) => b.id.compareTo(a.id));

    // Calculate active vs completed for the chip
    final activeCount = sortedTasks.where((t) => t.status.toUpperCase() != 'COMPLETED').length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "Active Tasks",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B), // Deep slate from screenshot
                fontFamily: 'Manrope', // Assuming your main font
              ),
            ),
            // --- MATCHING PURPLE CHIP FROM SCREENSHOT ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7FE), // Light purple background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$activeCount REMAINING',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF5452F6), // Deep indigo text
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (sortedTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text("No active tasks.", style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.separated(
            itemCount: sortedTasks.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _ExpandableTaskCard(
                task: sortedTasks[index],
                onStatusChange: onStatusChange,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
      ],
    );
  }
}

class _ExpandableTaskCard extends StatefulWidget {
  final TaskModel task;
  final Function(int, String) onStatusChange;

  const _ExpandableTaskCard({
    required this.task,
    required this.onStatusChange,
  });

  @override
  State<_ExpandableTaskCard> createState() => _ExpandableTaskCardState();
}

class _ExpandableTaskCardState extends State<_ExpandableTaskCard> {
  bool _isExpanded = false;

  // Premium SaaS Colors matching the Dashboard
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED': return const Color(0xFF10B981); // Emerald Green
      case 'IN_PROGRESS':
      case 'IN PROGRESS': return const Color(0xFF5452F6); // Indigo Blue
      case 'PENDING': return const Color(0xFFF59E0B); // Amber/Orange (Matches Screenshot)
      default: return const Color(0xFF94A3B8); // Slate Grey
    }
  }

  String _getSafeStatus(String currentStatus) {
    const validStatuses = ['Pending', 'In Progress', 'Completed'];
    final cleanStatus = currentStatus.replaceAll('_', ' ').toLowerCase();

    return validStatuses.firstWhere(
          (s) => s.toLowerCase() == cleanStatus,
      orElse: () => 'Pending',
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.task.status);
    final safeStatus = _getSafeStatus(widget.task.status);

    double progress = 0.0;
    if (safeStatus == 'In Progress') progress = 0.5;
    if (safeStatus == 'Completed') progress = 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Faint colored border matching the screenshot's amber outline
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- COMPACT HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon Container matching screenshot (amber tinted)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        safeStatus == 'Completed' ? Icons.check_circle_rounded : Icons.insert_chart_rounded,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Text(
                            widget.task.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B), // Dark slate
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(
                              widget.task.dueDate ?? "No Date",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),

            // --- EXPANDED CONTENT ---
            if (_isExpanded) ...[
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
              const SizedBox(height: 16),

              // Description matched to screenshot
              const Text(
                "Description",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B) // Grey label
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.task.description.isEmpty ? "No description provided." : widget.task.description,
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5),
                softWrap: true,
              ),

              const SizedBox(height: 24),

              // Interactive Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                      'STATUS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: safeStatus,
                        icon: Icon(Icons.arrow_drop_down_rounded, color: statusColor, size: 22),
                        isDense: true,
                        style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w800),
                        items: const [
                          DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                          DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            String apiStatus = v.toUpperCase().replaceAll(' ', '_');
                            widget.onStatusChange(widget.task.id, apiStatus);
                            if (v == 'Completed') {
                              setState(() => _isExpanded = false);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Progress Bar
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('COMPLETION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      Text('${(progress * 100).toInt()}%', style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: statusColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}