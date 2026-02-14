import 'package:flutter/material.dart';
import '../model/task.dart';

/// Production-ready Task Section Widget - Light Theme
/// Optimized for handling large datasets (100+ tasks)
/// with proper error handling, accessibility, and performance optimizations
class TaskSection extends StatefulWidget {
  final List<Task> tasks;
  final VoidCallback? onViewAll;
  final Function(Task)? onTaskTap;

  const TaskSection({
    super.key,
    required this.tasks,
    this.onViewAll,
    this.onTaskTap,
  });

  @override
  State<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends State<TaskSection> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollIndicator = false;
  bool _isDisposed = false;
  String _selectedFilter = 'all'; // all, pending, in_progress, completed

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && _scrollController.hasClients) {
        setState(() {
          _showScrollIndicator =
              _scrollController.position.maxScrollExtent > 0;
        });
      }
    });
  }

  void _onScroll() {
    if (!_isDisposed && _scrollController.hasClients) {
      final isScrollable = _scrollController.position.maxScrollExtent > 0;
      if (isScrollable != _showScrollIndicator) {
        setState(() {
          _showScrollIndicator = isScrollable;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  List<Task> get _filteredTasks {
    if (_selectedFilter == 'all') return widget.tasks;
    return widget.tasks
        .where((task) => task.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;

    return Semantics(
      label: 'Tasks section with ${widget.tasks.length} tasks',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildDivider(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 16),
            _buildContent(filteredTasks),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.task_alt_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Projects & Tasks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        "${widget.tasks.length} total",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildViewAllButton(),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Semantics(
      button: true,
      label: 'View all tasks',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.3),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onViewAll ?? () {},
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "View All",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF6366F1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFE5E7EB),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterChip('all', 'All Tasks', widget.tasks.length),
          const SizedBox(width: 8),
          _buildFilterChip(
            'pending',
            'Pending',
            widget.tasks.where((t) => t.status == 'pending').length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'in_progress',
            'In Progress',
            widget.tasks.where((t) => t.status == 'in_progress').length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'completed',
            'Completed',
            widget.tasks.where((t) => t.status == 'completed').length,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          )
              : null,
          color: isSelected ? null : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<Task> filteredTasks) {
    if (filteredTasks.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 420,
            ),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filteredTasks.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              cacheExtent: 200,
              itemBuilder: (_, i) {
                final task = filteredTasks[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TaskCard(
                    key: ValueKey(task.hashCode),
                    task: task,
                    animationDelay: i < 5 ? i * 50 : 0,
                    onTap: widget.onTaskTap != null
                        ? () => widget.onTaskTap!(task)
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
        if (_showScrollIndicator) _buildScrollIndicator(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_outlined,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all'
                  ? "No tasks available"
                  : "No ${_selectedFilter.replaceAll('_', ' ')} tasks",
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tasks will appear here when assigned",
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return Positioned(
      right: 24,
      top: 0,
      bottom: 20,
      child: AnimatedOpacity(
        opacity: _showScrollIndicator ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  if (!_scrollController.hasClients ||
                      _scrollController.position.maxScrollExtent <= 0) {
                    return const SizedBox.shrink();
                  }

                  final position = _scrollController.position;
                  final scrollPercentage = (position.pixels /
                      position.maxScrollExtent)
                      .clamp(0.0, 1.0);
                  final indicatorHeight = constraints.maxHeight * 0.3;
                  final maxOffset = constraints.maxHeight - indicatorHeight;
                  final offset = maxOffset * scrollPercentage;

                  return Transform.translate(
                    offset: Offset(0, offset),
                    child: Container(
                      height: indicatorHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Optimized task card widgets - Light theme
class _TaskCard extends StatelessWidget {
  final Task task;
  final int animationDelay;
  final VoidCallback? onTap;

  const _TaskCard({
    super.key,
    required this.task,
    this.animationDelay = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Semantics(
      button: true,
      label: 'Task: ${task.title}, Priority: ${task.priority}, Status: ${_statusText()}',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTaskInfo(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Only animate first 5 cards
    if (animationDelay > 0) {
      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 400 + animationDelay),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: card,
      );
    }

    return card;
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _initials(task.assignedToName),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
            _buildPriorityChip(),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                task.assignedToName,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatusChip(),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    task.dueDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip() {
    final color = _priorityColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        task.priority.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final color = _statusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _statusText(),
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor() {
    switch (task.priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Color _statusColor() {
    switch (task.status) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _statusText() {
    switch (task.status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      default:
        return 'Pending';
    }
  }

  String _initials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.split(" ");
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }
}