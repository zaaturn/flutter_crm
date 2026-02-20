import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.tasks,
    required this.filterStatus,
    required this.filterPriority,
    required this.isBoardView,
    required this.onStatusFilterChanged,
    required this.onPriorityFilterChanged,
  });

  final List<TaskModel> tasks;
  final String? filterStatus;
  final String? filterPriority;
  final bool isBoardView;
  final ValueChanged<String?> onStatusFilterChanged;
  final ValueChanged<String?> onPriorityFilterChanged;

  static const _surface = Colors.white;
  static const _border = Color(0xFFE2E8F0);
  static const _high = Color(0xFFEF4444);
  static const _medium = Color(0xFFF97316);
  static const _low = Color(0xFF10B981);
  static const _accent = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    final statusItems = [
      ('All Tasks', null, Icons.home_outlined, tasks.length),
      (
      'Pending',
      'PENDING',
      Icons.schedule_outlined,
      tasks.where((t) => t.status == 'PENDING').length
      ),
      (
      'In Progress',
      'IN_PROGRESS',
      Icons.trending_up_outlined,
      tasks.where((t) => t.status == 'IN_PROGRESS').length
      ),
      (
      'Completed',
      'COMPLETED',
      Icons.check_circle_outline,
      tasks.where((t) => t.status == 'COMPLETED').length
      ),
    ];

    final priorityItems = [
      ('High Priority', 'HIGH', Icons.keyboard_arrow_up_outlined, _high),
      ('Medium Priority', 'MEDIUM', Icons.remove_outlined, _medium),
      ('Low Priority', 'LOW', Icons.keyboard_arrow_down_outlined, _low),
    ];

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(right: BorderSide(color: _border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sidebarLabel('Workspace'),

          ...statusItems.map(
                (item) => _SidebarItem(
              label: item.$1,
              icon: item.$3,
              badge: item.$4,
              isActive: filterStatus == item.$2 && item.$2 != null,
              isAllActive: item.$2 == null &&
                  filterStatus == null &&
                  filterPriority == null,
              onTap: () {
                onStatusFilterChanged(
                    filterStatus == item.$2 ? null : item.$2);
              },
            ),
          ),

          const SizedBox(height: 8),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 8),

          _sidebarLabel('Priority'),

          ...priorityItems.map(
                (item) => _SidebarItem(
              label: item.$1,
              icon: item.$3,
              priorityColor: item.$4,
              isActive: filterPriority == item.$2,
              onTap: () {
                onPriorityFilterChanged(
                    filterPriority == item.$2 ? null : item.$2);
              },
            ),
          ),

          const Spacer(),

          if (isBoardView)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
                border:
                Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.drag_indicator,
                      size: 14, color: _accent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Drag cards between columns to change status',
                      style: TextStyle(
                          fontSize: 11,
                          color: _accent,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebarLabel(String label) => Padding(
    padding:
    const EdgeInsets.only(left: 8, top: 4, bottom: 6),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Color(0xFF94A3B8),
      ),
    ),
  );
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badge,
    this.isActive = false,
    this.isAllActive = false,
    this.priorityColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  final bool isActive;
  final bool isAllActive;
  final Color? priorityColor;

  @override
  Widget build(BuildContext context) {
    final active = isActive || isAllActive;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFEEF2FF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: active
                  ? const Color(0xFF6366F1)
                  : priorityColor ??
                  const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                  active ? FontWeight.w600 : FontWeight.w500,
                  color: active
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? const Color(0xFFC7D2FE)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}