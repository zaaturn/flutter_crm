import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/project.dart';

class DesktopProjectSection extends StatefulWidget {
  final List<Project> projects;
  final VoidCallback? onViewAll;
  final Function(Project)? onProjectTap;

  const DesktopProjectSection({
    super.key,
    required this.projects,
    this.onViewAll,
    this.onProjectTap,
  });

  @override
  State<DesktopProjectSection> createState() => _DesktopProjectSectionState();
}

class _DesktopProjectSectionState extends State<DesktopProjectSection> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollIndicator = false;
  bool _isDisposed = false;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isDark),
          _buildDivider(isDark),
          _buildContent(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D3199), Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.view_list_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Projects & Tasks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${widget.projects.length} active projects",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (widget.onViewAll != null) _buildViewAllButton(isDark),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D3199),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D3199).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onViewAll,
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildContent(bool isDark) {
    if (widget.projects.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 420,
            ),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.projects.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, i) {
                final project = widget.projects[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ProjectCard(
                    key: ValueKey(project.hashCode),
                    project: project,
                    isDark: isDark,
                    animationDelay: i < 5 ? i * 50 : 0,
                    onTap: widget.onProjectTap != null
                        ? () => widget.onProjectTap!(project)
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
        if (_showScrollIndicator) _buildScrollIndicator(isDark),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No active projects",
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Projects will appear here when created",
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollIndicator(bool isDark) {
    return Positioned(
      right: 28,
      top: 24,
      bottom: 24,
      child: AnimatedOpacity(
        opacity: _showScrollIndicator ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 4,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
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
                        color: const Color(0xFF0D3199),
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

/// Individual Project Card Widget
class _ProjectCard extends StatelessWidget {
  final Project project;
  final bool isDark;
  final int animationDelay;
  final VoidCallback? onTap;

  const _ProjectCard({
    super.key,
    required this.project,
    required this.isDark,
    this.animationDelay = 0,
    this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return const Color(0xFF10B981);
      case 'in progress':
      case 'ongoing':
        return const Color(0xFF0D3199);
      case 'pending':
      case 'waiting':
        return const Color(0xFFFF8C32);
      case 'blocked':
      case 'delayed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return Icons.check_circle_rounded;
      case 'in progress':
      case 'ongoing':
        return Icons.sync_rounded;
      case 'pending':
      case 'waiting':
        return Icons.pending_rounded;
      case 'blocked':
      case 'delayed':
        return Icons.block_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(project.status);
    final statusIcon = _getStatusIcon(project.status);

    final card = Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Project Avatar/Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D3199), Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D3199).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      project.owner.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Project Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _StatusBadge(
                            status: project.status,
                            color: statusColor,
                            icon: statusIcon,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Owner badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D3199).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF0D3199).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 12,
                                  color: Color(0xFF0D3199),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  project.owner,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0D3199),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Deadline
                          Icon(
                            Icons.event_rounded,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Due ${project.deadline}",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow indicator
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ],
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
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.status,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alternative: Grid Layout for Projects
class DesktopProjectSectionGrid extends StatelessWidget {
  final List<Project> projects;
  final VoidCallback? onViewAll;
  final Function(Project)? onProjectTap;

  const DesktopProjectSectionGrid({
    super.key,
    required this.projects,
    this.onViewAll,
    this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          Container(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: projects.isEmpty
                ? _buildEmptyState(isDark)
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: projects.length,
              itemBuilder: (_, i) {
                return _ProjectGridCard(
                  project: projects[i],
                  isDark: isDark,
                  onTap: onProjectTap != null
                      ? () => onProjectTap!(projects[i])
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D3199), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.view_list_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Projects & Tasks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${projects.length} active projects",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (onViewAll != null)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D3199),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "View All",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No active projects",
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid Card for Projects
class _ProjectGridCard extends StatelessWidget {
  final Project project;
  final bool isDark;
  final VoidCallback? onTap;

  const _ProjectGridCard({
    required this.project,
    required this.isDark,
    this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return const Color(0xFF10B981);
      case 'in progress':
      case 'ongoing':
        return const Color(0xFF0D3199);
      case 'pending':
      case 'waiting':
        return const Color(0xFFFF8C32);
      case 'blocked':
      case 'delayed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(project.status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D3199), Color(0xFF1E40AF)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          project.owner.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Due ${project.deadline}",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}