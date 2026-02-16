import 'package:flutter/material.dart';
import '../model/employee.dart';


class EmployeeSection extends StatefulWidget {
  final List<Employee> employees;
  final VoidCallback? onViewAll;
  final Function(Employee)? onEmployeeTap;

  const EmployeeSection({
    super.key,
    required this.employees,
    this.onViewAll,
    this.onEmployeeTap,
  });

  @override
  State<EmployeeSection> createState() => _EmployeeSectionState();
}

class _EmployeeSectionState extends State<EmployeeSection> {
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
    return Semantics(
      label: 'Employees section with ${widget.employees.length} active employees',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {
          if (!_scrollController.hasClients) return;

          final newOffset = _scrollController.offset - details.delta.dy;

          _scrollController.jumpTo(
            newOffset.clamp(
              _scrollController.position.minScrollExtent,
              _scrollController.position.maxScrollExtent,
            ),
          );
        },
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
              _buildContent(),
            ],
          ),
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
                    Icons.people_alt_rounded,
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
                        "Employees",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        "${widget.employees.length} active",
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
      label: 'View all employees',
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

  Widget _buildContent() {
    if (widget.employees.isEmpty) {
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
              itemCount: widget.employees.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              cacheExtent: 200,
              itemBuilder: (_, i) {
                final emp = widget.employees[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EmployeeCard(
                    key: ValueKey(emp.hashCode),
                    employee: emp,
                    animationDelay: i < 5 ? i * 50 : 0,
                    onTap: widget.onEmployeeTap != null
                        ? () => widget.onEmployeeTap!(emp)
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
                Icons.people_outline_rounded,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No active employees",
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Employees will appear here when active",
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

/// Optimized employee card widgets - Light theme
class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final int animationDelay;
  final VoidCallback? onTap;

  const _EmployeeCard({
    super.key,
    required this.employee,
    this.animationDelay = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Semantics(
      button: true,
      label: 'Employee: ${employee.name}, ${employee.designation}, ${employee.statusText}',
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
                children: [
                  _Avatar(employee: employee),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _EmployeeInfo(employee: employee),
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
}

/// Employee information section - Light theme
class _EmployeeInfo extends StatelessWidget {
  final Employee employee;

  const _EmployeeInfo({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                employee.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            _StatusPill(employee: employee),
          ],
        ),
        const SizedBox(height: 6),
        _buildDesignationRow(),
        const SizedBox(height: 12),
        _buildTimeCard(),
      ],
    );
  }

  Widget _buildDesignationRow() {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              employee.designation?? " ",
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          "•",
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
        employee.designation?? " ",
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TimeInfo(
              icon: Icons.login_rounded,
              label: "Check In",
              time: employee.checkIn,
              color: const Color(0xFF10B981),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: const Color(0xFFE5E7EB),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TimeInfo(
              icon: Icons.logout_rounded,
              label: "Check Out",
              time: employee.checkOut == '-' ? "Active" : employee.checkOut,
              color: employee.checkOut == '-'
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}

/// Time information widgets (Check In/Out) - Light theme
class _TimeInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _TimeInfo({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: time == "Active"
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Employee avatar widgets - Light theme
class _Avatar extends StatelessWidget {
  final Employee employee;

  const _Avatar({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Avatar for ${employee.name}',
      child: Stack(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                employee.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Semantics(
              label: 'Online status indicator',
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF9FAFB),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _StatusPill extends StatelessWidget {
  final Employee employee;

  const _StatusPill({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: employee.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: employee.statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: employee.statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: employee.statusColor.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            employee.statusText,
            style: TextStyle(
              color: employee.statusColor,
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