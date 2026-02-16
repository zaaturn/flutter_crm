import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

class DesktopEmployeeSection extends StatefulWidget {
  final List<Employee> employees;
  final VoidCallback? onViewAll;
  final Function(Employee)? onEmployeeTap;

  const DesktopEmployeeSection({
    super.key,
    required this.employees,
    this.onViewAll,
    this.onEmployeeTap,
  });

  @override
  State<DesktopEmployeeSection> createState() => _DesktopEmployeeSectionState();
}

class _DesktopEmployeeSectionState extends State<DesktopEmployeeSection> {
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
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
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
        ),
      ),
    );
  }
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Left side (icon + title)
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
                    Icons.people_alt_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),

                // Title texts
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Active Employees",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                          isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${widget.employees.length} employees currently active",
                        overflow: TextOverflow.ellipsis,
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

          // Right side button (now shrink-safe)
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: _buildViewAllButton(isDark),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildViewAllButton(bool isDark) {
    return Semantics(
      button: true,
      label: 'View all employees',
      child: Container(
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
            onTap: widget.onViewAll ?? () {},
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
    if (widget.employees.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 480,
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
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DesktopEmployeeCard(
                    key: ValueKey(emp.hashCode),
                    employee: emp,
                    isDark: isDark,
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
                Icons.people_outline_rounded,
                size: 48,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No active employees",
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Employees will appear here when they check in",
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

/// Desktop-optimized employee card widgets
class _DesktopEmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isDark;
  final int animationDelay;
  final VoidCallback? onTap;

  const _DesktopEmployeeCard({
    super.key,
    required this.employee,
    required this.isDark,
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
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF475569)
                : const Color(0xFFE2E8F0),
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
                  _Avatar(employee: employee, isDark: isDark),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _EmployeeInfo(employee: employee, isDark: isDark),
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

/// Employee information section - Desktop optimized
class _EmployeeInfo extends StatelessWidget {
  final Employee employee;
  final bool isDark;

  const _EmployeeInfo({
    required this.employee,
    required this.isDark,
  });

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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 12),
            _StatusPill(employee: employee, isDark: isDark),
          ],
        ),
        const SizedBox(height: 8),
        _buildDesignationRow(),
        const SizedBox(height: 14),
        _buildTimeCard(),
      ],
    );
  }

  Widget _buildDesignationRow() {
    return Row(
      children: [
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
                Icons.work_outline_rounded,
                size: 12,
                color: Color(0xFF0D3199),
              ),
              const SizedBox(width: 6),
              Text(
                employee.department ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF0D3199),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "•",
          style: TextStyle(
            color: isDark
                ? const Color(0xFF64748B)
                : const Color(0xFF94A3B8),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            employee.department ?? '',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF475569)
              : const Color(0xFFE2E8F0),
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
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: isDark
                ? const Color(0xFF475569)
                : const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _TimeInfo(
              icon: Icons.logout_rounded,
              label: "Check Out",
              time: employee.checkOut == '-' ? "Active" : employee.checkOut,
              color: employee.checkOut == '-'
                  ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                  : const Color(0xFFEF4444),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Time information widgets (Check In/Out) - Desktop optimized
class _TimeInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;
  final bool isDark;

  const _TimeInfo({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  color: time == "Active"
                      ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  fontWeight: FontWeight.bold,
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

/// Employee avatar widgets - Desktop optimized
class _Avatar extends StatelessWidget {
  final Employee employee;
  final bool isDark;

  const _Avatar({
    required this.employee,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Avatar for ${employee.name}',
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D3199),
                  Color(0xFF1E40AF),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
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
                employee.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF8F9FA),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
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

/// Status pill widgets - Desktop optimized
class _StatusPill extends StatelessWidget {
  final Employee employee;
  final bool isDark;

  const _StatusPill({
    required this.employee,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  color: employee.statusColor.withOpacity(0.5),
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